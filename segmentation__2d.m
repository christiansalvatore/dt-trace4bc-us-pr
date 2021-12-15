function varargout = segmentation__2d(varargin)
%segmentation__2deco MATLAB code file for segmentation__2deco.fig
%      segmentation__2deco, by itself, creates a new segmentation__2deco or raises the existing
%      singleton*.
%
%      H = segmentation__2deco returns the handle to a new segmentation__2deco or the handle to
%      the existing singleton*.
%
%      segmentation__2deco('Property','Value',...) creates a new segmentation__2deco using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to segmentation__2deco_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      segmentation__2deco('CALLBACK') and segmentation__2deco('CALLBACK',hObject,...) call the
%      local function named CALLBACK in segmentation__2deco.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help segmentation__2deco

% Last Modified by GUIDE v2.5 22-Nov-2021 14:10:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @segmentation__2d_OpeningFcn, ...
                   'gui_OutputFcn',  @segmentation__2d_OutputFcn, ...
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


% --- Executes just before segmentation__2deco is made visible.
function segmentation__2d_OpeningFcn(hObject, eventdata, handles, varargin)
global app1
app1 = [];
% global results
% delete(findall(findall(gcf,'Type','axe'),'Type','text'))
% set(gcf,'Name','TRACE4OC')
app1.output=[];
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

            % Change figure icon
            change__figicon(handles.output);

    movegui(gcf,'center');
    
    app1.temp.path = varargin{1};
    app1.temp.root = varargin{2};
    app1.temp.data = varargin{3};
    app1.temp.info = app1.temp.data.info;
%     app1.temp.jpgname = varargin{5};
    app1.temp.dx = app1.temp.data.dx;
    app1.temp.manuf = app1.temp.data.manuf;
    app1.temp.image = app1.temp.data.volume;
%     app1.temp.info = dicominfo(app1.temp.path);
%     app1.temp.image = dicomread(app1.temp.path);
    app1.temp.mask = zeros(size(app1.temp.image));
    app1.temp.radiomicsmapp1ing = 0;
    app1.mask_pos = [];
    app1.mask_pos.Center = [];
    app1.mask_pos.SemiAxes = [];
    app1.mask_pos.RotationAngle = [];
    app1.mask_pos.Position = [];

    % Plot
    global hf
    axes(handles.slice_fig);
%     hf = imagesc(app1.temp.image);
    hf = imshow(app1.temp.image,[]);
    app1.figura = app1.temp.image;
    app1.figura_or = app1.figura;
    app1.mask_pos = [];
    app1.temp.clean = [];
    axis image
    axis off
    colormap gray    
    %     colorbar;
    %     caxis([zMin, zMax]);
    %     mapp1a='gray';
    %     imshow(app1.temp.image, [], 'Parent', handles.slice_fig);
    % movegui(handles.figure1,'center');
%     global a
%     a = 1;
%     while a > 0
        drawnow();
%     end
image_name = fullfile(mkdir__ifnotexist(fullfile(...
                app1.temp.root, 'volumes')), 'image_nomask');
                export_fig(handles.slice_fig, image_name, '-png');
waitfor(handles.output);


% --- Outputs from this function are returned to the command line.
function varargout = segmentation__2d_OutputFcn(hObject, eventdata, handles)
    global app1
    varargout{1} = app1.output;
% varargout{2} = app1.output.mask;




% --- Executes on button press in draw_roi.
function draw_roi_Callback(hObject, eventdata, handles)
    global app1
    global hf
    try
        app1.temp.mask = [];
        % Re-Plot
        
        axes(handles.slice_fig);
%         hf = imshow(app1.figura,[app1.zMin app1.zMax]);
        hf = imshow(app1.figura);
%         hf = imagesc(app1.figura);
        axis image
        axis off    
    end
    app1.h = drawfreehand(handles.slice_fig, 'FaceAlpha',0, 'Multiclick', 1, 'DrawingArea', 'auto','LineWidth',1,'Color','y');
    addlistener(app1.h,'ROIMoved',@allevents_h);
    app1.temp.mask = uint8(createMask(app1.h));
    try 
        xy.Center = [];
        xy.SemiAxes = [];
        xy.RotationAngle = [];
    end
    xy.Position = app1.h.Position;
    app1.mask_pos = xy;
    app1.mask_pos.ROI = 'free';
    set(handles.delete_roi, 'enable', 'on');
    set(handles.draw_roi, 'enable', 'off');
    set(handles.save_mask, 'enable', 'on');



% --- Executes on button press in delete_roi.
function delete_roi_Callback(hObject, eventdata, handles)
    global app1
    app1.temp.mask = [];
%     app1.h = [];
    % Re-Plot
%     imshow(app1.temp.image, [], 'Parent', handles.slice_fig);
    global hf
    axes(handles.slice_fig);
%     hf = imshow(app1.figura,[app1.zMin app1.zMax]);
    hf = imshow(app1.figura);
    axis image
    axis off
    set(handles.delete_roi, 'enable', 'off');
    set(handles.draw_roi, 'enable', 'on');
    set(handles.save_mask, 'enable', 'off');

% --- Executes on button press in save_mask.
function save_mask_Callback(hObject, eventdata, handles)
% hObject    handle to save_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global app1


app1.h.InteractionsAllowed = 'none';
if ~isempty(app1.temp.mask)
    cc = bwconncomp(app1.temp.mask,8);
    if cc.NumObjects > 1
        msgbox('More than 1 ROI drawn. Please modify it avoiding too narrow areas or crossed lines.','Warning','warn');
        app1.h.InteractionsAllowed = 'all';
    else
        [row,col] = ind2sub(size(app1.temp.mask),cc.PixelIdxList{1,1});
        min_range = min(max(row)-min(row)+1,max(col)-min(col)+1);
        if min_range < 10
            msgbox('ROI is too small. Please expand it.','Warning','warn');
            app1.h.InteractionsAllowed = 'all';
        else
            
            c = [];

            if ~isempty(c)
                test = sprintf('Mask ROI and cleaning ROI partially overlap.\nPlease, correct one of them to avoid it.');
                msgbox(test, 'Error','error');
            else
%                 [~,name,ext] = fileparts(app1.File_Name);
%                 if strcmp(ext,'.dcm')
%                 else
%                     name = strcat(name,ext);
%                 end
%                 app1.sbj_name = name;
%                 % SAVE MASK BIG AS DICOM
%                 mask_name = fullfile(mkdir__ifnotexist(fullfile(...
%                     app1.Path_Name, 'new_mask')), strcat(app1.sbj_name,'_mask.dcm'));
%                 
%                 lista_fatti = dir(fullfile(mkdir__ifnotexist(fullfile(...
%                     app1.Path_Name, 'new_mask')), strcat(app1.sbj_name,'*')));
%                 
%                 if ~isempty(lista_fatti)
%                     mask_name = fullfile(mkdir__ifnotexist(fullfile(...
%                     app1.Path_Name, 'new_mask')), strcat(app1.sbj_name,'_mask(',num2str(length(lista_fatti)),').dcm'));
%                 end
%                 
                app1.temp.mask2 = app1.temp.mask;
                if size(app1.temp.image,1)<size(app1.temp.mask2,1)
                    mask2 = app1.temp.mask2(size(app1.temp.mask2,1)-size(app1.temp.image,1)+1:end,:);
                    app1.temp.mask2 = mask2;
                end
                if size(app1.temp.image,2)<size(app1.temp.mask2,2)
                    mask3 = app1.temp.mask2(:,1:size(app1.temp.image,2));
                    app1.temp.mask2 = mask3;
                end
                if size(app1.temp.image,1)>size(app1.temp.mask2,1)
                    app1.temp.mask2(end+1:end+size(app1.temp.image,1)-size(app1.temp.mask2,1)+1,:) = 0;
                end
                if size(app1.temp.image,2)>size(app1.temp.mask2,2)
                    app1.temp.mask2(:,end+1:end+size(app1.temp.image,2)-size(app1.temp.mask2,2)+1) = 0;
                end
                app1.temp.mask2=bwmorph(app1.temp.mask2,'bridge');
%                 temp_debt = app1.info.BitDepth;
                app1.info.BitDepth = 8;
                app1.temp.mask2(app1.temp.mask2>0) = 1;
                app1.temp.mask2 = uint8(app1.temp.mask2);
                
                mask_name = fullfile(mkdir__ifnotexist(fullfile(...
                app1.temp.root, 'volumes')), 'mask.dcm');
                dicomwrite(app1.temp.mask2,mask_name,app1.temp.info,'CreateMode', 'copy');
                image_name = fullfile(mkdir__ifnotexist(fullfile(...
                app1.temp.root, 'volumes')), 'image_mask');
                export_fig(handles.slice_fig, image_name, '-png');
                app1.output = app1.temp.mask2;
                
                
                
                closereq;

                
%                 % SHOW REFERENCE
%                 axes(handles.slice_fig);
%                 imshow(app1.temp.image);
%                 
%                 try 
%                     [row,col]=find(app1.maskref);
%                     contoura = bwtraceboundary(app1.maskref,[row(1), col(1)],'W');
%                     
%                     [row,col]=find(app1.temp.mask2);
%                     contourb = bwtraceboundary(app1.temp.mask2,[row(1), col(1)],'W');
%                     
%                     hold on
%                     plot(contoura(:,2),contoura(:,1),'g','LineWidth',1)
%                     plot(contourb(:,2),contourb(:,1),'y','LineWidth',1)
%                     hold off
%                 catch
%                 end


%                 set(handles.draw_roi, 'enable', 'off');
%                 set(handles.draw_clean, 'enable', 'off');
%                 set(handles.delete_roi, 'enable', 'off');
%                 set(handles.delete_clean, 'enable', 'off');
%                 set(handles.min_intensity, 'enable', 'off');
%                 set(handles.max_intensity, 'enable', 'off');
%                 set(handles.save_mask, 'enable', 'off');
%                 set(handles.next, 'enable', 'on');
%                 set(handles.load_file, 'enable', 'on');
%                 set(handles.up_folder, 'enable', 'on');
%                 waitfor(msgbox('Segmentation completed','No other files','help'));
%                 if strcmp(handles.next.Enable,'off')
%                     waitfor(msgbox('Segmentation completed.','Success','help'));
% %                     cla(handles.slice_fig)
%                 else
% %                     waitfor(msgbox('Segmentation completed. Click "OK" to show next dicom image.','Success','help'));
% %                     next_Callback(hObject, eventdata, handles);
%                     set(handles.text10, 'visible', 'on');
% %                     waitfor(msgbox('Segmentation completed. The outline of your ROI is in YELLOW, while the outline of the reference ROI is in GREEN. Click "Show next dicom" to show next dicom image from the selected folder.','Success','help'));
%                     set(handles.next2, 'enable', 'on');
%                     set(handles.next2, 'visible', 'on');
% %                     next_Callback(hObject, eventdata, handles);
%                 end
            end
        end
    end
else
    errordlg('no mask to save, please click "Draw ROI".');
end
try app1.h.InteractionsAllowed = 'all';
catch
end





% --- Executes during object creation, after setting all properties.
function save_mask_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function delete_roi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to delete_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function draw_roi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to draw_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function allevents_h(~,evt)
    global app1
    evname = evt.EventName;
    switch(evname)
        case{'MovingROI'}
        case{'ROIMoved'}
            app1.temp.mask = uint8(createMask(evt.Source));
            if isempty(app1.mask_pos.Center)
                xy.Position = evt.Source.Position;
            else
                xy.Center = evt.Source.Center;
                xy.SemiAxes = evt.Source.SemiAxes;
                xy.RotationAngle = evt.Source.RotationAngle;
            end
            app1.mask_pos = xy;
    end


% --- Executes during object creation, after setting all properties.
function min_intensity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min_intensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function max_intensity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_intensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
