%% Lidar Point Cloud Semantic Segmentation Using SalsaNext Deep Learning Network
% The following code demonstrates running prediction on a pre-trained
% SalsaNext network, trained on Pandaset Dataset.

%% Prerequisites
% To run this example you need the following prerequisites - 
% # MATLAB (R2021a or later) with Lidar and Deep Learning Toolbox.
% # Pretrained SalsaNext network(download instructions below)

%% Download the pre-trained network
model = helper.downloadPretrainedSalsaNext; 
net = model.net;  

% Define ClassNames
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
          
%% Perform Semantic Segmentation Using SalsaNext Network
% Read test point cloud.
ptCloud = pcread('pointclouds/Input1.pcd');

% Convert point cloud to 5-channel image.
I = helper.pointCloudToImage(ptCloud);

% Segment objects from the test point cloud.
predictedResult = semanticseg(I, net,"ExecutionEnvironment","auto");

%% Display Output 
figure;
helper.displayLidarOverlayImage(I, predictedResult, classNames);
title('Semantic Segmentation Result');

% Display in point cloud format.
cmap = helper.lidarColorMap();
colormap = cmap(single(predictedResult),:);
ptCloudMod = pointCloud(reshape(I(:,:,1:3),[],3),"Color",colormap);
figure
ax = pcshow(ptCloudMod);
zoom(ax,3);

%% Get Bounding Boxes from semgenation output.
% Get the indices of points for the required class.
carIdx = (predictedResult == 'Car');

% Select the points of required class and cluster them based on distance.
ptCldMod = select(ptCloud,carIdx);
[labels,numClusters] = pcsegdist(ptCldMod,0.5);

% Select each cluster and fit a cuboid to each cluster.
bboxes = [];
for num = 1:numClusters
    labelIdx = (labels == num);
    
    % Ignore cluster that has points less than 200 points.
    if sum(labelIdx,'all') < 200
        continue;
    end
    pcSeg = select(ptCldMod,labelIdx);
    try
        mdl = pcfitcuboid(pcSeg);
        bboxes = [bboxes;mdl.Parameters];
    catch
        continue;
    end
end

% Display the output.
figure;
ax = pcshow(ptCloudMod);
showShape('cuboid',bboxes,'Parent',ax,'Opacity',0.1,...
         'Color','green','LineWidth',0.5);
zoom(ax,3);

% Copyright 2021 The MathWorks, Inc