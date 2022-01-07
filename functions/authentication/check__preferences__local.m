function [pref__check, pref__fullpath] = check__preferences__local()
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
%             pref__abspath = endout{1,1};
%         else
%             pref__abspath = strcat(pref__abspath,'/',endout{1,i});
%         end  
%     end

    % Check license
    pref__check = 0;

    currentDir = [getenv('HOMEDRIVE'), getenv('HOMEPATH')];
    pref__abspath = fullfile(currentDir,'documents');
    preferences = 'DeepTraceTech_AddOns\TRACE4BUS_security\preferences.mat';

    if pref__check == 0
        root__path = pref__abspath;
        try
            load(fullfile(root__path, preferences));
        end

        if exist('check__pref','var')
            pref__check = 1;
            pref__fullpath = fullfile(root__path, preferences);
        end
    end

    if pref__check == 0    
        p = mfilename('fullpath');
        endout = regexp(p,filesep,'split');

        for i=1:size(endout,2)-1
            if i==1
                pref__abspath2 = endout{1,1};
            else
                pref__abspath2 = strcat(pref__abspath2,'/',endout{1,i});
            end  
        end
        preferences2 = 'preferences.mat';            
        try
%             load(fullfile(license__abspath2, license2));
            root__path = fullfile(pref__abspath,'DeepTraceTech_AddOns\TRACE4BUS_security');
            copyfile(fullfile(pref__abspath2, preferences2), mkdir__ifnotexist(root__path));
            pref__check = 1;
            pref__fullpath = fullfile(root__path, preferences2);
        end
        
    end
    
end
