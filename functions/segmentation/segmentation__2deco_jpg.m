function varargout = segmentation__2deco_jpg(varargin)
%segmentation__2deco_jpg MATLAB code file for segmentation__2deco_jpg.fig
%      segmentation__2deco_jpg, by itself, creates a new segmentation__2deco_jpg or raises the existing
%      singleton*.
%
%      H = segmentation__2deco_jpg returns the handle to a new segmentation__2deco_jpg or the handle to
%      the existing singleton*.
%
%      segmentation__2deco_jpg('Property','Value',...) creates a new segmentation__2deco_jpg using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to segmentation__2deco_jpg_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      segmentation__2deco_jpg('CALLBACK') and segmentation__2deco_jpg('CALLBACK',hObject,...) call the
%      local function named CALLBACK in segmentation__2deco_jpg.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help segmentation__2deco_jpg

% Last Modified by GUIDE v2.5 24-Sep-2020 12:48:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @segmentation__2deco_jpg_OpeningFcn, ...
                   'gui_OutputFcn',  @segmentation__2deco_jpg_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before segmentation__2deco_jpg is made visible.
function segmentation__2deco_jpg_OpeningFcn(hObject, eventdata, handles, varargin)
   global app 
% global results
% delete(findall(findall(gcf,'Type','axe'),'Type','text'))
% set(gcf,'Name','TRACE4')
app.output=[];
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

            % Change figure icon
            change__figicon(handles.output);

guidata(hObject, handles);
    movegui(gcf,'center');

    app.temp.path = varargin{1};
    app.temp.root = varargin{2};
    app.temp.radiomicsmapping = varargin{3};
    app.temp.imtype = varargin{4};
    app.temp.data = varargin{5};
    app.temp.jpgname = varargin{6};
    
    app.temp.dx = app.temp.data.dx;
    app.temp.manuf = app.temp.data.manuf;
%     app.temp.image = dicomread(app.temp.path);%%%
    app.temp.image = app.temp.data.volume;
    app.temp.mask = zeros(size(app.temp.image));
    % Plot
    global hf
    axes(handles.slice_fig);
%     hf = imagesc(app.temp.image);
    hf = imshow(app.temp.jpgname);
    app.figura = imread(app.temp.jpgname);
    app.figura_or = app.figura;
    app.mask_pos = [];
    app.temp.clean = [];
    axis image
    axis off
    colormap gray    
    %     colorbar;
    %     caxis([zMin, zMax]);
    %     mappa='gray';
    %     imshow(app.temp.image, [], 'Parent', handles.slice_fig);
    % movegui(handles.figure1,'center');
%     global a
%     a = 1;
%     while a > 0
        drawnow();
%     end
waitfor(handles.output);
    



% --- Outputs from this function are returned to the command line.
function varargout = segmentation__2deco_jpg_OutputFcn(hObject, eventdata, handles)
global app
varargout{1} = app.output;
% varargout{2} = app.output.mask;


% --- Executes on button press in map_range.
function map_range_Callback(hObject, eventdata, handles)


% --- Executes on button press in draw_roi.
function draw_roi_Callback(hObject, eventdata, handles)
    global app
    global hf
    try
        app.temp.mask = [];
        % Re-Plot
        
        axes(handles.slice_fig);
        hf = imagesc(app.figura);
        axis image
        axis off    
    end
    app.h = drawfreehand(handles.slice_fig, 'Multiclick', 1);
    addlistener(app.h,'ROIMoved',@allevents_h);
    app.temp.mask = uint16(createMask(app.h));

    xy = app.h.Position;
    app.mask_pos = xy;


% --- Executes on button press in delete_1ROI.
function delete_1ROI_Callback(hObject, eventdata, handles)
    global app
    app.temp.mask = [];
%     app.h = [];
    % Re-Plot
%     imshow(app.temp.image, [], 'Parent', handles.slice_fig);
    global hf
    axes(handles.slice_fig);
    hf = imshow(app.temp.jpgname);
    axis image
    axis off    


    % --- Executes on button press in finito.
function finito_Callback(hObject, eventdata, handles)
    global app
    [r1,~,~] = ind2sub(size(app.temp.mask),find(app.temp.mask>0));
    % [r2,~,~] = ind2sub(size(app.mask_check),find(app.mask_check>0));
    if isempty(r1)
        mask_exist=0;
    else
        mask_exist=1;
    end
    c = [];
    if ~isempty(app.temp.clean) && mask_exist==1
        
        if size(app.temp.clean,2)~=size(app.temp.mask,2)
            app.temp.clean=app.temp.clean(:,2:end);
        end
        a = find(app.temp.mask>0);
        b = find(app.temp.clean>0);
        c = intersect(a, b);
    end
    if ~isempty(c) && mask_exist==1
        test = sprintf('Mask ROI and cleaning ROI partially overlap.\nPlease, correct one of them to avoid it.');
        msgbox(test, 'Error','error');
    else
        %find connected regions in each method
        % cc = bwconncomp(app.temp.mask,8);
        % if cc.NumObjects>1
        %     mask_exist=2;
        % end

        stats = regionprops3(app.temp.mask,'all');
        length_1 = length(stats.SubarrayIdx{1});
        length_2 = length(stats.SubarrayIdx{2});
        % length_3 = length(stats.SubarrayIdx{3})*dx(1,3);

        if length_1<6 || length_2<6   
            mask_exist=3;
        end


        if mask_exist==0
            msgbox('Mask not drawn', 'Error','error');
        elseif mask_exist==2
            msgbox('Multiple volumes drawn, please draw only 1 volume', 'Error','error');
        elseif mask_exist==3
            msgbox('Mask too small along at least one of the two axes, please enlarge', 'Error','error');
        else
        %     try
        %         manufacturer = strcat(app.temp.info.Manufacturer, ...
        %             '___', app.temp.info.ManufacturerModelName);
        %     catch
        %         try
        %             manufacturer = strcat(app.temp.info.Manufacturer, ...
        %                 '___', app.temp.info.ManufacturerModelname);
        %         catch
        %             manufacturer = 'unknown';
        %         end         
        %     end
            manufacturer = app.temp.manuf;
            if size(app.temp.image,1)<size(app.temp.mask,1)
                mask2 = app.temp.mask(size(app.temp.mask,1)-size(app.temp.image,1)+1:end,:);
                app.temp.mask = mask2;
            end
            if size(app.temp.image,2)<size(app.temp.mask,2)
                mask3 = app.temp.mask(:,1:size(app.temp.image,2));
                app.temp.mask = mask3;
            end
            if ~isempty(app.temp.clean)
                app.temp.clean2=app.temp.clean(:,2:end);
                for i=1:size(app.temp.image,3)
                    temp_figura=app.temp.image(:,:,i);
                    temp_figura(app.temp.clean2>0)=0;
                    app.temp.image(:,:,i)=temp_figura;
                end
                input.file = app.temp.path;
                input.volume = app.temp.image;
                input.info = app.temp.data.info;
                input.dx = app.temp.dx;
                input.manuf = app.temp.manuf;
                % input.dimension
                % input.data_mod 
                identify_save_file(input);
        %         dicomwrite(app.temp.image,app.temp.path,app.temp.data.info,'CreateMode', 'copy');%%%%%%%%%%%%%%%%%%%%%%%%%
                imwrite(app.figura, app.temp.jpgname);
            end
            try app.temp.image = rgb2gray(app.temp.image);
            catch
            end
            try app.temp.mask = rgb2gray(app.temp.mask);
            catch
            end
            five__percrow = round(size(app.temp.mask, 1) * 0.05);
            five__perccol = round(size(app.temp.mask, 2) * 0.05);

            [r, c] = find(app.temp.mask > 0);

            colmin = min(min(c)) - five__perccol;
            rowmin = min(min(r)) - five__percrow;
            colmax = max(max(c)) + five__perccol;
            rowmax = max(max(r)) + five__percrow;
            if colmin <= 0
                colmin = 1;
            end
            if rowmin <= 0
                rowmin = 1;
            end
            if colmax > size(app.temp.mask, 2)
                colmax = size(app.temp.mask, 2);
            end
            if rowmax > size(app.temp.mask, 1)
                rowmax = size(app.temp.mask, 1);
            end


            crop__img = double(squeeze(app.temp.image(rowmin:rowmax, colmin:colmax)));
            crop__mask = double(squeeze(app.temp.mask(rowmin:rowmax, colmin:colmax)));

            % Save img
            new__img = fullfile(mkdir__ifnotexist(fullfile(...
                app.temp.root, 'volumes')), 'vol.nii');
            H = size(crop__img, 1);
            W = size(crop__img, 2);

            % Pixel dimensions
        %     try
        %         dx = app.temp.info.ImagerPixelSpacing;
        %     catch
        %         try
        %             dx = app.temp.info.PixelSpacing;
        %         catch
        %             errordlg('Pixel dimensions not found! Please, check the input file.');
        %             dx = [1,1];%%%%%%%%%%%%%
        %         end
        %     end
            dx = app.temp.dx;
        %     crop__img=(crop__img./max(max(crop__img)))*100;
            nii = make_nii(crop__img, [dx(1) dx(2) dx(1)], [H/2 W/2 0],...
                [], manufacturer);
        %     nii = make_nii(crop__img, [dx(1) dx(2) dx(1)], [H/2 W/2 0],...
        %         512, manufacturer);
            save_nii(nii, new__img);

            % Save mask
            new__mask = fullfile(mkdir__ifnotexist(fullfile(...
                app.temp.root, 'volumes')), 'mask.nii');
            H = size(crop__mask, 1);
            W = size(crop__mask, 2);

            nii = make_nii(crop__mask, [dx(1) dx(2) dx(1)], [H/2 W/2 0],...
                [], manufacturer);
        %     nii = make_nii(crop__mask, [dx(1) dx(2) dx(1)], [H/2 W/2 0],...
        %         512, manufacturer);
            save_nii(nii, new__mask);

            app.output.vol = crop__img;
            app.output.mask = crop__mask;
            app.output.vol_path = new__img;
            app.output.mask_path = new__mask;
        %     global a
        %     a = 0;

            closereq;
        end
    end
    
% function visibility(hObject, eventdata, handles)


% % --- Executes on selection change in popupmenu1.
% function popupmenu1_Callback(hObject, eventdata, handles)
%     switch get(handles.popupmenu1,'Value')   
%       case 1
%         mappa = 'Gray';
%       case 2
%         mappa = 'Hot';
%       case 3
%         mappa = 'Jet';
%     end 
%     h__temp = figure('Visible', 'off');
%     cm__ = colormap(lower(mappa));
%     colormap(handles.slice_fig, cm__);
    

% % --- Executes during object creation, after setting all properties.
% function popupmenu1_CreateFcn(hObject, eventdata, handles)
%     if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%         set(hObject,'BackgroundColor','white');
%     end


% --- Executes during object creation, after setting all properties.
function finito_CreateFcn(hObject, eventdata, handles)
% hObject    handle to finito (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function delete_1ROI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to delete_1ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function draw_roi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to draw_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in back.
function back_Callback(hObject, eventdata, handles)
global app
out = app.temp;
closereq;
trace4bc__radiomics1(out);

function allevents_h(~,evt)
global app
evname = evt.EventName;
switch(evname)
    case{'MovingROI'}
    case{'ROIMoved'}
        app.temp.mask = uint16(createMask(evt.Source));
        xy = evt.Source.Position;
        app.mask_pos = xy;
end


% --- Executes on button press in draw_clean.
function draw_clean_Callback(hObject, eventdata, handles)
% hObject    handle to draw_clean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global app

h = drawfreehand(handles.slice_fig, 'Multiclick', 1, 'DrawingArea', 'auto');
temp_clean=uint8(createMask(h));
if ~isempty(app.temp.clean)
    tempclean1 = app.temp.clean;
    temp_clean(tempclean1>0) = max(max(temp_clean));
end
app.temp.clean = temp_clean;
for i=1:size(app.figura,3)
    temp_figura=app.figura(:,:,i);
    temp_figura(app.temp.clean>0)=0;
    app.figura(:,:,i)=temp_figura;
end
global hf
axes(handles.slice_fig);
hf = imshow(app.figura);
axis image
axis off
if ~isempty(app.mask_pos) && ~isempty(app.temp.mask)
    try xyz = app.mask_pos;
        app.h=drawfreehand(handles.slice_fig,'Position',xyz);
        addlistener(app.h,'ROIMoved',@allevents_h);
        app.mask_pos = xyz;
    catch
    end
end

% --- Executes on button press in delete_clean.
function delete_clean_Callback(hObject, eventdata, handles)
% hObject    handle to delete_clean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global app
% set(handles.testo_save, 'string','');

app.temp.clean = [];
% Re-Plot
%     imshow(app.temp.image, [], 'Parent', handles.slice_fig);
global hf
axes(handles.slice_fig);
hf = imshow(app.figura_or);
app.figura = app.figura_or;

axis image
axis off
if ~isempty(app.mask_pos) && ~isempty(app.temp.mask)
    try xyz = app.mask_pos;
        app.h=drawfreehand(handles.slice_fig,'Position',xyz);
        addlistener(app.h,'ROIMoved',@allevents_h);
        app.mask_pos = xyz;
    catch
    end
end
