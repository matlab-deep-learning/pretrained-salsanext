%% Configure Pretrained SalsaNext Network for Transfer Learning
% The following code demonstrates configuring a pretrained 
% SalsaNext[1] network on the custom dataset.

%% Download Pretrained Model

model = helper.downloadPretrainedSalsaNext; 
net = model.net;

%% Download Pandaset Data Set
% This example uses a subset of PandaSet[2], that contains 2560
% preprocessed organized point clouds. Each point cloud is specified as a
% 64-by-1856 matrix. The corresponding ground truth contains the semantic
% segmentation labels for 12 classes. The point clouds are stored in PCD
% format, and the ground truth data is stored in PNG format. The size of
% the data set is 5.2 GB. Execute this code to download the data set.

url = 'https://ssd.mathworks.com/supportfiles/lidar/data/Pandaset_LidarData.tar.gz';
outputFolder = fullfile(tempdir,'Pandaset');

lidarDataTarFile = fullfile(outputFolder,'Pandaset_LidarData.tar.gz');
if ~exist(lidarDataTarFile, 'file')
    mkdir(outputFolder);
    disp('Downloading Pandaset Lidar driving data (5.2 GB)...');
    websave(lidarDataTarFile, url);
    untar(lidarDataTarFile,outputFolder);
end

% Check if tar.gz file is downloaded, but not uncompressed.
if (~exist(fullfile(outputFolder,'Lidar'), 'file'))...
        &&(~exist(fullfile(outputFolder,'semanticLabels'), 'file'))
    untar(lidarDataTarFile,outputFolder);
end

lidarData =  fullfile(outputFolder,'Lidar');
labelsFolder = fullfile(outputFolder,'semanticLabels');

% Note: Depending on your Internet connection, the download process can
% take some time. The code suspends MATLAB® execution until the download
% process is complete. Alternatively, you can download the data set to your
% local disk using your web browser, and then extract Pandaset_LidarData
% folder. To use the file you downloaded from the web, change the
% outputFolder variable in the code to the location of the downloaded file.
 
%% Prepare Data for Training
% Load Lidar Point Clouds and Class Labels Use the generateLidarData helper
% function, to generate training data from the lidar point clouds. The
% function uses point cloud data to create five-channel input images. Each
% training image is specified as a 64-by-1856-by-5 array:
% 
% Generate the five-channel training images.

imagesFolder = fullfile(outputFolder,'Images');
helper.generateLidarData(lidarData,imagesFolder);
 
% The five-channel images are saved as MAT files. 
% 
% Note: Processing can take some time. The code suspends MATLAB® execution
% until processing is complete.

%% Load Generated Images.
% Create ImageDatastore and PixelLabelDatastore Use the ImageDatastore
% object to extract and store the five channels of the 2-D spherical images
% using the imageMatReader helper function, which is a custom MAT file
% reader.

imds = imageDatastore(imagesFolder, ...
    'FileExtensions', '.mat', ...
    'ReadFcn', @helper.imageMatReader);
 
% Use the PixelLabelDatastore object to store pixel-wise labels from pixel
% label images. The object maps each pixel label to a class name. In this
% example, vegetation, ground, road, road markings, side walk, cars,
% trucks, other vehicles, pedestrian, road barrier signs and buildings are
% the objects of interest; all other pixels are the background. Specify
% these classes and assign a unique label ID to each class.

classNames = ["unlabelled"
              "Vegetation"
              "Ground"
              "Road"
              "RoadMarkings"
              "SideWalk"
              "Car"
              "Truck"
              "OtherVehicle"
              "Pedestrian"
              "RoadBarriers"
              "Signs"
              "Buildings"];

numClasses = numel(classNames);

% Specify label IDs from 1 to the number of classes.
labelIDs = 1 : numClasses;

pxds = pixelLabelDatastore(labelsFolder, classNames, labelIDs);

%% Prepare Training, Validation, and Test Sets
% Use the partitionLidarData helper function to split the data into
% training, images, respectively.

[imdsTrain, imdsVal, imdsTest, pxdsTrain, pxdsVal, pxdsTest] = helper.partitionLidarData(imds, pxds);

dsTrain = combine(imdsTrain,pxdsTrain);
dsVal = combine(imdsVal,pxdsVal);

%% Data Augmentation
% Data augmentation is used to improve network accuracy by randomly
% transforming the original data during training. By using data
% augmentation, you can add more variety to the training data without
% actually having to increase the number of labeled training samples.
% 
% Augment the training data by using the transform function with custom
% preprocessing operations specified by the augmentData helper function.
% This function randomly flips the multichannel 2-D image and associated
% labels in the horizontal direction. Apply data augmentation to only the
% training data set.

augmentedTrainingData = transform(dsTrain, @(x) helper.augmentData(x));
%% Configure Pretrained Network

% Extract the layergraph from the pretrained network to perform custom
% modification.
lgraph = layerGraph(net);

% Changing output size to required number of classes.
lgraph = replaceLayer(lgraph, 'Conv_191', convolution2dLayer([1,1], numClasses, 'Name', 'Conv_191'));

%% % Define training options. 
options = trainingOptions('sgdm', ...
    'LearnRateSchedule','piecewise',...
    'LearnRateDropPeriod',10,...
    'LearnRateDropFactor',0.3,...
    'Momentum',0.9, ...
    'InitialLearnRate',1e-3, ...
    'L2Regularization',0.005, ...
    'ValidationData',dsVal,...
    'MaxEpochs',6, ...  
    'MiniBatchSize',8, ...
    'Shuffle','every-epoch', ...
    'CheckpointPath', tempdir, ...
    'VerboseFrequency',2,...
    'Plots','training-progress',...
    'ValidationPatience', 4);

% The learning rate uses a piecewise schedule. The learning rate is reduced 
% by a factor of 0.3 every 10 epochs. This allows the network to learn quickly 
% with a higher initial learning rate, while being able to find a solution 
% close to the local optimum once the learning rate drops.
%
% The network is tested against the validation data every epoch by setting 
% the 'ValidationData' parameter. The 'ValidationPatience' is set to 4 to 
% stop training early when the validation accuracy converges. This prevents 
% the network from overfitting on the training dataset.
%
% A mini-batch size of 16 is used for training. You can increase or decrease 
% this value based on the amount of GPU memory you have on your system.
%
% In addition, 'CheckpointPath' is set to a temporary location. This name-value 
% pair enables the saving of network checkpoints at the end of every training 
% epoch. If training is interrupted due to a system failure or power outage, 
% you can resume training from the saved checkpoint. Make sure that the location 
% specified by 'CheckpointPath' has enough space to store the network checkpoints.

% Now, you can pass the 'dsTrain', 'lgraph' and 'options' to trainNetwork
% as shown in 'Train Network' section of the example 'Lidar Point Cloud
% Semantic Segmentation Using SqueezeSegV2 Deep Learning Network Example'
% (https://www.mathworks.com/help/lidar/ug/semantic-segmentation-using-squeezesegv2-network.html)to
% obtain salsaNext model trained on the custom dataset.
%
% You can follow the sections 'Test Network on One Image' for inference using 
% the trained model and 'Evaluate Trained Network' for evaluating metrics.


%% References

% [1] Cortinhal, Tiago, George Tzelepis, and Eren Erdal Aksoy. "SalsaNext: Fast, 
% Uncertainty-Aware Semantic Segmentation of LiDAR Point Clouds for Autonomous 
% Driving." ArXiv:2003.03653 [Cs], July 9, 2020. http://arxiv.org/abs/2003.03653 
% http://arxiv.org/abs/2003.03653.
% 
% [2] https://scale.com/open-datasets/pandaset https://scale.com/open-datasets/pandaset
% 
% Copyright 2020 The MathWorks, Inc.