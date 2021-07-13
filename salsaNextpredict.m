function out = salsaNextpredict(in)
%#codegen
% Copyright 2021 The MathWorks, Inc.

persistent salsaNextObj;

if isempty(salsaNextObj)
    salsaNextObj = coder.loadDeepLearningNetwork('model/trainedSalsaNext.mat');
end

% Pass input.
out = predict(salsaNextObj,in);

end