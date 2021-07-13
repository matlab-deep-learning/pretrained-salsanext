%% Code generation For SalsaNext Network
% The following script demonstrates how to perform code generation for a
% pretrained SalsaNext semantic segmentation network, trained on Pandaset
% dataset.

%% Download the pre-trained network
helper.downloadPretrainedSalsaNext;  

%% Read and process the input point cloud 
% Read test point cloud.
ptCloud = pcread('pointclouds/Input1.pcd');

% Convert point cloud to 5-channel image.
I = helper.pointCloudToImage(ptCloud);

%% Run MEX code generation
% The salsaNextpredict.m is entry-point function that takes an input image
% and gives output. The function uses a persistent object salsaNextObj to 
% load the DAG network object and reuses the persistent object for prediction 
% on subsequent calls.
%
% To generate CUDA code for the salsaNextpredict entry-point function, 
% create a GPU code configuration object for a MEX target and set the 
% target language to C++. 
% 
% Use the coder.DeepLearningConfig (GPU Coder) function to create a CuDNN 
% deep learning configuration object and assign it to the DeepLearningConfig 
% property of the GPU code configuration object. 
% 
% Run the codegen command and specify the input size. 
cfg = coder.gpuConfig('mex');
cfg.TargetLang = 'C++';
cfg.DeepLearningConfig = coder.DeepLearningConfig('cudnn');
codegen -config cfg salsaNextpredict -args {ones(64,1856,5)} -report

%% Perform Semantic Segmenation Using Generated Mex
% Call salsaNextpredict_mex on the input range image.
predict_scores = salsaNextpredict_mex(I);

% The predict_scores variable is a three-dimensional matrix that has 13
% channels corresponding to the pixel-wise prediction scores for every
% class. Compute the channel by using the maximum prediction score to get
% pixel-wise labels.
[~,op] = max(predict_scores,[],3);

% Visualize the result.
cmap = helper.lidarColorMap();
colormap = cmap(op,:);
ptCloudMod = pointCloud(reshape(I(:,:,1:3),[],3),"Color",colormap);
figure
ax1 = pcshow(ptCloudMod);
zoom(ax1,3);


% Copyright 2021 The MathWorks, Inc