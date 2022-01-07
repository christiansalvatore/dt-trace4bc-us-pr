function [license__check, license__fullpath] = check__license__local()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% 
%     p = mfilename('fullpath');
%     endout = regexp(p,filesep,'split');
% 
%     if nargin > 0
%         gui__handles = varargin{1};
%     end
% 
%     for i=1:size(endout,2)-1
%         if i==1
%             license__abspath = endout{1,1};
%         else
%             license__abspath = strcat(license__abspath,'/',endout{1,i});
%         end  
%     end
% 
    % Check license
    license__check = 0;
% 
%     env{1} = 'PROGRAMFILES';
%     env{2} = 'PROGRAMFILES(x86)';
%     env{3} = 'PROGRAMW6432';
%     env{4} = 'PROGRAMDATA';
%     env{5} = 'HOMEDRIVE';
%     final__path = 'trace4/application';

    currentDir = [getenv('HOMEDRIVE'), getenv('HOMEPATH')];
    license__abspath = fullfile(currentDir,'documents');
    license = 'DeepTraceTech_AddOns\TRACE4BUS_security\config__trace4BUS.mat';

    if license__check == 0
        root__path = license__abspath;
        try
            load(fullfile(root__path, license));
        end

        if exist('license__number','var')
            license__check = 1;
            license__fullpath = fullfile(root__path, license);
        end
    end

    if license__check == 0    
        p = mfilename('fullpath');
        endout = regexp(p,filesep,'split');

        for i=1:size(endout,2)-1
            if i==1
                license__abspath2 = endout{1,1};
            else
                license__abspath2 = strcat(license__abspath2,'/',endout{1,i});
            end  
        end
        license2 = 'config__trace4BUS.mat';            
        try
%             load(fullfile(license__abspath2, license2));
            root__path = fullfile(license__abspath,'DeepTraceTech_AddOns\TRACE4BUS_security');
            copyfile(fullfile(license__abspath2, license2), mkdir__ifnotexist(root__path));
            license__check = 1;
            license__fullpath = fullfile(root__path, license2);
        end
        
    end
    
end
