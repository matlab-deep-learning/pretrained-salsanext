classdef DownloadSalsaNextFixture < matlab.unittest.fixtures.Fixture
    % DownloadSalsaNextFixture   A fixture for calling
    % downloadPretrainedSalsaNext if necessary. This is to ensure that this
    % function is only called once and only when tests need it. It also
    % provides a teardown to return the test environment to the expected
    % state before testing.
    
    % Copyright 2021 The MathWorks, Inc
    
    properties(Constant)
        SalsaNextDataDir = fullfile(getRepoRoot(),'model')
    end
    
    properties
        SalsaNextExist (1,1) logical        
    end
    
    methods
        function setup(this)            
            this.SalsaNextExist = exist(fullfile(this.SalsaNextDataDir,'trainedSalsaNext.mat'),'file')==2;
            
            % Call this in eval to capture and drop any standard output
            % that we don't want polluting the test logs.
            if ~this.SalsaNextExist
            	evalc('helper.downloadPretrainedSalsaNext();');
            end       
        end
        
        function teardown(this)
            if this.SalsaNextExist
                delete(fullfile(this.SalsaNextDataDir,'trainedSalsaNext.mat'));
            end            
        end
    end
end