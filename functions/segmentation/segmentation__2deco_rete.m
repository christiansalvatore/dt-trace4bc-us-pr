function varargout = segmentation__2deco_rete(varargin)
%segmentation__2deco_rete MATLAB code file for segmentation__2deco_rete.fig
%      segmentation__2deco_rete, by itself, creates a new segmentation__2deco_rete or raises the existing
%      singleton*.
%
%      H = segmentation__2deco_rete returns the handle to a new segmentation__2deco_rete or the handle to
%      the existing singleton*.
%
%      segmentation__2deco_rete('Property','Value',...) creates a new segmentation__2deco_rete using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to segmentation__2deco_rete_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      segmentation__2deco_rete('CALLBACK') and segmentation__2deco_rete('CALLBACK',hObject,...) call the
%      local function named CALLBACK in segmentation__2deco_rete.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help segmentation__2deco_rete

% Last Modified by GUIDE v2.5 25-Mar-2021 09:32:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @segmentation__2deco_rete_OpeningFcn, ...
                   'gui_OutputFcn',  @segmentation__2deco_rete_OutputFcn, ...
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


% --- Executes just before segmentation__2deco_rete is made visible.
function segmentation__2deco_rete_OpeningFcn(hObject, eventdata, handles, varargin)
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
%     app.temp.jpgname = varargin{5};
    app.temp.dx = app.temp.data.dx;
    app.temp.manuf = app.temp.data.manuf;
    app.temp.image = app.temp.data.volume;
%     app.temp.info = dicominfo(app.temp.path);
%     app.temp.image = dicomread(app.temp.path);
    app.temp.mask = zeros(size(app.temp.image));
    % Plot
    global hf
    axes(handles.slice_fig);
%     hf = imagesc(app.temp.image);
    hf = imshow(app.temp.image,[]);
    app.figura = app.temp.image;
    app.figura_or = app.figura;
    app.mask_pos = [];
    app.temp.clean = [];
    app.roi_length = 224;
    if app.roi_length>min(size(app.temp.image))
        app.roi_length=min(size(app.temp.image));
        test = sprintf('Warning!\nSelected image is very small.');
        msgbox(test, 'Warning','warn');
    end
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
function varargout = segmentation__2deco_rete_OutputFcn(hObject, eventdata, handles)
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

% --- Executes on button press in draw_square.
function draw_square_Callback(hObject, eventdata, handles)
% hObject    handle to draw_square (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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
h = drawrectangle(handles.slice_fig,'AspectRatio',1,'FixedAspectRatio',1);
if h.Position(3)<5 || h.Position(4)<5
    h.Position
    corner = h.Position(1:2)-round(app.roi_length./2);
    
    if corner(1)+app.roi_length>size(app.temp.image,2)
        corner(1) = corner(1)-(corner(1)+app.roi_length-size(app.temp.image,2));
    end
    if corner(2)+app.roi_length>size(app.temp.image,1)
        corner(2) = corner(2)-(corner(2)+app.roi_length-size(app.temp.image,1));
    end
    if corner(1)<0
        corner(1) = 1;
    end
    if corner(2)<0
        corner(2) = 1;
    end
    position = [corner, app.roi_length, app.roi_length];
    delete(h)
    app.h = drawrectangle(handles.slice_fig,'Position',position,'AspectRatio',1,'FixedAspectRatio',1);
else
    position = h.Position;
    delete(h)
    app.h = drawrectangle(handles.slice_fig,'Position',position,'AspectRatio',1,'FixedAspectRatio',1);
end
addlistener(app.h,'ROIMoved',@allevents_h);
app.temp.mask = uint16(createMask(app.h));

xy = app.h.Position;
app.mask_pos = xy;
pause(0.01)
    

% --- Executes on button press in delete_1ROI.
function delete_1ROI_Callback(hObject, eventdata, handles)
    global app
    app.temp.mask = [];
%     app.h = [];
    % Re-Plot
%     imshow(app.temp.image, [], 'Parent', handles.slice_fig);
    global hf
    axes(handles.slice_fig);
    hf = imshow(app.temp.image,[]);
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

        if length_1<100 || length_2<100   
            mask_exist=3;
        end


        if mask_exist==0
            msgbox('Mask not drawn', 'Error','error');
        elseif mask_exist==2
            msgbox('Multiple volumes drawn, please draw only 1 volume', 'Error','error');
        elseif mask_exist==3
            msgbox('Mask too small along at least one of the two axes, please enlarge', 'Error','error');
        else
            if size(app.temp.image,1)<size(app.temp.mask,1)
                mask2 = app.temp.mask(size(app.temp.mask,1)-size(app.temp.image,1)+1:end,:);
                app.temp.mask = mask2;
            end
            if size(app.temp.image,2)<size(app.temp.mask,2)
                mask3 = app.temp.mask(:,1:size(app.temp.image,2));
                app.temp.mask = mask3;
            end
%             if ~isempty(app.temp.clean)
%                 app.temp.clean2=app.temp.clean(:,2:end);
%                 for i=1:size(app.temp.image,3)
%                     temp_figura=app.temp.image(:,:,i);
%                     temp_figura(app.temp.clean2>0)=0;
%                     app.temp.image(:,:,i)=temp_figura;
%                 end
%                 input.file = app.temp.path;
%                 input.volume = app.temp.image;
%                 input.info = app.temp.data.info;
%                 input.dx = app.temp.dx;
%                 input.manuf = app.temp.manuf;
%                 % input.dimension
%                 % input.data_mod 
%                 identify_save_file(input);
%         %         dicomwrite(app.temp.image,app.temp.path,app.temp.info,'CreateMode', 'copy');%%%%%%%%%%%%%%%
%         %         imwrite(app.figura, app.temp.jpgname);
%             end
%             try app.temp.image = rgb2gray(app.temp.image);
            try app.temp.image = rgb2gray(app.figura);
            catch
            end
            try app.temp.mask = rgb2gray(app.temp.mask);
            catch
            end
%             five__percrow = round(size(app.temp.mask, 1) * 0.01);
%             five__perccol = round(size(app.temp.mask, 2) * 0.01);
% 
            [r, c] = find(app.temp.mask > 0);
            if length_1 == length_2 && length(r)==length_1*length_1
                square_mask = 1;
                %maschera quadrata.. ritaglia e salva
                colmin = min(c);
                colmax = max(c);
                rowmin = min(r);
                rowmax = max(r);
            else
                square_mask = 0;
%                 five__percrow = round(size(app.temp.mask, 1) * 0.01);
                %maschera non quadrata
                medium_row = min(r) + round((max(r) - min(r))./2);
                medium_col = min(c) + round((max(c) - min(c))./2);
                new_length = max(length_1,length_2);
                rowmin = medium_row - round(new_length./2) + 1;
                rowmax = medium_row + round(new_length./2);
                colmin = medium_col - round(new_length./2) + 1;
                colmax = medium_col + round(new_length./2);
                if colmin <= 0
                    colmax = colmax-colmin+1;
                    colmin = 1;
                end
                if rowmin <= 0
                    rowmax = rowmax-rowmin+1;
                    rowmin = 1;
                end
                if colmax > size(app.temp.mask, 2)
                    colmin = colmin+(size(app.temp.mask, 2)-colmax);
                    colmax = size(app.temp.mask, 2);
                end
                if rowmax > size(app.temp.mask, 1)
                    rowmin = rowmin+(size(app.temp.mask, 1)-rowmax);
                    rowmax = size(app.temp.mask, 1);
                end
            end
            crop__img = double(squeeze(app.temp.image(rowmin:rowmax, colmin:colmax)));
            crop__mask = double(squeeze(app.temp.mask(rowmin:rowmax, colmin:colmax)));
            
            if square_mask == 0
                crop__img2 = crop__img;
                crop__img2(crop__mask==0) = 0;
                tipo = class(app.temp.image);
                [crop__img2, ~] = chance_datatype(crop__img2,tipo);
            end
            
            tipo = class(app.temp.image);
            [crop__img, ~] = chance_datatype(crop__img,tipo);

            % Save img
            
            [~,name,~] = fileparts(app.temp.path);
            name1 = strcat(name,'_vol.jpg');
            new__img = fullfile(mkdir__ifnotexist(fullfile(...
                app.temp.root, 'volumes')), name1);
            
            if square_mask == 0
                name2 = strcat(name,'_masked_vol.jpg');
                new__img_masked = fullfile(mkdir__ifnotexist(fullfile(...
                    app.temp.root, 'volumes')), name2);
                imwrite(crop__img2,new__img_masked);
            end
            
            try imwrite(crop__img,new__img);
            catch
                crop__img=im2uint8(crop__img);
                imwrite(crop__img,new__img);
            end

            app.output.vol = crop__img;
            app.output.mask = crop__mask;

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
hf = imshow(app.figura,[]);
axis image
axis off
if ~isempty(app.mask_pos) && ~isempty(app.temp.mask)
    try xyz = app.mask_pos;
        app.h=drawfreehand(handles.slice_fig,'Position',xyz);
        addlistener(app.h,'ROIMoved',@allevents_h);
        app.mask_pos = xyz;
    catch
        try xyz = app.mask_pos;
            app.h = drawrectangle(handles.slice_fig,'Position',xyz,'AspectRatio',1,'FixedAspectRatio',1);
            addlistener(app.h,'ROIMoved',@allevents_h);
            app.mask_pos = xyz;
        catch
        end
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
hf = imshow(app.figura_or,[]);
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





