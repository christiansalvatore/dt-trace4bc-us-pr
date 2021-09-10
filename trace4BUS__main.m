function varargout = trace4BUS__main(varargin)
% trace4BUS__main MATLAB code for trace4BUS__main.fig
%      trace4BUS__main, by itself, creates a new trace4BUS__main or raises the existing
%      singleton*.
%
%      H = trace4BUS__main returns the handle to a new trace4BUS__main or the handle to
%      the existing singleton*.
%
%      trace4BUS__main('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in trace4BUS__main.M with the given input arguments.
%
%      trace4BUS__main('Property','Value',...) creates a new trace4BUS__main or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before trace4BUS__main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to trace4BUS__main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help trace4BUS__main

% Last Modified by GUIDE v2.5 10-Sep-2021 14:04:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @trace4BUS__main_OpeningFcn, ...
                   'gui_OutputFcn',  @trace4BUS__main_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before trace4BUS__main is made visible.
function trace4BUS__main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to trace4BUS__main (see VARARGIN)

% Choose default command line output for trace4BUS__main
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
global app



input = varargin{1};
app.img__type = 'us';
app.buttons_on = input.buttons_on;
app.pathology = 'bc';
app.username = input.username;
app.password = input.password;
app.modello = input.modello;
app.h = [];
app.Path_Name = [];
m1 = uimenu('Text','Documentation');
mitem1 = uimenu(m1,'Text','Technical Sheet');
mitem1.MenuSelectedFcn = @TSSelected;

mitem2 = uimenu(m1,'Text','USI Protocol');
mitem2.MenuSelectedFcn = @UPSelected;

mitem3 = uimenu(m1,'Text','User Manual');
mitem3.MenuSelectedFcn = @UMSelected;

m2 = uimenu('Text','User');
m2item1 = uimenu(m2,'Text','Change Password');
m2item1.MenuSelectedFcn = @CPSelected;
m2item2 = uimenu(m2,'Text','Logout');
m2item2.MenuSelectedFcn = @logoutmenu;


% UIWAIT makes trace4BUS__main wait for user response (see UIRESUME)
% uiwait(handles.figure1);
function TSSelected(src,event)
if isdeployed
p = mfilename('fullpath');
endout = regexp(p, filesep, 'split');
for i = 1:size(endout,2)-1
    if i == 1
        path_exe = endout{1,1};
    else
        path_exe = strcat(path_exe, '/' ,endout{1,i});
    end  
end
path_pdf = fullfile(path_exe, 'docs', 'TRACE4BUS__Technical_Sheet_en-it.pdf');
system(['start "TRACE4BUS | Technical Sheet" ','"', path_pdf,'"']);
else
system(['start "TRACE4BUS | Technical Sheet" ','"', 'docs/TRACE4BUS__Technical_Sheet_en-it.pdf','"']);
end

function UPSelected(src,event)
if isdeployed
p = mfilename('fullpath');
endout = regexp(p, filesep, 'split');
for i = 1:size(endout,2)-1
    if i == 1
        path_exe = endout{1,1};
    else
        path_exe = strcat(path_exe, '/' ,endout{1,i});
    end  
end
path_pdf = fullfile(path_exe, 'docs', 'TRACE4BUS__USI_protocol_en-it.pdf');
system(['start "TRACE4BUS | USI protocol" ','"', path_pdf,'"']);
else
system(['start "TRACE4BUS | USI protocol" ','"', 'docs/TRACE4BUS__USI_protocol_en-it.pdf','"']);
end
        
function UMSelected(src,event)
if isdeployed
p = mfilename('fullpath');
endout = regexp(p, filesep, 'split');
for i = 1:size(endout,2)-1
    if i == 1
        path_exe = endout{1,1};
    else
        path_exe = strcat(path_exe, '/' ,endout{1,i});
    end  
end
path_pdf = fullfile(path_exe, 'docs', 'TRACE4BUS__User_manual_en-it.pdf');
system(['start "TRACE4BUS | User Manual" ','"', path_pdf,'"']);
else
system(['start "TRACE4BUS | User Manual" ','"', 'docs/TRACE4BUS__User_manual_en-it.pdf','"']);
end
        
% function CPSelected(src,event)
%         file = uigetfile('*.txt');
        
        
        
% --- Outputs from this function are returned to the command line.
function varargout = trace4BUS__main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% global app
% handles.output = app.modello;
varargout{1} = handles.output;


% --- Executes on button press in upload_fig.
function upload_fig_Callback(hObject, eventdata, handles)
% hObject    handle to upload_fig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global app
global hf
app.counter = 1;
app.h = [];
app.second = 0;
set(handles.next,'enable', 'off');
set(handles.draw_roi, 'enable', 'off');
set(handles.delete_roi, 'enable', 'off');
set(handles.save_mask, 'enable', 'off');
set(handles.save_mask, 'visible','on');
set(handles.view_report, 'visible','off');

try if ~isnumeric(app.Path_Name)
        [app.File_Name, app.Path_Name] = uigetfile(fullfile(app.Path_Name,'*.*'));
    else
        [app.File_Name, app.Path_Name] = uigetfile('*');
    end
catch
    [app.File_Name, app.Path_Name] = uigetfile('*');
end
set(handles.testo_save, 'string','');
app.upload=0;
if app.File_Name ~= 0
    try dicominfo(fullfile(app.Path_Name,app.File_Name));
        app.upload=1;
    catch
        app.upload=2;
    end
end

if app.upload==1
    [filepath,name,ext] = fileparts(app.File_Name);
    if strcmp(ext,'.dcm')
    else
        name = strcat(name,ext);
    end
    app.sbj_name = name;
    app.testo = '';
    app.info=dicominfo(fullfile(app.Path_Name,app.File_Name));

    app.dicm_fig = dicomread(fullfile(app.Path_Name,app.File_Name));
    app.dicm_fig = squeeze(app.dicm_fig);
    if max(max(max(app.dicm_fig)))==255
        app.dicm_fig = uint8(app.dicm_fig);
    end
    try 
        app.dicm_fig = rgb2gray(app.dicm_fig);
    catch
    end
        
    axes(handles.axes1)
    hf = imshow(app.dicm_fig,[]);
    app.temp.mask = [];
    app.temp.clean = [];
    app.h = [];
    axis image
    axis off
    
    app.answer1 = question1;
    app.answer2 = question2;
    
    switch app.answer1
    case 'Yes'
        switch app.answer2
            case 'Yes' % 0% di malignancy with second opinion
                app.second = 1;
                set(handles.testo_save, 'string','Please, press "Draw Mask ROI" and segment the lesion.');
                set(handles.draw_roi, 'enable', 'on');
%                 set(handles.delete_roi, 'enable', 'on');
            case 'No' % 0% di malignancy without second opinion
                app.second = 0;
                app.testo = 'Breast lesion with 0% likelihood of malignancy.';
                set(handles.testo_save, 'string',app.testo);
                set(handles.draw_roi, 'enable', 'off');
                set(handles.delete_roi, 'enable', 'off');
                app.pdf__path = trace4bus__testreport(app.testo,app.sbj_name,app.Path_Name,app.second);
        end
    case 'No'
        switch app.answer2
            case 'Yes' % >0% di malignancy with second opinion
                app.second = 1;
                set(handles.testo_save, 'string','Please, press "Draw Mask ROI" and segment the lesion.');
                set(handles.draw_roi, 'enable', 'on');
%                 set(handles.delete_roi, 'enable', 'on');
            case 'No' % >0% di malignancy without second opinion
                app.second = 0;
                app.testo = 'Breast lesion with >0% likelihood of malignancy.';
                set(handles.testo_save, 'string', app.testo);
                set(handles.draw_roi, 'enable', 'off');
                set(handles.delete_roi, 'enable', 'off');
                app.pdf__path = trace4bus__testreport(app.testo,app.sbj_name,app.Path_Name,app.second);
        end
    end

elseif app.upload==2
    set(handles.testo_save, 'string','Wrong file format. Only dicom files are supported.');
    set(handles.draw_roi, 'enable', 'off');
    set(handles.delete_roi, 'enable', 'off');
end

function answer = question1()
    
    answer = questdlg('Breast lesion with 0% likelihood of malignancy?', ...
	'Likelihood of malignancy', ...
	'Yes','No','No');

function answer = question2()
    
    answer = questdlg('Do you need a second opinion?', ...
	'Second opinion', ...
	'Yes','No','No'); 

% --- Executes on button press in draw_roi.
function draw_roi_Callback(hObject, eventdata, handles)
% hObject    handle to draw_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global app
global hf
set(handles.testo_save, 'string','');
app.temp.mask = [];
app.temp.clean = [];
app.h = [];
axes(handles.axes1)
hf = imshow(app.dicm_fig,[]);
axis image
axis off
app.h = drawfreehand(handles.axes1, 'Multiclick', 1, 'DrawingArea', [1,1,size(app.dicm_fig,2),size(app.dicm_fig,1)],'LineWidth',1);
addlistener(app.h,'ROIMoved',@allevents_h);
app.temp.mask = uint8(createMask(app.h));

set(handles.testo_save, 'string','Segmentation completed. To confirm and analyse the ROI, press "Classify".');
set(handles.draw_roi, 'enable', 'off');
set(handles.delete_roi, 'enable', 'on');
set(handles.save_mask, 'enable', 'on');
                

% --- Executes on button press in delete_roi.
function delete_roi_Callback(hObject, eventdata, handles)
% hObject    handle to delete_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global app
set(handles.testo_save, 'string','');

app.temp.mask = [];
% Re-Plot
%     imshow(app.temp.image, [], 'Parent', handles.slice_fig);
global hf
axes(handles.axes1);
hf = imshow(app.dicm_fig,[]);
axis image
axis off
set(handles.testo_save, 'string','Please, press "Draw Mask ROI" and segment the lesion.');
set(handles.save_mask, 'enable', 'off');
set(handles.save_mask, 'visible', 'on');
set(handles.view_report, 'visible', 'off');
set(handles.draw_roi, 'enable', 'on');
set(handles.delete_roi, 'enable', 'off');

% --- Executes on button press in save_mask.
function save_mask_Callback(hObject, eventdata, handles)
% hObject    handle to save_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global app
% set(handles.draw_roi, 'enable', 'off');
set(handles.testo_save, 'string','');
app.h.InteractionsAllowed = 'none';
if ~isempty(app.temp.mask)
    cc = bwconncomp(app.temp.mask,8);
    if cc.NumObjects > 1
        app.testo = 'More than 1 ROI drawn. Please modify it avoiding too narrow areas or crossed lines.';
        set(handles.testo_save, 'string',app.testo);
        app.h.InteractionsAllowed = 'all';
    else
        [row,col] = ind2sub(size(app.temp.mask),cc.PixelIdxList{1,1});
        min_range = min(max(row)-min(row)+1,max(col)-min(col)+1);
        if min_range < 10
            app.testo = 'ROI is too small. Please expand it.';
            set(handles.testo_save, 'string',app.testo);
            app.h.InteractionsAllowed = 'all';
        else
%             new_dicom = [];
            [filepath,name,ext] = fileparts(app.File_Name);
            if strcmp(ext,'.dcm')
            else
                name = strcat(name,ext);
            end
            app.sbj_name = name;
            lista_mask = dir(fullfile(app.Path_Name,strcat(name,'*')));
            conta_mask = 1;
            for i = 1:length(lista_mask)
                if endsWith(lista_mask(i).name,'_mask.dcm')
                    conta_mask = conta_mask + 1;
                end
            end
            if conta_mask == 1
                mask_name=strcat(app.Path_Name,'\',name,'_mask.dcm');
            else
                mask_name=strcat(app.Path_Name,'\',name,'_',num2str(conta_mask),'_mask.dcm');
            end

            if size(app.dicm_fig,2)~=size(app.temp.mask,2)
                app.temp.mask2=app.temp.mask(:,2:end);
            else
                app.temp.mask2=app.temp.mask;
            end
        %     if isfile(mask_name)
        %         mask_name=strcat(app.Path_Name,'\',name,'_2_mask.dcm');
        %         if isfile(mask_name)
        %             mask_name=strcat(app.Path_Name,'\',name,'_3_mask.dcm');
        %             if isfile(mask_name)
        %                 mask_name=strcat(app.Path_Name,'\',name,'_4_mask.dcm');
        %             end
        %         end
        %     end

            if size(app.dicm_fig,1)<size(app.temp.mask2,1)
                mask2 = app.temp.mask2(size(app.temp.mask2,1)-size(app.dicm_fig,1)+1:end,:);
                app.temp.mask2 = mask2;
            end
            if size(app.dicm_fig,2)<size(app.temp.mask2,2)
                mask3 = app.temp.mask2(:,1:size(app.dicm_fig,2));
                app.temp.mask2 = mask3;
            end
            app.temp.mask2=bwmorph(app.temp.mask2,'bridge');
            dicomwrite(app.temp.mask2,mask_name,app.info,'CreateMode', 'copy');

        %     testo=strcat('Mask file saved as: "', name,'_mask.dcm"');

        %     set(handles.testo_save, 'string',testo);
            app.Mask_Name = mask_name;
            set(handles.draw_roi, 'enable', 'off');
        %     set(handles.delete_roi, 'visible', 'off');
        %     set(handles.save_mask, 'visible', 'off');
            finito(handles);
            set(handles.save_mask, 'visible','off');
            set(handles.view_report, 'visible','on');
        end
    end
else
    errordlg('no mask to save, please click "Draw Mask ROI".');
end
app.h.InteractionsAllowed = 'all';

function finito(handles)
global app
set(handles.testo_save, 'string','Classifing...');
output = trace4bus_classify(app);
%produce and save report
if output.class == 0
    switch app.answer1
    case 'Yes'
        switch app.answer2
            case 'Yes' % 0% di malignancy with second opinion
                app.testo = 'Breast lesion with >0% likelihood of malignancy: short-interval follow-up or continuous surveillance is suggested.';
                set(handles.testo_save, 'string',app.testo);
                app.pdf__path = trace4bus__testreport(app.testo,app.sbj_name,app.Path_Name,app.second);
            case 'No' % 0% di malignancy without second opinion
                
        end
    case 'No'
        switch app.answer2
            case 'Yes' % >0% di malignancy with second opinion
                app.testo = 'Breast lesion with >2% likelihood of malignancy: tissue diagnosis is suggested.';
                set(handles.testo_save, 'string',app.testo);
                app.pdf__path = trace4bus__testreport(app.testo,app.sbj_name,app.Path_Name,app.second);
            case 'No' % >0% di malignancy without second opinion
                
        end
    end
else
    switch app.answer1
    case 'Yes'
        switch app.answer2
            case 'Yes' % 0% di malignancy with second opinion
                app.testo = 'Breast lesion with 0% likelihood of malignancy.';
                set(handles.testo_save, 'string',app.testo);
                app.pdf__path = trace4bus__testreport(app.testo,app.sbj_name,app.Path_Name,app.second);
            case 'No' % 0% di malignancy without second opinion
                
        end
    case 'No'
        switch app.answer2
            case 'Yes' % >0% di malignancy with second opinion
                app.testo = 'Breast lesion with <2% likelihood of malignancy: short-interval follow-up or continuous surveillance is suggested.';
                set(handles.testo_save, 'string',app.testo);
                app.pdf__path = trace4bus__testreport(app.testo,app.sbj_name,app.Path_Name,app.second);
            case 'No' % >0% di malignancy without second opinion
                
        end
    end
end

% --- Executes on button press in next.
function next_Callback(hObject, eventdata, handles)
% hObject    handle to next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global app
set(handles.save_mask, 'visible','on');
set(handles.save_mask, 'enable','off');
set(handles.view_report, 'visible','off');
app.second = 0;
if app.counter < length(app.lista)
    app.counter=app.counter+1;
    uploaded = 0;
    while uploaded == 0 && app.counter <= length(app.lista)
        try app.File_Name = app.lista(app.counter).name;
            if app.File_Name ~= 0
                try dicominfo(fullfile(app.Path_Name,app.File_Name));
                    uploaded = 1;
                catch
                    app.counter=app.counter+1;
                end
            end
        end
    end
    if uploaded == 1
        sequence_upload(handles)
    else
        set(handles.testo_save, 'string','No other dicom images found in the folder.');
        set(handles.next,'enable', 'off');
    end
else
    set(handles.testo_save, 'string','No other dicom images found in the folder.');
    set(handles.next,'enable', 'off');
end

% --- Executes on button press in up_folder.
function up_folder_Callback(hObject, eventdata, handles)
% hObject    handle to up_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global app
% global hf
app.testo = '';
app.second = 0;
try [app.Path_Name] = uigetdir(app.Path_Name);
catch
    [app.Path_Name] = uigetdir;
end
if app.Path_Name ~= 0
    set(handles.testo_save, 'string','');
    app.lista=dir(app.Path_Name);
    app.lista(1:2)=[];
    % lista2=dir(fullfile(app.Path_Name,'*.jpeg'));
    % app.lista=[lista1; lista2];
    app.counter=1;
    set(handles.next,'enable', 'on');
    sequence_upload(handles)
end


function sequence_upload(handles)
global app
global hf
app.testo = '';
set(handles.delete_roi, 'enable', 'off');
set(handles.save_mask, 'visible','on');
set(handles.save_mask, 'enable','off');
set(handles.view_report, 'visible','off');
set(handles.testo_save, 'string','');
app.upload=0;
while app.upload == 0 && app.counter<=length(app.lista)
    app.File_Name = app.lista(app.counter).name;
    if app.File_Name ~= 0
        try dicominfo(fullfile(app.Path_Name,app.File_Name));
            if endsWith(app.File_Name,'_mask.dcm')
                app.counter = app.counter+1;
            else
                app.upload=1;
            end
            
        catch
%             app.upload=2;
            app.counter = app.counter+1;
        end
    end
end
if app.counter >= length(app.lista) && app.upload~=1
    app.upload=2;
end
    
if app.upload==1
    [filepath,name,ext] = fileparts(app.File_Name);
    if strcmp(ext,'.dcm')
    else
        name = strcat(name,ext);
    end
    app.sbj_name = name;
    app.info=dicominfo(fullfile(app.Path_Name,app.File_Name));
%     info_cell = struct2cell(app.info.PatientName);
%     fam_name = info_cell{1};
    app.dicm_fig=dicomread(fullfile(app.Path_Name,app.File_Name));
    app.dicm_fig = squeeze(app.dicm_fig);
    if max(max(max(app.dicm_fig)))==255
        app.dicm_fig = uint8(app.dicm_fig);
    end
%     tipo = class(app.dicm_fig);
%     [app.dicm_fig, ~] = chance_datatype(app.dicm_fig,tipo);
    try 
        app.dicm_fig = rgb2gray(app.dicm_fig);
    catch
    end
    
%     app.figura=imread(fullfile(app.Path_Name,app.File_Name));
    
    axes(handles.axes1)
    hf = imshow(app.dicm_fig,[]);
%     app.figura_or = app.figura;
    app.temp.mask = [];
    app.temp.clean = [];
    axis image
    axis off
    
    app.answer1 = question1;
    app.answer2 = question2;
    
    switch app.answer1
    case 'Yes'
        switch app.answer2
            case 'Yes' % 0% di malignancy with second opinion
                app.second = 1;
                set(handles.testo_save, 'string','Please, press "Draw Mask ROI" and segment the lesion.');
                set(handles.draw_roi, 'enable', 'on');
%                 set(handles.delete_roi, 'enable', 'on');
            case 'No' % 0% di malignancy without second opinion
                app.second = 0;
                app.testo = 'Breast lesion with 0% likelihood of malignancy.';
                set(handles.testo_save, 'string', app.testo);
                set(handles.draw_roi, 'enable', 'off');
                set(handles.delete_roi, 'enable', 'off');
                app.pdf__path = trace4bus__testreport(app.testo,app.sbj_name,app.Path_Name,app.second);
        end
    case 'No'
        switch app.answer2
            case 'Yes' % >0% di malignancy with second opinion
                app.second = 1;
                set(handles.testo_save, 'string','Please, press "Draw Mask ROI" and segment the lesion.');
                set(handles.draw_roi, 'enable', 'on');
%                 set(handles.delete_roi, 'enable', 'on');
            case 'No' % >0% di malignancy without second opinion
                app.second = 0;
                app.testo = 'Breast lesion with >0% likelihood of malignancy.';
                set(handles.testo_save, 'string', app.testo);
                set(handles.draw_roi, 'enable', 'off');
                set(handles.delete_roi, 'enable', 'off');
                app.pdf__path = trace4bus__testreport(app.testo,app.sbj_name,app.Path_Name,app.second);
        end
    end
    
    
    
elseif app.upload==2
    set(handles.testo_save, 'string','No other dicom images found in the folder.');
    set(handles.next,'enable', 'off');
    set(handles.draw_roi, 'enable', 'off');
    set(handles.delete_roi, 'enable', 'off');
end


function allevents_h(~,evt)
global app
evname = evt.EventName;
switch(evname)
    case{'MovingROI'}
    case{'ROIMoved'}
        app.temp.mask = uint8(createMask(evt.Source));
end


% % --- Executes on button press in logout.
% function logout_Callback(hObject, eventdata, handles)
% % hObject    handle to logout (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% global app
% out = app.modello;
% closereq;
% trace4BUS_login(out);


% --- Executes on button press in logout.
function logoutmenu(src,event)
% hObject    handle to logout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global app
out = app.modello;
closereq;
trace4BUS_login(out);

function CPSelected(src,event)
global app
trace4__pwdreset(app.username,app.password,2);


% --- Executes on button press in view_report.
function view_report_Callback(hObject, eventdata, handles)
% hObject    handle to view_report (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global app
system(['start "TRACE4BUS | Test Report" ','"', app.pdf__path,'"']);


% --- Executes on button press in IOU.
function IOU_Callback(hObject, eventdata, handles)
% hObject    handle to IOU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox('prova......hearhaehaehae... .......fasdfafas...... .....heahhaeh......fsdfsdfs.. .....herahaeh..fsdfafasdf... ... reher...eh','Indications of Use','help');

% --- Executes on button press in TOU.
function TOU_Callback(hObject, eventdata, handles)
% hObject    handle to TOU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox('prova......... ........... ......... ........ ..... .... .....hhh','Terms of Use','help');

% --- Executes on button press in REG.
function REG_Callback(hObject, eventdata, handles)
% hObject    handle to REG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% uialert(app.figure1, "This software is not a medical device. It is not CE marked nor FDA cleared. Any use of this software and the associated information is for research and statistical analysis only.", 'Regulatory','Icon','info');
msgbox('This software is not a medical device. It is not CE marked nor FDA cleared. Any use of this software and the associated information is for research and statistical analysis only.','Regulatory','help');

