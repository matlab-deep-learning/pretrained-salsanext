classdef(SharedTestFixtures = {DownloadSalsaNextFixture}) tdownloadPretrainedSalsaNext < matlab.unittest.TestCase
    % Test for downloadPretrainedSalsaNext
    
    % Copyright 2021 The MathWorks, Inc.
    
    % The shared test fixture DownloadSalsaNextFixture calls
    % downloadPretrainedSalsaNext. Here we check that the downloaded files
    % exists in the appropriate location.
    
    properties        
        DataDir = fullfile(getRepoRoot(),'model');
    end
    
    methods(Test)
        function verifyDownloadedFilesExist(test)
            dataFileName = 'trainedSalsaNext.mat';
            test.verifyTrue(isequal(exist(fullfile(test.DataDir,dataFileName),'file'),2));
        end
    end
end