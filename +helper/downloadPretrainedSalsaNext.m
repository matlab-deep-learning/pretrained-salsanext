function model = downloadPretrainedSalsaNext()

% The downloadPretrainedSalsaNext function downloads a SalsaNext network 
% pretrained on Pandaset dataset.
%
% Copyright 2021 The MathWorks, Inc.

dataPath = 'model';
modelName = 'SalsNext';
netFileFullPath = fullfile(dataPath,modelName);

% Add '.mat' extension to the data.
netFileFull = [netFileFullPath,'.zip'];

if ~exist(netFileFull,'file')
    fprintf(['Downloading pretrained', modelName ,'network.\n']);
    fprintf('This can take several minutes to download...\n');
    url = 'https://ssd.mathworks.com/supportfiles/lidar/data/trainedSalsaNextPandasetNet.zip';
    websave (netFileFullPath,url);
    unzip(netFileFullPath, dataPath);
    model = load([dataPath, '/trainedSalsaNext.mat']);
else
    fprintf('Pretrained SalsaNext network already exists.\n\n');
    unzip(netFileFullPath, dataPath);
    model = load(fullfile(dataPath, 'trainedSalsaNext.mat'));
end

end
