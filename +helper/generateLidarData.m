function generateLidarData(lidarData, imageDataLocation)

%generateLidarData Function to generate images 
%   from Lidar Point Clouds. The inputs
%   lidarData, imageDataLocation are described below.
% 
%  Inputs
%  ------
%   lidarData           Lidar point clouds folder path.
%
%   imageDataLocation   Folder where training images will be saved to
%                       disk. Make sure this points to a valid location on 
%                       the filesystem.
% 
% Copyright 2021 The MathWorks, Inc

if ~exist(imageDataLocation,'dir')
    mkdir(imageDataLocation);
end


tmpStr = '';
lidarData = dir(fullfile(lidarData,'*.pcd'));
numFiles = size(lidarData,1);
for i=1:numFiles
    % Load ptcloud object.
    data = fullfile(lidarData(i).folder,lidarData(i).name);
    ptcloud = pcread(data);
    % Image are of 5-channels, namely x,y,z,intensity and range.
    im = helper.pointCloudToImage(ptcloud);
    
    % Store images and labels as .mat and .png files respectively.
    imfile = fullfile(imageDataLocation,sprintf('%04d.mat',i));
    save(imfile,'im');

    
    % Display progress after 300 files on screen.
    if ~mod(i,300)
        msg = sprintf('Preprocessing data %3.2f%% complete', (i/numFiles)*100.0);
        fprintf(1,'%s',[tmpStr, msg]);
        tmpStr = repmat(sprintf('\b'), 1, length(msg));
    end
end

% Print completion message when done.
msg = sprintf('Preprocessing data 100%% complete');
fprintf(1,'%s',[tmpStr, msg]);

end