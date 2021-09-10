function change__figicon(fig__handle)

    try
        
        p = mfilename('fullpath');
        endout = regexp(p, filesep, 'split');

        for i = 1:size(endout,2)-3
            if i == 1
                path_exe = endout{1,1};
            else
                path_exe = strcat(path_exe, '/' ,endout{1,i});
            end  
        end        
        
        uifig = getWebWindowOfUiFigure(fig__handle);
        icon__path = fullfile(path_exe, 'images\icons\icon.ico');
        warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
        uifig.Icon = icon__path;
        
    end

end

function webWindow = getWebWindowOfUiFigure(fig)

    % returns the underlaying webwindow of the given figure handle in case of an uifigure, otherwise it returns an empty
    % webwindow array
    %
    %%Example
    %{
    % standard Java based Matlab figure -> no webwindow is returned
    fig = figure
    ww = getWebWindowOfUiFigure(fig);
    assert(isempty(ww))
    
    % Web based Matlab figure (uifigure) -> webwindow is returned
    figWeb = uifigure
    ww = getWebWindowOfUiFigure(figWeb);
    assert(numel(ww) == 1)
    
    % change the figures icon
    ww.Icon     % returns the current path of the icon
    % set a new icon; on Windows systems it must be an .ico file
    ww.Icon = fullfile(matlabroot, '\toolbox\matlab\icons\file_open.png')
    ww.Icon = fullfile(matlabroot, '\toolbox\matlab\icons\webicon.gif')
    % "C:\MATLAB\R2019b\toolbox\compiler\Resources\default_icon.ico"
    ww.Icon = fullfile(matlabroot, '\toolbox\matlab\toolstrip\web\image\uicontainer.ico')
    
    %}
    figNameOrig = fig.Name;                   % original figure name
    figNameTemp = [fig.Name, tempname('$')];  % creaet a unique temporary figure name (in case of multiple figures with the same name exists
    fig.Name = figNameTemp;     % rename the figure in case of multiple figures with the same name exists
    drawnow
    ww = matlab.internal.webwindowmanager.instance.findAllWebwindows();
    webWindow = matlab.internal.webwindow.empty();
    for ii = 1:numel(ww)
        if strcmp(ww(ii).Title, figNameTemp)
            webWindow = ww(ii);
            break;
        end
    end
    fig.Name = figNameOrig;     % restore orignal figure name
    
end

