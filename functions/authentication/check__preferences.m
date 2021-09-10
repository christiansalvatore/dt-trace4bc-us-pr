function [pref__check, pref__fullpath] = check__preferences(varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    p = mfilename('fullpath');
    endout = regexp(p,filesep,'split');

    if nargin > 0
        gui__handles = varargin{1};
    end

    for i=1:size(endout,2)-1
        if i==1
            pref__abspath = endout{1,1};
        else
            pref__abspath = strcat(pref__abspath,'/',endout{1,i});
        end  
    end

    % Check license
    pref__check = 0;

    env{1} = 'PROGRAMFILES';
    env{2} = 'PROGRAMFILES(x86)';
    env{3} = 'PROGRAMW6432';
    env{4} = 'PROGRAMDATA';
    env{5} = 'HOMEDRIVE';
    final__path = 'trace4/application';
    preferences = 'preferences.mat';            

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
        try
            for i = 1:size(gui__handles)
                set(gui__handles{i},'Enable','off');
            end
        end

        uiwait(msgbox('Preferences file not found!'));
        closereq;
        closereq;
    else
        % uiwait(msgbox('License found!'));
        % increase__counter(license__fullpath,'login');
    end
    
end
