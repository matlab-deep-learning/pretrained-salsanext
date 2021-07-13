function cmap = lidarColorMap()
% Lidar color map for the pandaset classes

% Copyright 2021 The MathWorks, Inc

cmap = [[30,30,30];      % UnClassified
        [0,255,0];       % Vegetation
        [255, 150, 255]; % Ground
        [255,0,255];     % Road
        [255,0,0];       % Road Markings
        [90, 30, 150];   % Side Walk
        [245,150,100];   % Car
        [250, 80, 100];  % Truck
        [150, 60, 30];   % Other Vehicle
        [255, 255, 0];   % Pedestrian
        [0, 200, 255];   % Road Barriers
        [170,100,150];   % Signs
        [30, 30, 255]];  % Building

cmap = cmap./255;

end