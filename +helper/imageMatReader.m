function data = imageMatReader(filename)
%imageMatReader Reads custom MAT files containing 5-channel 
%   multispectral image data.
%
%  DATA = imageMatReader(FILENAME) returns the first 5 channels of the
%  multispectral image saved in FILENAME.

% Copyright 2021 The MathWorks, Inc

    d = load(filename);
    f = fields(d);
    data = d.(f{1})(:,:,1:5);
    index = isnan(data);
    data(index) = 0;
    
    
    