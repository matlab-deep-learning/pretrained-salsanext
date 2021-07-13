function image = pointCloudToImage(ptcloud)
% pointCloudToImage Converts organized 3-D point cloud to 5-channel 
% 2-D image.
%
% Copyright 2021 The MathWorks, Inc.

image = ptcloud.Location;
image(:,:,4) = ptcloud.Intensity;
rangeData = iComputeRangeData(image(:,:,1),image(:,:,2),image(:,:,3));
image(:,:,5) = rangeData;
index = isnan(image);
image(index) = 0;
end

%--------------------------------------------------------------------------
function rangeData = iComputeRangeData(xChannel,yChannel,zChannel)
rangeData = sqrt(xChannel.*xChannel+yChannel.*yChannel+zChannel.*zChannel);
end
