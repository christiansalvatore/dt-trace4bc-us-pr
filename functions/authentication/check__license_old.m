function [license__check, license__fullpath] = check__license(varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    p = mfilename('fullpath');
    endout = regexp(p,filesep,'split');

    if nargin > 0
        gui__handles = varargin{1};
    end

    for i=1:size(endout,2)-1
        if i==1
            license__abspath=endout{1,1};
        else
            license__abspath = strcat(license__abspath,'/',endout{1,i});
        end  
    end

    % Check license
    license__check = 0;

    env{1} = 'PROGRAMFILES';
    env{2} = 'PROGRAMFILES(x86)';
    env{3} = 'PROGRAMW6432';
    env{4} = 'PROGRAMDATA';
    env{5} = 'HOMEDRIVE';
    final__path = 'trace4OC/application';
    license = 'config__trace4OC.mat';            

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

%     if license__check == 0
%         root__path = 'C:\Program Files\DeepTraceTech\TRACE4\application';
%         files = dir(fullfile(root__path,'**',license));
%         try
%             load(fullfile(files(1).folder,files(1).name));
%         end
% 
%         if exist('license__number','var')
%             license__check = 1;
%         end
%     end
% 
%     if license__check == 0
%         size__ = size(env,2);
%         for i = 1:size__
%             root__path = getenv(env{1});
%             try
%                 files = dir(fullfile(root__path,'**',final__path,license));
%             end
%             if exist('license__number','var')
%                 license__check = 1;
%             end
% 
%             env = env(2:end);
%         end
%     end
    
    if license__check == 0    
        try
            for i = 1:size(gui__handles)
                set(gui__handles{i},'Enable','off');
            end
        end

        uiwait(msgbox('License not found!'));
        closereq;
        closereq;
    else
        % uiwait(msgbox('License found!'));
        % increase__counter(license__fullpath,'login');
    end
    
end
