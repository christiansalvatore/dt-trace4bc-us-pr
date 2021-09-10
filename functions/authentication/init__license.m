function init__license()
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    
    if ~isdeployed
        load('config__trace4BUS.mat','counter');
    
        counter = [];
        counter.global = 0;
        counter.login = 0;

%         counter.bc.segrad__automatic = 0;
%         counter.bc.segrad__manual = 0;
%         counter.bc.trainmodel = 0;
%         counter.bc.testmodel = 0;
    
        date__ = [];
        
        save('config__trace4BUS.mat','counter','date__','-append');
    end

end

