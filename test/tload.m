classdef(SharedTestFixtures = {DownloadSalsaNextFixture}) tload < matlab.unittest.TestCase
    % Test for loading the downloaded models.
    
    % Copyright 2021 The MathWorks, Inc.
    
    % The shared test fixture DownloadSalsaNextFixture calls
    % downloadPretrainedSalsaNext. Here we check that the properties of
    % downloaded models.
    
    properties        
        DataDir = fullfile(getRepoRoot(),'model');        
    end
    
    methods(Test)
        function verifyModelAndFields(test)
            % Test point to verify the fields of the downloaded models are
            % as expected.
                                    
            loadedModel = load(fullfile(test.DataDir,'trainedSalsaNext.mat'));
            
            test.verifyClass(loadedModel.net,'DAGNetwork');
            test.verifyEqual(numel(loadedModel.net.Layers),175);
            test.verifyEqual(size(loadedModel.net.Connections),[204 2])
            test.verifyEqual(loadedModel.net.InputNames,{'Input_input.1'});
            test.verifyEqual(loadedModel.net.OutputNames,{'focalloss_out'});            
        end        
    end
end