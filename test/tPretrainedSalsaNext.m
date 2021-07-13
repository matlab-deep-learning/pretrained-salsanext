classdef(SharedTestFixtures = {DownloadSalsaNextFixture}) tPretrainedSalsaNext < matlab.unittest.TestCase
    % Test for tPretrainedSalsaNext
    
    % Copyright 2021 The MathWorks, Inc.
    
    % The shared test fixture downloads the model. Here we check the
    % inference on the pretrained model.
    properties        
        RepoRoot = getRepoRoot;
        ModelName = 'trainedSalsaNext.mat';
    end
    
    methods(Test)
        function exerciseDetection(test)            
            model = load(fullfile(test.RepoRoot,'model',test.ModelName));
            ptCloud = pcread(fullfile(test.RepoRoot,'pointclouds','Input1.pcd'));
            img = helper.pointCloudToImage(ptCloud);
            
            imSize = size(img);
            imSize = imSize(:,1:2);
            actualLabel1Count = 48420;
            actualLabel2Count = 11990;
            
            result = semanticseg(img, model.net);            
            labelsCountTbl = countlabels(result(:));
            labelCount = labelsCountTbl.Count(find(labelsCountTbl.Count));
            
            % verifying size of output from semanticseg.
            test.verifyEqual(size(result),imSize);
            % verifying that all the pixels are labelled.
            test.verifyEqual(sum(labelCount),prod(imSize));
            % verifying the count of each labels on the result.
            test.verifyEqual(labelCount(1),actualLabel1Count);            
            test.verifyEqual(labelCount(2),actualLabel2Count);
        end       
    end
end