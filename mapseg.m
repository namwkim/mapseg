function varargout = mapseg(varargin)
% MAPSEG M-file for mapseg.fig
%      MAPSEG, by itself, creates a new MAPSEG or raises the existing
%      singleton*.
%
%      H = MAPSEG returns the handle to a new MAPSEG or the handle to
%      the existing singleton*.
%
%      MAPSEG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAPSEG.M with the given input arguments.
%
%      MAPSEG('Property','Value',...) creates a new MAPSEG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mapseg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mapseg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mapseg

% Last Modified by GUIDE v2.5 28-Jan-2013 00:44:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mapseg_OpeningFcn, ...
                   'gui_OutputFcn',  @mapseg_OutputFcn, ...
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


% --- Executes just before mapseg is made visible.
function mapseg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mapseg (see VARARGIN)

% Choose default command line output for mapseg
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
setappdata(handles.img,'bw',[]); 
setappdata(handles.img,'stage1',[]); 
setappdata(handles.img,'stage2',[]); 
setappdata(handles.img,'stage3',[]); 
setappdata(handles.img,'stage4',[]); 
setappdata(handles.img,'stage5',[]); 
setappdata(handles.img,'stage6',[]); 
setappdata(handles.img, 'stage', -1);
% UIWAIT makes mapseg wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mapseg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in load_btn.
function load_btn_Callback(hObject, eventdata, handles)
% hObject    handle to load_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,path,~] = uigetfile({  '*.jpg','JPEG (*.jpg)'; ...
                                '*.png','PNG (*.png)'; ...
                                '*.bmp','BMP (*.bmp)'; ...
                                '*.*',  'All Files (*.*)'},...
                                'Select an Image File');
                            
if (filename~=0)
    bw = tobinary(strcat(path, filename));
    rgb = bw2rgb(bw);
    setappdata(handles.img, 'org', bw);
    setappdata(handles.img,'bw',bw);
    setappdata(handles.img,'rgb',rgb);
    setappdata(handles.img,'stage',0);
    setappdata(handles.img, 'polygon', {});
    setappdata(handles.img, 'stats', {});
    setappdata(handles.img, 'filename', filename);
    set(handles.stage, 'String', '0');
    axes(handles.img);
    imshow(bw);
end

% --- Executes on button press in save_btn.
function save_btn_Callback(hObject, eventdata, handles)
% hObject    handle to save_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filename = getappdata(handles.img, 'filename');
[~,name,ext] = fileparts(filename);

[filename,path] = uiputfile(strcat(name,'.poly'), 'Save');

if (filename~=0)
    polygons = getappdata(handles.img, 'polygon');
    [~,numpoly] = size(polygons);
    fid = fopen(strcat(path,filename),'w');
    for i=1:3:numpoly
        poly = polygons{i};
        fprintf(fid, 'polygon %d\n', i);
        fprintf(fid, '%12.3f, %12.3f\n', poly);
    end
    fclose(fid);
end


% --- Executes on button press in thin_btn.
function thin_btn_Callback(hObject, eventdata, handles)
% hObject    handle to thin_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stage = getappdata(handles.img, 'stage');
if stage==1
    bw = getappdata(handles.img, 'bw');
    bw =thinning(bw);
    axes(handles.img);
    imshow(bw);
    setappdata(handles.img,'bw',bw); 
    setappdata(handles.img,'stage2',bw);
    setappdata(handles.img,'stage',2);
    set(handles.stage, 'String', '2');
else 
    msgbox('You need to remove grid beforehand!','error','modal');
end


% --- Executes during object creation, after setting all properties.
function grid_width_CreateFcn(hObject, eventdata, handles)
% hObject    handle to grid_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rm_grid_btn.
function rm_grid_btn_Callback(hObject, eventdata, handles)
% hObject    handle to rm_grid_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

stage = getappdata(handles.img, 'stage');
if stage==0
    bw = getappdata(handles.img, 'bw');
    grid_width = str2num(get(handles.grid_width, 'String'));
    hthresh = str2num(get(handles.hthresh, 'String'));
    vthresh = str2num(get(handles.vthresh, 'String'));

    t = cputime;
    [~, vresult] = remove_vgrid5(bw, grid_width, vthresh, 50, 3,4);
    axes(handles.img);
    imshow(vresult);
    [~, hresult] = remove_hgrid5(vresult, grid_width, hthresh, 50, 3,4);
    axes(handles.img);
    disp(['grid(t): ', num2str(cputime-t)]);
    imshow(hresult);    
    setappdata(handles.img,'bw',hresult); 
    setappdata(handles.img,'stage',1);
    setappdata(handles.img,'stage1',hresult);
    set(handles.stage, 'String', '1');
else 
    msgbox('You need to load an image!', 'error', 'modal');
end


% --------------------------------------------------------------------
function pan_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to pan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)\
pan on;

% --------------------------------------------------------------------
function zoom_in_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to zoom_in (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hz = zoom(handles.img);
set(hz, 'Enable', 'on', 'Direction', 'in');


% --------------------------------------------------------------------
function zoom_out_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to zoom_out (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hz = zoom(handles.img);
set(hz, 'Enable', 'on', 'Direction', 'out');


% --- Executes on button press in select_btn.
function select_btn_Callback(hObject, eventdata, handles)
% hObject    handle to select_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stage = getappdata(handles.img, 'stage');
if stage>=5
    bw  = getappdata(handles.img, 'bw');
    rgb = getappdata(handles.img, 'rgb');
    
    [polygons, regions, colored] = select_region(handles.img, bw, rgb);
    axes(handles.img);
    imshow(colored);

    setappdata(handles.img,'stage',6);
    set(handles.stage, 'String', '6');
    
    confirm = questdlg('Do you want to save the regions?',...
                        'Confirm Regions',...
                        'Yes','No','Yes');
    if (strcmp(confirm, 'Yes'))
        found = getappdata(handles.img, 'polygon');
        found = [found, polygons];
        setappdata(handles.img, 'polygon', found);
        setappdata(handles.img, 'bw', regions);
        setappdata(handles.img, 'rgb', colored);
    else
        %show the image before
        axes(handles.img);
        imshow(bw);
    end
else 
    msgbox('You need to close holes beforehand!', 'error', 'modal');
end


function hole_size_Callback(hObject, eventdata, handles)
% hObject    handle to hole_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hole_size as text
%        str2double(get(hObject,'String')) returns contents of hole_size as a double


% --- Executes during object creation, after setting all properties.
function hole_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hole_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in close_hole_btn.
function close_hole_btn_Callback(hObject, eventdata, handles)
% hObject    handle to close_hole_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

stage = getappdata(handles.img, 'stage');
if stage==4
    bw = getappdata(handles.img, 'bw');
    hole_size = str2num(get(handles.hole_size, 'String'));
    t=cputime;
    bw = close_lands(bw, hole_size, 5);
    disp(['close(t): ', num2str(cputime-t)]);
    axes(handles.img);
    imshow(bw);    
    rgb  = bw2rgb(bw); % sync before region selection
    setappdata(handles.img,'rgb',rgb); 
    setappdata(handles.img,'bw',bw); 
    setappdata(handles.img,'stage',5);
    setappdata(handles.img,'stage5',bw);
    set(handles.stage, 'String', '5');

else 
    msgbox('You need to remove characters beforehand!', 'error', 'modal');
end


function frg_size_Callback(hObject, eventdata, handles)
% hObject    handle to frg_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frg_size as text
%        str2double(get(hObject,'String')) returns contents of frg_size as a double


% --- Executes during object creation, after setting all properties.
function frg_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frg_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rm_frg_btn.
function rm_frg_btn_Callback(hObject, eventdata, handles)
% hObject    handle to rm_frg_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stage = getappdata(handles.img, 'stage');
if stage==3
    bw = getappdata(handles.img, 'bw');
    frg_size = str2num(get(handles.frg_size, 'String'));
    t = cputime;
    bw = remove_fragments(bw, frg_size);
    disp(['frag(t): ', num2str(cputime-t)]);
    axes(handles.img);
    imshow(bw);    
    setappdata(handles.img,'bw',bw); 
    setappdata(handles.img,'stage',4);
    set(handles.stage, 'String', '4');
    setappdata(handles.img,'stage4',bw);
else 
    msgbox('You need to remove characters beforehand!', 'error', 'modal');
end

% --- Executes during object creation, after setting all properties.
function brch_pts_CreateFcn(hObject, eventdata, handles)
% hObject    handle to brch_pts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function chr_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chr_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rm_chr_btn.
function rm_chr_btn_Callback(hObject, eventdata, handles)
% hObject    handle to rm_chr_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stage = getappdata(handles.img, 'stage');
if stage==2
    bw = getappdata(handles.img, 'bw');
    brch_pts = str2num(get(handles.brch_pts, 'String'));
    chr_size = str2num(get(handles.chr_size, 'String'));
    t = cputime;
    bw = remove_characters(bw, brch_pts, chr_size);
    disp(['char(t): ', num2str(cputime-t)]);
    for i=1:3
        bw = ~bwmorph(~bw, 'spur');
    end
    axes(handles.img);
    imshow(bw);    
    setappdata(handles.img,'bw',bw); 
    setappdata(handles.img,'stage',3);
    set(handles.stage, 'String', '3');
    setappdata(handles.img,'stage3',bw);
else 
    msgbox('You need to thin images beforehand!', 'error', 'modal');
end


% --- Executes on button press in select_auto_region.
function select_auto_region_Callback(hObject, eventdata, handles)
% hObject    handle to select_auto_region (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
polygons = getappdata(handles.img, 'polygon');
image    = getappdata(handles.img, 'rgb');
 
% get user selection
[x, y] = getpts(handles.img);
y=round(y); x=round(x);
[numpts,~] = size(y);
if numpts == 1
    [~,numpoly] = size(polygons);
    dist = [];
    for i=2:3:numpoly
        stats = polygons{i};
        % calculate distances from auto-segmented polygons
        dist = [dist, norm(stats(2:3) - [y,x], 2)];
    end
    %find the selected polygon
    [~, sidx] = min(dist);
    set(handles.stats_text, 'Max', 20);
    set(handles.stats_text, 'String', {
        ['selected polygon', num2str(sidx)],
        'now segment a region...'});
    setappdata(handles.img, 'sidx', sidx);
end
    


% --- Executes on button press in segment_region.
function segment_region_Callback(hObject, eventdata, handles)
% hObject    handle to segment_region (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sidx = getappdata(handles.img, 'sidx');
stats = getappdata(handles.img, 'stats');
image    = getappdata(handles.img, 'rgb');
segbw = roipoly;
marea = size(find(segbw), 1);

confirm = questdlg('Do you want to use this region?',...
                    'Confirm Regions',...
                    'Yes','No','Yes');
if (strcmp(confirm, 'Yes'))
    if (sidx ~= -1)
        polygons = getappdata(handles.img, 'polygon');
        spolygon = polygons{sidx*3-1}; %stats are saved in even-indices
        sarea    = spolygon(1);
        sregion  = polygons{sidx*3}; % region bw
        % false positive error
        fpe = 100*(size(find(sregion&(~segbw)), 1)/marea);  
        % false negative error
        fne = 100*(size(find((~sregion)&segbw), 1)/marea);        
        % similarity error
        sim = 1-(2*size(find(sregion&segbw),1))/(marea+sarea);
        
        stats = [stats, [sidx, fpe, fne, sim]];
        set(handles.stats_text, 'String', {
            ['eval_count: ', num2str(size(stats, 2))],
            ['marea:', num2str(marea)],
            ['sarea:', num2str(sarea)],
            ['index: ', num2str(sidx)],
            ['fpe: ', num2str(fpe)],
            ['fne: ', num2str(fne)],
            ['sim: ', num2str(sim)],
            'evaluate another region...'});

    else
        stats = [stats, [-1, 0, 0, 0]];
        set(handles.stats_text, 'String', {
            ['eval_count: ', num2str(size(stats, 2))],
            ['marea:', num2str(0)],
            ['sarea:', num2str(0)],            
            ['index: ', num2str(sidx)],
            ['fpe: ', num2str(0)],
            ['fne: ', num2str(0)],
            ['sim: ', num2str(0)],
            'evaluate another region...'});
    end
    setappdata(handles.img, 'sidx', -1); %reset the index
    setappdata(handles.img, 'stats', stats); %save stats
end



% --- Executes on button press in done_eval.
function done_eval_Callback(hObject, eventdata, handles)
% hObject    handle to done_eval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% reports stats
stats = getappdata(handles.img, 'stats');

[~,num] = size(stats);
dist = [];
sum_fpe = 0;
sum_fne = 0; 
sum_sim = 0;
num_auto = 0;
num_manual = 0;
for i=1:num
    stat = stats{i};
    if (stat(i) ~= -1) % auto-region exists
        num_auto = num_auto + 1;
        sum_fpe  = sum_fpe + stat(2);
        sum_fne  = sum_fne + stat(3);
        sum_sim  = sum_sim + stat(4);
    end       
    num_manual = num_manual + 1;
end
set(handles.stats_text, 'String', {
    ['avg_fpe: ', num2str(sum_fpe/num_auto)],
    ['avg_fne: ', num2str(sum_fne/num_auto)],
    ['avg_sim: ', num2str(sum_sim/num_auto)],
    ['num_auto: ', num2str(num_auto)],
    ['num_manual: ', num2str(num_manual)],
    ['seg_rate: ', num2str(100*(1-(num_auto/num_manual)))]});


% --- Executes during object creation, after setting all properties.
function stats_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stats_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in see_org_img.
function see_org_img_Callback(hObject, eventdata, handles)
% hObject    handle to see_org_img (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of see_org_img
stage = getappdata(handles.img, 'stage');
if get(hObject, 'Value') == 1
    img = getappdata(handles.img, 'org');
else
    if stage==6
        img = getappdata(handles.img, 'rgb');
    else
        img = getappdata(handles.img, 'bw');
    end
end
axes(handles.img);
imshow(img);  



function hthresh_Callback(hObject, eventdata, handles)
% hObject    handle to hthresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hthresh as text
%        str2double(get(hObject,'String')) returns contents of hthresh as a double


% --- Executes during object creation, after setting all properties.
function hthresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hthresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function vthresh_Callback(hObject, eventdata, handles)
% hObject    handle to vthresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vthresh as text
%        str2double(get(hObject,'String')) returns contents of vthresh as a double


% --- Executes during object creation, after setting all properties.
function vthresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vthresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in back_btn.
function back_btn_Callback(hObject, eventdata, handles)
% hObject    handle to back_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stage = getappdata(handles.img, 'stage');
switch stage
    case 1
        setappdata(handles.img, 'bw', getappdata(handles.img, 'org'));
        setappdata(handles.img, 'stage', 0);
        set(handles.stage, 'String', '0');
    case 2
        setappdata(handles.img, 'bw', getappdata(handles.img, 'stage1'));
        setappdata(handles.img, 'stage', 1);
        set(handles.stage, 'String', '1');
    case 3
        setappdata(handles.img, 'bw', getappdata(handles.img, 'stage2'));        
        setappdata(handles.img, 'stage', 2);
        set(handles.stage, 'String', '2');
    case 4
        setappdata(handles.img, 'bw', getappdata(handles.img, 'stage3'));        
        setappdata(handles.img, 'stage', 3);
        set(handles.stage, 'String', '3');
    case 5
        setappdata(handles.img, 'bw', getappdata(handles.img, 'stage4'));        
        setappdata(handles.img, 'stage', 4);
        set(handles.stage, 'String', '4');
    case 6
        setappdata(handles.img, 'bw', getappdata(handles.img, 'stage5'));        
        setappdata(handles.img, 'stage', 5);
        set(handles.stage, 'String', '5');        
end
axes(handles.img);
imshow(getappdata(handles.img, 'bw')); 

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over back_btn.
function back_btn_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to back_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function stage_Callback(hObject, eventdata, handles)
% hObject    handle to stage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stage as text
%        str2double(get(hObject,'String')) returns contents of stage as a double


% --- Executes during object creation, after setting all properties.
function stage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
