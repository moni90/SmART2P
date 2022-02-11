function varargout = ROIs(varargin)
% ROIS MATLAB code for ROIs.fig
%      ROIS, by itself, creates a new ROIS or raises the existing
%      singleton*.
%
%      H = ROIS returns the handle to a new ROIS or the handle to
%      the existing singleton*.
%
%      ROIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROIS.M with the given input arguments.
%
%      ROIS('Property','Value',...) creates a new ROIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ROIs_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ROIs_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ROIs

% Last Modified by GUIDE v2.5 28-Jan-2021 09:35:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ROIs_OpeningFcn, ...
    'gui_OutputFcn',  @ROIs_OutputFcn, ...
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

function ROIs_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ROIs (see VARARGIN)
global data
%add path to CAIMAN for NORMCorre and other functions already implemented
if ispc
    addpath(genpath('.\CaImAn-MATLAB-master'));
    addpath(genpath('.\utilities'));
    addpath(genpath('.\NoRMCorre-master'));
else
    addpath(genpath('./CaImAn-MATLAB-master'));
    addpath(genpath('./utilities'));
    addpath(genpath('./NoRMCorre-master'));
end
% Choose default command line output for ROIs
handles.output = hObject;
set(handles.elap_time,'String',strcat(num2str(0),' s'));
% Update handles structure
guidata(hObject, handles);

%set some parameters needed
data.transient_prev_seconds = 0.4;
data.transient_post_seconds = 1;
data.min_px_roi = 5;%min num of px for each ROI for manual segmentation
data.average_window_choose_roi = 2;%0.4;
data.running_average_linescan = 0.5;%I will average and downsample the activity of the linescans
data.motion_rigid.bin_width = 50;
data.motion_rigid.max_shift = 15;
data.motion_rigid.us_fact = 50;
data.motion_rigid.avg_width = 10;
data.motion_non_rigid.grid_size = [64,64];
data.motion_non_rigid.mot_uf = 4;
data.motion_non_rigid.bin_width = 50;
data.motion_non_rigid.max_shift = 8;
data.motion_non_rigid.max_dev = 4;
data.motion_non_rigid.us_fac = 20;
data.motion_non_rigid.avg_width = 10;
data.average_slash_max = 'DR';
data.handles.imagen = imagesc([],'parent',handles.imagen);%keep the handle of the gui image
data.handles.axes_handles_imagen = handles.imagen;%keep the handle of the gui image
set(handles.imagen,'visible','off')
data.handles.activity = imagesc([],'parent',handles.activity);%keep the handle of the gui image
data.handles.axes_handles_activity = handles.activity;%keep the handle of the gui image
data.handles.scanning_trajectory = handles.scanning_trajectory;
data.handles.play_movie = handles.play_movie;
set(handles.activity,'visible','off')
data.handles.update_ROIs = handles.update_ROIs;
data.insides = 0;%this variable controls if the rois' inside are shown or not (0=not)
data.handles.num_neuronas_text = handles.num_neuronas_indicator;%keep this handle so it can be accesed later
data.prediction_made = 0;%to control if there are ROIs to show or not
data.handles.neurons_list = handles.neurons_list;
data.rois_hidden = 0;
colores = [[1 0 0];[0 1 0];[0 0 1];[0 1 1];[1 0 1];[1 1 0];];%[0 0 0]];%colores is the variable that keeps the colours used to draw the ROIs
data.colores = [colores(2:end,:);colores(1:end,:)*0.9;colores(1:end,:)*0.8,;colores(1:end,:)*0.7;...
    colores(1:end,:)*0.6;colores(1:end,:)*0.5,;colores(1:end,:)*0.4];
data.colores = repmat(data.colores,10,1);
%try to load the file in which the last parameters' values are kept (XXX
%you need to actually put the parameters in the variable 'recent' and save
%it)
try
    load('recent')
    data.size_area_roi = recent.size_area_roi;
    data.fluorescence_threshold = recent.fluorescence_threshold;
    data.path = recent.path;
catch m
    display(m.message)
    data.size_area_roi = 10;
    data.fluorescence_threshold = 90;
end

function varargout = ROIs_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%BUTTONS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in correct_motion.
function correct_motion_Callback(hObject, eventdata, handles)
% this function correct motion artefacts in the raster acquition

global data;
choice = questdlg('Do you want to perform rigid or non-rigid motion correction?', ...
    'Motion correction', ...
    'Rigid','Non rigid','Rigid');
% Handle response
tic;
fig_loading = uifigure;
d = uiprogressdlg(fig_loading,'Title','Correcting motion artefacts',...
    'Indeterminate','on');
drawnow
data.movie_doc.movie_original = data.movie_doc.movie_ruido;
if isequal(choice,'Rigid')
    [movie_correct,motion_est] = correctMotionRigid(data.movie_doc.movie_original,data.linesPerFrame,data.pixels_per_line,data.framePeriod,data.path,data.motion_rigid);
    data.motion = motion_est;
    data.movie_doc.movie_ruido = movie_correct;
else
    [movie_correct,motion_est] = correctMotionNonRigid(data.movie_doc.movie_original,data.linesPerFrame,data.pixels_per_line,data.framePeriod,data.path,data.motion_non_rigid);
    data.motion = motion_est;
    data.movie_doc.movie_ruido = movie_correct;
end
close(d)
close(fig_loading)
set(handles.elap_time,'String',strcat(num2str(toc),' s'));

function draw_ROIs_Callback(hObject, eventdata, handles)
%this funcion present the cells to the user for him/her to draw the ROIs.
global data

disp('Draw ROIs')
%before drawing anything the user needs to create/open_tiff_movie a movie
if isfield(data,'movie_doc')
    if ~isequal(data.mode,'Linescan') && ~isequal(data.mode,'freehand')
        if isfield(data,'roi')
            choice = questdlg('Do you want to delete existing ROIs?', ...
                'Reset ROIs', ...
                'Yes','No','No');
            % Handle response
            if isequal(choice,'Yes')
                data = reset_data(data);
                data.CNMF = 0;
                data.update = 0;
            else
                data.update = 1;
            end
        else
            data.CNMF = 0;
            data.update = 0;
        end
        manual_drawing()
    else
        warndlg('Cannot draw ROIs on LS','No drawing');
        return
    end
else
    errordlg('? No data !')
end

function update_ROIs_Callback(hObject, eventdata, handles)
global data;
if ~isequal(data.mode,'Linescan') && ~isequal(data.mode,'freehand')
    data.update = 1;
    manual_drawing();
else
    warndlg('Cannot draw ROIs on LS','No drawing');
    return
end

function predict_ROIs_Callback(hObject, eventdata, handles)
%This function predicts the putative position and shape of a given number
%of ROIs. The user is asked to give in input the number of ROIs and the
%expected radius of the ROIs. First of all the function predict the
%location of the center of the ROIs. After that the user can add further
%starting point for the search af the ROIs. At the end the function
%estimate the shape of the ROIs and their fluorescence activity using the
%algorithm and the software provided by Paninski.
global data
disp('Predict ROIs')
tic;
if isfield(data,'movie_doc')
    %since, we are going to predict new ROIs, we reset the previous
    %parameters related to the prediction
    data = reset_data(data);
    data.CNMF = 1;
    data.some_drawing_done = 1;
    initialize = inputdlg({'Num ROIs:', 'Half radius ROIs:'}, ...
        'Initialization', [1 15; 1 15],{'50', '8'});
    if isempty(initialize)
        return
    end
    data.numStart = str2num(initialize{1});
    data.sizeEst = str2num(initialize{2});
    %auto segmentation of the FOV
    [A_or,C_or,C_df,S_or,P_or] = auto_segmentation_CaImAn(reshape(data.movie_doc.movie_ruido',data.linesPerFrame,data.pixels_per_line,[]),data.numStart,data.sizeEst,data.framePeriod);
    
    if issparse(A_or)
        data.A = full(A_or);
    else
        data.A = A_or;
    end
    if issparse(C_or)
        data.C = full(C_or);
    else
        data.C = C_or;
    end
    if issparse(C_df)
        data.C_df = full(C_df);
    else
        data.C_df = C_df;
    end
    if issparse(S_or)
        data.S = full(S_or);
    else
        data.S = S_or;
    end
    data.P = P_or;
    data.numero_neuronas = size(data.A,2);
    data = fromAtoROIs(data,0.01); %save rois coordinates
    data = fluorescence(data);
    
    %update results and GUI
    data = deal_with_new_rois(data);
else
    errordlg('? No data !')
end
set(handles.elap_time,'String',strcat(num2str(toc),' s'));

function show_inside_Callback(hObject, eventdata, handles)
%this function just show the inside of the ROIs if they are not shown and
%remove them otherwise.
global data
display('Show Inside')
if data.insides == 0
    hold(data.handles.axes_handles_imagen,'on')
    if isfield(data,'numero_neuronas')
        for ind_n=1:data.numero_neuronas
            roi_dots = squeeze(data.rois_inside(ind_n,:,:));
            roi_dots(:,roi_dots(1,:)==0) = [];
            data.handles.inside_rois(ind_n,:) =...
                plot(data.handles.axes_handles_imagen,roi_dots(2,:),roi_dots(1,:),'.','markersize',2,'color',data.colores(ind_n,:));
        end
    end
    hold(data.handles.axes_handles_imagen,'off')
    data.insides = 1;
else
    
    delete(data.handles.inside_rois(data.handles.inside_rois~=0))
    delete(data.handles.outline_rois(data.handles.outline_rois~=0))
    
    hold(data.handles.axes_handles_imagen,'on')
    if isfield(data,'numero_neuronas')
        for ind_n=1:data.numero_neuronas
            roi_dots = squeeze(data.roi(ind_n,:,:));
            roi_dots(:,roi_dots(1,:)==0) = [];
            data.handles.outline_rois(ind_n,:) =...
                plot(data.handles.axes_handles_imagen,roi_dots(2,:),roi_dots(1,:),'.','markersize',2,'color',data.colores(ind_n,:));
        end
    end
    hold(data.handles.axes_handles_imagen,'off')
    data.insides = 0;
end

function average_Callback(hObject, eventdata, handles)
global data
tic;
if ~isequal(data.mode,'Linescan') && ~isequal(data.mode,'freehand')
    imagen = data.movie_doc.movie_ruido;
    data.current_stack = 1:size(imagen,1);
    imagen = average_slash_max(imagen(data.current_stack,:));
    imagen = reshape(imagen, data.linesPerFrame,[]);
    data.frame_plot = round(get(handles.slider1,'value'));
    set(data.handles.imagen,'cdata',imagen)
    set(data.handles.axes_handles_imagen,'XTick',[],'YTick',[])
    set(data.handles.axes_handles_imagen,...
        'xlim',[0.5 data.pixels_per_line + 0.5],'ylim',[0.5 data.linesPerFrame + 0.5]);
    set(data.handles.axes_handles_imagen,'clim',data.limites);
    if ~isequal(data.mode,'Linescan') && ~isequal(data.mode,'freehand')
        axis(data.handles.axes_handles_imagen,'image');
    else
        axis(data.handles.axes_handles_imagen,'square');
    end
    colormap(data.handles.axes_handles_imagen,gray)
else
    warndlg('Cannot show average for SLS','No drawing');
    return
end
time_int = strcat(num2str(toc),' s');
disp(['Average completed!Elapsed time: ',time_int]);
set(handles.elap_time,'String',time_int);

function Movie_Info_Callback(hObject, eventdata, handles)
global data
info = {['movie: ' data.file];'';['mode: ' data.mode];'';['scanning type: ' data.scanningType];'';...
    ['duration: ' num2str(data.duration*data.framePeriod-data.framePeriod) 's'];'';['frame period: ' num2str(data.framePeriod) 's'];'';...
    ['number of frames: ' num2str(data.duration) ];'';['number of lines: ' num2str(data.linesPerFrame)];'';...
    ['pixels per line: ' num2str(data.pixels_per_line)];'';['line period: ' num2str(data.scanlinePeriod) 's'];'';...
    ['dwell time:' num2str(data.dwellTime) 's'];'';['num of neurons: ' num2str(data.numero_neuronas)]};%;...
%     '';['microns per pixel X axis: ' num2str(data.micronsPerPixel_XAxis)];'';['microns per pixel Y axis: ' num2str(data.micronsPerPixel_YAxis)]};

%mean num pixels per neuron
num_pixels_per_neuron = data.numero_puntos(1:data.numero_neuronas);
info = [info;{'';['average num of pixels per neuron: ' num2str(mean(num_pixels_per_neuron))]}];

%num pixels per neuron
num_n_per_packet = 5;
for ind_packet=1:ceil(data.numero_neuronas/num_n_per_packet)
    info_aux = [];
    for ind_n=num_n_per_packet*(ind_packet-1)+1:num_n_per_packet*ind_packet
        if ind_n>data.numero_neuronas
            break
        end
        info_aux = [info_aux [' | n' num2str(ind_n) ': ' num2str(data.numero_puntos(ind_n))]];
    end
    info = [info;{'';info_aux}];
end

msgbox(info, 'INFO','help');

function scanning_trajectory_Callback(hObject, eventdata, handles)
%this function will calculate the scanning trajectory based on the number
%of pixels per neuron introduced by the user.
global data
tam_screen = get(0,'ScreenSize');
video = data.movie_doc.movie_ruido;

if ~isequal(data.mode,'Linescan') && ~isequal(data.mode,'freehand')
    
    automatic_or_manual = questdlg('Automatic or Manual trajectory', ...
        'Choose mode', ...
        'Automatic','Manual','Manual');
    tic;
    if isequal(automatic_or_manual,'Manual')
        data.scan_margin_extra_pixels = 0;
        data.scan_extra_pixels = [];
        data.scan_extra_background = [];
        data.traj_choice = questdlg('Type of Trajectory', ...
            'Choose Trajectory', ...
            'half of the pixels','linear fit','half of the pixels');
        
        h = figure('Units','Normalized','OuterPosition',[0.4 0.2 0.4 0.6],'WindowButtonDownFcn',@wbdcb_scanning_trajectory_onset,'WindowScrollWheelFcn',...
            @pass_frames_scanning_trajectory,'CloseRequestFcn',@close_fnc_scanning_trajectory);
        
        help_button = uicontrol('Parent',gcf,'Style','pushbutton','String','?',...
            'Units','normalized','Position',[0.01 0.95 0.05 0.05]);%,'Visible','on');
        help_button.Callback = @help_window_SLS_show;
        
        imagen = max(video(1:data.duration,:),[],1);
        imagen = reshape(imagen, data.linesPerFrame,[]);
        
        data.scan_image = imagesc(imagen);
        hold on
        tic
        [scan_traj, neurons_tags] = build_scan_trajectory(data.numero_neuronas,data.rois_centres,data.rois_inside,data.traj_choice);
        plot(scan_traj(2,:),scan_traj(1,:),'-','color','y');
        
        distancia = sum(sqrt(diff(scan_traj(1,:)).^2 + diff(scan_traj(2,:)).^2));
        title(['Trajectory length = ' num2str(distancia*4.4e-6) ' (a.u.)'])
        axis image
        colormap('gray')
        if ispc
            save_dir = [data.path 'SLS_trajectory\'];
        else
            save_dir = [data.path 'SLS_trajectory/'];
        end
        if ~exist(save_dir)
            mkdir(save_dir);
        end
        data.scan_traj = scan_traj;
        saveas(h,[save_dir 'scan_path'],'png')
        %here I calculate distances from all points to the scan trajectory. I have
        %changed this so it matches with the transformation done by twoD_to_oneD
        [aux1, aux2] =  meshgrid(1:data.pixels_per_line,1:data.linesPerFrame);
        all_pixels = [aux2(:) aux1(:)];
        data.scan_distances_to_trajectory = zeros(1,size(all_pixels,1));
        data.scan_neuron_tag_all_pixels = zeros(1,size(all_pixels,1));
        for ind_sc=1:size(all_pixels,1)
            [data.scan_distances_to_trajectory(ind_sc),index] =...
                min(sqrt((all_pixels(ind_sc,1)-data.scan_traj(1,:)).^2 + (all_pixels(ind_sc,2)-data.scan_traj(2,:)).^2));
            %here we get as well the tag of each pixels to quickly assign tags to
            %any trajectory
            data.scan_neuron_tag_all_pixels(ind_sc) = neurons_tags(index);
        end
        title('DONE')
        
        
    else
        prompt = {'number of trajectories per class:','Increment in the number of neurons:'};
        dlg_title = 'Input';
        num_lines = 1;
        defaultans = {'5','5'};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        num_rand_traj = str2double(answer{1});
        incr_num_neurons = str2double(answer{2});
        mat_neurons_in_trajs = incr_num_neurons:incr_num_neurons:data.numero_neuronas;
        
        if ispc
            save_dir = [data.path 'SLS_trajectory\'];
        else
            save_dir = [data.path 'SLS_trajectory/'];
        end
        if ~exist(save_dir)
            mkdir(save_dir);
        end
        imagen = max(video(1:data.duration,:),[],1);
        imagen = reshape(imagen, data.linesPerFrame,[]);
        for ind_tr=1:numel(mat_neurons_in_trajs)
            if mat_neurons_in_trajs(ind_tr)==data.numero_neuronas
                num_rand_traj = 1;
            end
            for ind_rand=1:num_rand_traj
                rand_index = randperm(data.numero_neuronas);
                [scan_traj, neurons_tags] = build_scan_trajectory(mat_neurons_in_trajs(ind_tr),...
                    data.rois_centres(rand_index(1:mat_neurons_in_trajs(ind_tr)),:,:),data.rois_inside(rand_index(1:mat_neurons_in_trajs(ind_tr)),:,:),'half of the pixels');
                scan_traj = group_pixels_and_calculate_shortest_path(scan_traj',neurons_tags);
                h1 = figure('OuterPosition',[10 10 tam_screen(3) tam_screen(4)]);
                imagesc(imagen);
                hold on
                plot(scan_traj(:,2),scan_traj(:,1),'y','lineWidth',2)
                
                
                scan_traj = scan_traj';
                distancia = sum(sqrt(diff(scan_traj(1,:)).^2 + diff(scan_traj(2,:)).^2));
                title(num2str(distancia*4.4e-3))
                print(h1,[data.path data.file '_numNeurons_' num2str(mat_neurons_in_trajs(ind_tr)) '_time_' num2str(distancia*4.4e-3) '_' num2str(ind_rand)],'-dpng')
                close(h1)
                save_name = ['sls_trajectory_' data.file '_numNeurons_' num2str(mat_neurons_in_trajs(ind_tr)) '_time_' num2str(round(distancia*4.4e-3)) '_' num2str(ind_rand)];
                m_scanning_trajectory(scan_traj,data.linesPerFrame,data.pixels_per_line,save_dir, save_name)
                scan_traj(1,:) = scan_traj(1,:)/data.linesPerFrame;
                scan_traj(2,:) = scan_traj(2,:)/data.pixels_per_line;
                xml_scanning_trajectory(scan_traj,[save_dir data.file '_numNeurons_' num2str(mat_neurons_in_trajs(ind_tr)) '_time_' num2str(round(distancia*4.4e-3)) '_' num2str(ind_rand)])
            end
        end
        
        %save the reference data (just in case the user forgets to do so and lose it).
        data_aux = data;
        if isfield(data,'handles')
            data = rmfield(data,'handles');
        end
        data_reference.roi = data.roi;
        data_reference.rois_centres = data.rois_centres;
        data_reference.rois_inside = data.rois_inside;
        data_reference.numero_neuronas = data.numero_neuronas;
        data_reference.linesPerFrame = data.linesPerFrame;
        data_reference.pixels_per_line = data.pixels_per_line; %#ok<STRNU>
        
        save([save_dir data.file '_automaticPaths_totalNumNeurons_' num2str(data.numero_neuronas)],'data_reference')
        data = data_aux;
    end
    time_int = strcat(num2str(toc),' s');
    disp(['Scanning trajectory completed! Elapsed time:',time_int]);
    set(handles.elap_time,'String',time_int);
    
else
    warndlg('Cannot draw SLS trajectories on LS','No drawing');
    return
end

function play_movie_Callback(hObject, eventdata, handles)
global data
if isequal(data.mode,'freehand')
    warndlg('Cannot show SLS','No drawing');
    return
else
    if isfield(data,'movie_running')
        data.movie_running = 0;
    else
        data.movie_running = 1;
        imagen = data.movie_doc.movie_ruido;
        s = findobj(data.handles.axes_handles_imagen,'type','line');
        if ~isempty(s)
            delete(s)
        end
        paso = ceil(data.running_average_linescan/data.framePeriod);
        pasos_vector = 1:paso:data.duration-paso;
        if isequal(data.mode,'freehand')
            num_rows = ceil(max(data.freehand_scan(1,:)))-floor(min(data.freehand_scan(1,:)))+1;
            num_col = ceil(max(data.freehand_scan(2,:)))-floor(min(data.freehand_scan(2,:)))+1;
        end
        for ind=pasos_vector
            if data.movie_running
                imagen_aux = mean(imagen(ind:ind+paso-1,:),1);
                imagen_aux = reshape(imagen_aux, data.linesPerFrame,[]);
                set(data.handles.imagen,'cdata',imagen_aux)
                set(data.handles.axes_handles_imagen,'XTick',[],'YTick',[])
                set(data.handles.axes_handles_imagen,...
                    'xlim',[0.5 data.pixels_per_line + 0.5],'ylim',[0.5 data.linesPerFrame + 0.5]);
                
                set(data.handles.axes_handles_imagen,'clim',[min(imagen_aux(:)) max(imagen_aux(:))]);
                colormap(data.handles.axes_handles_imagen,hot)
                axis(data.handles.axes_handles_imagen,'image')
                
                set(handles.num_frame_slider,'string',['Scroll frames - current frame: ' num2str(round(ind))])
                getframe;
                %             pause(data.framePeriod)
            else
                break
            end
        end
        
        data = rmfield(data,'movie_running');
    end
    plot_movie(handles.slider1)
    set(handles.num_frame_slider,'string',['Scroll frames - current frame: ' num2str(round(data.frame_plot))]);
    if isfield(data,'handle_frame_indicator')
        delete(data.handle_frame_indicator)
        
        paso = (max(data.activities(:))-min(data.activities(:)))/2;
        t = min(data.activities(:))-paso:paso:max(data.activities(:))+paso;
        hold(data.handles.axes_handles_activity,'on')
        data.handle_frame_indicator = plot(data.handles.axes_handles_activity,ones(1,numel(t))*data.frameTimes(data.frame_plot),t,'color',[.7 .7 .7]);
        hold(data.handles.axes_handles_activity,'off')
    end
    
    hold(data.handles.axes_handles_imagen,'on')
    for ind_n=1:data.numero_neuronas
        roi_dots = squeeze(data.roi(ind_n,:,:));
        roi_dots(:,roi_dots(1,:)==0) = [];
        data.handles.outline_rois(ind_n,:) =...
            plot(data.handles.axes_handles_imagen,roi_dots(2,:),roi_dots(1,:),'.','markersize',2,'color',data.colores(ind_n,:));
    end
    hold(data.handles.axes_handles_imagen,'off')
end


%                              MENUS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%                             TOOLBAR

function load_import_data_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Segmentation_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function export_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function More_Callback(hObject, eventdata, handles)
% --------------------------------------------------------------------
function Settings_Callback(hObject, eventdata, handles)

%file menu%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%     load and import data

function open_tiff_movie_Callback(hObject, eventdata, handles)
%this function opens RASTER time series saved as single tiff file
global data
tic;
disp('opening file')
if isfield(data,'movie_doc') %if a TS already exists, remove it
    data = rmfield(data,'movie_doc');
end
data.prediction_made = 0;
pintar_rois = 0;
if isfield(data,'path') %select movie
    [FileName,PathName,~] = uigetfile([data.path '*.tif'],'Select Movie');
else
    [FileName,PathName,~] = uigetfile('.tif','Select Movie');
end

if PathName==0
    return;
end
if ispc
    data.path = [PathName(1:end-1) '\'];
else
    data.path = [PathName(1:end-1) '/'];
end

data.file = FileName;

data = import_tiff_sequence(data);

%define other parameters that depend on the frame period
data.transient_prev = ceil(data.transient_prev_seconds/data.framePeriod);
data.transient_post = ceil(data.transient_post_seconds/data.framePeriod);
data.average_window_choose_roi_current = ceil(data.average_window_choose_roi/data.framePeriod);
build_projections()

%once I get the movie, I plot it in the gui figure
plot_movie(handles.slider1)
set(handles.predict_ROIs,'visible','on')
set(handles.slider1,'visible','on')
set(handles.draw_ROIs,'visible','on')
set(handles.num_frame_slider,'visible','on')
set(handles.num_neurons_ind_text,'visible','on')
set(handles.num_neuronas_indicator,'visible','on')
set(handles.num_frames_ind_text,'visible','on')
set(handles.num_frames_total_indicator,'visible','on')
set(handles.correct_motion,'visible','on')
set(data.handles.play_movie,'visible','on')

set(handles.show_inside,'visible','on')
set(handles.Movie_Info,'visible','on')
set(handles.neurons_list,'visible','on')

set(handles.average,'visible','on')

set(handles.slider1,'Max',data.movie_doc.num_frames)
set(handles.slider1, 'SliderStep', [1/data.movie_doc.num_frames , 10/data.movie_doc.num_frames ]);
set(handles.num_frames_total_indicator,'string',num2str(data.movie_doc.num_frames))
if pintar_rois
    data = deal_with_new_rois(data);
end
display('movie info: ')
display(data)
time_int=strcat(num2str(toc),' s');
display(['Loading done! Elapsed Time:',time_int]);

function open_tiff_seq_Callback(hObject, eventdata, handles)
%this function opens RASTER time series saved as sequence of tiff files
global data
tic;
disp('opening file')
if isfield(data,'movie_doc')
    data = rmfield(data,'movie_doc');
end
data.prediction_made = 0;
pintar_rois = 0;
if isfield(data,'path') %select folder
    PathName = uigetdir(data.path,'Select Movie');
else
    PathName = uigetdir('Select Movie');
end

if PathName==0
    return;
end
if ispc
    data.path = [PathName '\'];
else
    data.path = [PathName '/'];
end

data = import_tiff_multitiff(data);

%define other parameters that depend on the frame period
data.transient_prev = ceil(data.transient_prev_seconds/data.framePeriod);
data.transient_post = ceil(data.transient_post_seconds/data.framePeriod);
data.average_window_choose_roi_current = ceil(data.average_window_choose_roi/data.framePeriod);
build_projections()


%once I get the movie, I plot it in the gui figure
plot_movie(handles.slider1)
% msgbox('Movie Loaded');
set(handles.predict_ROIs,'visible','on')
set(handles.slider1,'visible','on')
set(handles.draw_ROIs,'visible','on')
set(handles.num_frame_slider,'visible','on')
set(handles.num_neurons_ind_text,'visible','on')
set(handles.num_neuronas_indicator,'visible','on')
set(handles.num_frames_ind_text,'visible','on')
set(handles.num_frames_total_indicator,'visible','on')
set(handles.correct_motion,'visible','on')
set(data.handles.play_movie,'visible','on')

set(handles.show_inside,'visible','on')
set(handles.Movie_Info,'visible','on')
set(handles.neurons_list,'visible','on')

set(handles.average,'visible','on')

set(handles.slider1,'Max',data.movie_doc.num_frames)
set(handles.slider1, 'SliderStep', [1/data.movie_doc.num_frames , 10/data.movie_doc.num_frames ]);
set(handles.num_frames_total_indicator,'string',num2str(data.movie_doc.num_frames))
if pintar_rois
    data = deal_with_new_rois(data)
end
disp('movie info: ')
display(data)
time_int=strcat(num2str(toc),' s');
disp(['Loading done! Elapsed time:',time_int]);

function lineScan_Callback(hObject, eventdata, handles)
%this function open the linescan required by the user.
global data
frame_quest_dlg = questdlg('Would you like to chose the number of frame to load?',...
    'Number of frame','Yes','No','No');
switch frame_quest_dlg
    case 'Yes'
        frame_num = inputdlg('Number of frame to load:',...
            'Number of frame',...
            [1,30]);
        frame_num=str2double(frame_num);
    case 'No'
        frame_num = NaN;
end
tic;
disp('Opening file');
if isfield(data,'movie_doc')
    data = rmfield(data,'movie_doc');
end
data.prediction_made = 0;
pintar_rois = 0;
%import ls data
software_quest_dlg = questdlg('How did you acquire data?',...
    'Data format','Tiff','ScanImage','Tiff');
switch software_quest_dlg
    case 'Tiff'
        import_linescan_data(frame_num);
    case 'ScanImage'
        [data, success_import] = import_linescan_data_ScanImage(data, frame_num); %missing: how to import trajectory SLS
        if success_import == 0
            return;
        end
end

%import reference ROIs
%ask for the ROIs reference
[filename, pathname] = uigetfile([data.path '*.mat'], 'Select the corresponding ROIs .mat data');
fig_loading = uifigure;
d = uiprogressdlg(fig_loading,'Title','Registering ROIs',...
    'Indeterminate','on');
drawnow
if pathname~=0
    data = register_ROIs_ls(data,[pathname filename]);
else
    warning('No reference segmentation!')
end
close(d)
close(fig_loading)

if isfield(data,'A') && ~isempty(data.A)
    process_quest_dlg = questdlg('Would you like to process the data?',...
        'Data process','Yes','No','No');
    data = process_ls_data(data, process_quest_dlg);
    set(handles.draw_ROIs,'visible','on');
    pintar_rois=1;
    %     deal_with_new_rois;
else
    set(handles.draw_ROIs,'visible','on');
end

%once I get the movie, I plot it in the gui figure
plot_movie(handles.slider1)
set(handles.predict_ROIs,'visible','off')
set(handles.slider1,'visible','on')
% set(handles.draw_ROIs,'visible','off')
set(handles.num_frame_slider,'visible','on')
set(handles.num_neurons_ind_text,'visible','on')
set(handles.num_neuronas_indicator,'visible','on')
set(handles.num_frames_ind_text,'visible','on')
set(handles.num_frames_total_indicator,'visible','on')
set(data.handles.play_movie,'visible','on')

set(handles.show_inside,'visible','on')
set(handles.Movie_Info,'visible','on')
set(handles.neurons_list,'visible','on')

set(handles.average,'visible','on')

set(handles.slider1,'Max',data.movie_doc.num_frames)
set(handles.slider1, 'SliderStep', [1/data.movie_doc.num_frames , 10/data.movie_doc.num_frames ]);
set(handles.num_frames_total_indicator,'string',num2str(data.movie_doc.num_frames))
if pintar_rois
    data = deal_with_new_rois(data);
end
disp('Movie info: ')
display(data)

time_int=strcat(num2str(toc),' s');
disp(['Loading done! Elapsed time:',time_int]);

function lineScan_as_raster_Callback(hObject, eventdata, handles)
%this function open_tiff_movie the experiment required by the user.
global data
frame_num = inputdlg('Number of frame to load:',...
    'Number of frame',...
    [1,30]);
frame_num = str2double(frame_num);
tic;
if frame_num > 2
    warning('The number of frame is too large. Only the first frame will be loaded');
    frame_num = 1;
end

disp('opening file')
if isfield(data,'movie_doc')
    data = rmfield(data,'movie_doc');
end
data.prediction_made = 0;
data.CNMF = 0;
pintar_rois = 0;
%import ls data
software_quest_dlg = questdlg('How did you acquire data?',...
    'Data format','Tiff','ScanImage','Tiff');
switch software_quest_dlg
    case 'Tiff'
        import_linescan_data(frame_num);
    case 'ScanImage'
        [data, success_import] = import_linescan_data_ScanImage(data, frame_num); 
        if success_import == 0
            return;
        end
end

%import reference ROIs
%ask for the ROIs reference
[filename, pathname] = uigetfile([data.path '*.mat'], 'Select the corresponding ROIs .mat data');
fig_loading = uifigure;
d = uiprogressdlg(fig_loading,'Title','Converting to raster',...
    'Indeterminate','on');
drawnow
if pathname~=0
    data = register_ROIs_ls(data,[pathname filename]);
else
    warning('No reference segmentation!')
end

movie = data.movie_doc.movie_ruido;
n_rows = size(data.reference_image,1);
n_col = size(data.reference_image,2);
scan_path = data.freehand_scan;
raster_movie = from_ls_to_raster(movie,scan_path,n_rows,n_col);

%save the movie
data.movie_doc.movie_ls = movie;
data.movie_doc.movie_ruido = raster_movie;
data.movie_doc.num_frames = data.duration;
data.pixels_per_line = n_col;
data.linesPerFrame = n_rows;

try
    data.CNimage = correlation_image(data.movie_doc.movie_ruido',...
        8, data.linesPerFrame, data.pixels_per_line);
    
    %create stack with grouped frames
    build_projections()
catch
    warning('Could not compute correlation matrix and Ystack (check if image processing toolbox is installed)')
    data.CNimage = zeros(data.linesPerFrame, data.pixels_per_line);
    Ystack = zeros(ceil(size(data.movie_doc.movie_ruido,1)/data.average_window_choose_roi_current),...
        data.average_window_choose_roi_current,...
        size(data.movie_doc.movie_ruido,2));
    data.movie_doc.movie_stack = Ystack;
    data.movie_doc.avg_proj = squeeze(nanmean(Ystack,2));
    data.movie_doc.DR_proj = squeeze(nanmax(Ystack,[],2)-nanmin(Ystack,[],2));
end

%now the mode is raster
data.mode = 'raster';
%this is to know which frames to use when showing the visual field
data.current_stack = 1:data.duration;
%once I get the movie, I plot it in the gui figure
plot_movie(handles.slider1)

if isfield(data,'A') && ~isempty(data.A)
    pintar_rois = 1;
    %     process_quest_dlg = questdlg('Would you like to process the data?',...
    %         'Data process','Yes','No','No');
    %     data = process_ls_data(data,process_quest_dlg);
    data = fluorescence(data);
    data = deal_with_new_rois(data);
else
end
close(d)
close(fig_loading)

set(handles.predict_ROIs,'visible','on')
set(handles.slider1,'visible','on')
set(handles.draw_ROIs,'visible','on')
set(handles.num_frame_slider,'visible','on')
set(handles.num_neurons_ind_text,'visible','on')
set(handles.num_neuronas_indicator,'visible','on')
set(handles.num_frames_ind_text,'visible','on')
set(handles.num_frames_total_indicator,'visible','on')
set(data.handles.play_movie,'visible','on')

set(handles.show_inside,'visible','on')
set(handles.Movie_Info,'visible','on')
set(handles.neurons_list,'visible','on')

set(handles.average,'visible','on')

set(handles.slider1,'Max',data.movie_doc.num_frames)
set(handles.slider1, 'SliderStep', [1/data.movie_doc.num_frames , 10/data.movie_doc.num_frames ]);
set(handles.num_frames_total_indicator,'string',num2str(data.movie_doc.num_frames))
if pintar_rois
    data = deal_with_new_rois(data);
end

disp('Movie info: ')
display(data)
time_int=strcat(num2str(toc),' s');
disp(['Loading done! Elapsed time:',time_int]);

function charge_Callback(hObject, eventdata, handles)
global data
tic;
%get the file
if isfield(data,'path')
    [FileName,PathName] = uigetfile('*','Select Movie',data.path);
else
    [FileName,PathName] = uigetfile('*.mat','Select Movie');
end
if FileName==0
    return;
end
if ispc
    data_aux = load([PathName '/' FileName],'-mat');
else
    data_aux = load([PathName '\' FileName],'-mat');
end
data = data_aux.data;
data.handles.imagen = imagesc([],'parent',handles.imagen);%keep the handle of the gui image
data.handles.axes_handles_imagen = handles.imagen;%keep the handle of the gui image
data.handles.activity = imagesc([],'parent',handles.activity);%keep the handle of the gui image
data.handles.axes_handles_activity = handles.activity;%keep the handle of the gui image
data.handles.scanning_trajectory = handles.scanning_trajectory;
data.handles.play_movie = handles.play_movie;
data.handles.update_ROIs = handles.update_ROIs;
data.handles.num_neuronas_text = handles.num_neuronas_indicator;%keep this handle so it can be accesed later
data.handles.neurons_list = handles.neurons_list;
data.path = PathName;
data.file = FileName;
%once we have the ROIs and their insides we plot them.
update_listbox(data.numero_neuronas)
hold(data.handles.axes_handles_imagen,'on')
for ind_n=1:data.numero_neuronas
    roi_dots = squeeze(data.roi(ind_n,:,:));
    roi_dots(:,roi_dots(1,:)==0) = [];
    data.handles.outline_rois(ind_n,:) = plot(data.handles.axes_handles_imagen,roi_dots(2,:),roi_dots(1,:),'.','markersize',2,'color',data.colores(ind_n,:));
end
hold(data.handles.axes_handles_imagen,'off')
%set the text in the gui 'num_neuronas_text' according to the number of
%neurons
set(data.handles.num_neuronas_text,'string',num2str(data.numero_neuronas))
%now we build the fluorescence for each roi
if data.numero_backgrounds==0
    data = fluorescence(data);
else
    data = fluorescence(data,1);
end
for ind_n=1:data.numero_neuronas
    activity = squeeze(data.activities(ind_n,:));
    timing = squeeze(data.pixelsTimes(ind_n,:));
    data.handles.activities(ind_n,:) = plot(data.handles.axes_handles_activity,timing,activity,'color',data.colores(ind_n,:));
    hold(data.handles.axes_handles_activity,'on')
end
paso = (max(data.activities(:))-min(data.activities(:)))/2;
t = min(data.activities(:))-paso:paso:max(data.activities(:))+paso;
data.handle_frame_indicator = plot(data.handles.axes_handles_activity,ones(1,numel(t))*data.frameTimes(min(numel(data.frameTimes),data.frame_plot)),t,'color',[.7 .7 .7]);

hold(data.handles.axes_handles_activity,'off')
data.prediction_made = 1;
data.background_on = 0;
%once I get the movie, I plot it in the gui figure
imagen = data.movie_doc.movie_ruido;
imagen = max(imagen,[],1);%imagen(data.frame_plot,:);
data.limites = [min(imagen(:)) max(imagen(:))];
data.frame_plot = round(get(handles.slider1,'value'));
imagen = reshape(imagen,data.linesPerFrame,[]);
data.imagen = imagen;

set(data.handles.imagen,'cdata',imagen)
set(data.handles.axes_handles_imagen,'XTick',[],'YTick',[])
set(data.handles.axes_handles_imagen,...
    'xlim',[0.5 data.pixels_per_line + 0.5],'ylim',[0.5 data.linesPerFrame + 0.5]);
set(data.handles.axes_handles_imagen,'clim',data.limites);
if ~isequal(data.mode,'Linescan') && ~isequal(data.mode,'freehand'); axis image; else axis square; end
colormap(data.handles.axes_handles_imagen,gray)
% msgbox('Movie Loaded');
set(handles.predict_ROIs,'visible','on')
set(handles.update_ROIs,'visible','on')
set(handles.slider1,'visible','on')
set(handles.draw_ROIs,'visible','on')
set(handles.num_frame_slider,'visible','on')
set(handles.num_neurons_ind_text,'visible','on')
set(handles.num_neuronas_indicator,'visible','on')
set(handles.num_frames_ind_text,'visible','on')
set(handles.num_frames_total_indicator,'visible','on')
set(data.handles.play_movie,'visible','on')

set(handles.show_inside,'visible','on')
set(handles.Movie_Info,'visible','on')
set(handles.neurons_list,'visible','on')

set(handles.average,'visible','on')
set(data.handles.scanning_trajectory,'visible','on')
set(handles.slider1,'Max',data.movie_doc.num_frames)
set(handles.slider1, 'SliderStep', [1/data.movie_doc.num_frames , 10/data.movie_doc.num_frames ]);
set(handles.num_frames_total_indicator,'string',num2str(data.movie_doc.num_frames))
time_int=strcat(num2str(toc),' s');
disp(['Loading done! Elapsed time:',time_int]);

%     segmentation

function import_rois_Callback(hObject, eventdata, handles)
global data
tic;
%get the file
if isfield(data,'path')
    [FileName,PathName] = uigetfile('*.mat','Select Movie',data.path);
else
    [FileName,PathName] = uigetfile('*.mat','Select Movie');
end
if FileName==0
    return;
end
if ispc
    ROIs_path = [PathName '\' FileName];
else
    ROIs_path = [PathName '/' FileName] ;
end
if ~isequal(data.mode,'Linescan') && ~isequal(data.mode,'freehand')
    align_fov=questdlg('Would you like to align FOVS?','Alignment','Yes','No','No');
    switch align_fov
        case 'Yes'
            flag_align = 1;
        case 'No'
            flag_align = 0;
    end
    optimize_SNR=questdlg('Would you like to optimize SNR?','SLS','Yes','No','No');
    switch optimize_SNR
        case 'Yes'
            flag_optimize_SNR = 1;
        case 'No'
            flag_optimize_SNR = 0;
    end
else
    flag_align = 0;
    flag_optimize_SNR = 0;
end
data = import_and_align_ROIs(data,ROIs_path,flag_align,flag_optimize_SNR);
% if ~isequal(data.mode,'Linescan') && ~isequal(data.mode,'freehand')
%     data = deal_with_new_rois(data);
% else
    if isfield(data,'A') && ~isempty(data.A)
        set(handles.draw_ROIs,'visible','on');
        pintar_rois=1;
    else
        set(handles.draw_ROIs,'visible','on');
    end

% end
data = deal_with_new_rois(data);

function import_rois_fiji_Callback(hObject, eventdata, handles)
% hObject    handle to import_rois_fiji (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data
if isfield(data,'CNimage')
    CN = data.CNimage;
else
    CN = correlation_image(data.movie_doc.movie_ruido',8,...
        data.linesPerFrame, data.pixels_per_line);
end

%get the file
if isfield(data,'path')
    [FileName,PathName] = uigetfile(data.path);
else
    [FileName,PathName] = uigetfile;%('*.mat','Select Movie');
end
if FileName==0
    return;
end

sROI = ReadImageJROI([PathName,FileName]);

[xx,yy]=meshgrid(1:1:size(CN,1),1:1:size(CN,2));
for ii = 1:length(sROI)
    ROImask = zeros(size(CN));
    if length(sROI)>1
        coord = sROI{1,ii}.mnCoordinates;
        for jj=1:size(coord,1)
            ROImask(coord(jj,2),coord(jj,1)) = 1;
        end
    end
    
    [x_in,y_in]=inpolygon(xx,yy,coord(:,1),coord(:,2));
    data_aux.A(:,ii) = (x_in(:)+y_in(:))>0;
end

%remove some data that might have been previously stored
data = reset_data(data);

data.CNMF = 0;
data.A = data_aux.A;
data.numero_neuronas = size(data.A ,2);

data = fromAtoROIs(data);
optimize_SNR=questdlg('Would you like to optimize SNR?','SLS','Yes','No','No');
switch optimize_SNR
    case 'Yes'
        data = onlyOptimizeSNR(data);
    case 'No'
        
end
data.noOrder = 1;
deal_with_new_rois;

clear data_aux;

function import_rois_as_A_Callback(hObject, eventdata, handles)

global data
tic;
%get the file
if isfield(data,'path')
    [FileName,PathName] = uigetfile({'*.txt;*.csv'},'Select ROIs',data.path);
else
    [FileName,PathName] = uigetfile({'*.txt;*.csv'},'Select ROIs');
end
if FileName==0
    return;
end
if strcmp(FileName(end-3:end),'.csv') == 0 && strcmp(FileName(end-3:end),'.txt') == 0
    warning('ROI format not valid!');
    return
end
if ispc
    ROIs_path = [PathName '\' FileName];
else
    ROIs_path = [PathName '/' FileName] ;
end

flag_align = 0;
optimize_SNR=questdlg('Would you like to optimize SNR?','SLS','Yes','No','No');
switch optimize_SNR
    case 'Yes'
        flag_optimize_SNR = 1;
    case 'No'
        flag_optimize_SNR = 0;
end
data = import_and_align_ROIs(data,ROIs_path,flag_align,flag_optimize_SNR);
if ~isequal(data.mode,'Linescan') && ~isequal(data.mode,'freehand')
    data = deal_with_new_rois(data);
else
    
end

%      Export

function save_Callback(hObject, eventdata, handles)
global data

data_original = data;


if isfield(data,'file')
    [filename, pathname, filterindex] = uiputfile( '*.mat','save the data',[data.path data.file(1:end-4) '.mat']);
else
    [filename, pathname, filterindex] = uiputfile( '*.mat','save the data','NAME.mat');
end
if filterindex==0
    return
end
if isfield(data,'handles')
    data = rmfield(data,'handles');
end
if isfield(data,'line_handles')
    data = rmfield(data,'line_handles');
end
if isfield(data,'line_bg_handles')
    data = rmfield(data,'line_bg_handles');
end

choice = questdlg('Save a compact version?', ...
    'Remove fields', ...
    'Yes','No','No');
% Handle response
if isequal(choice,'Yes')
    if isfield(data,'movie_doc')
        if isfield(data.movie_doc,'avg_proj')
            data.movie_doc = rmfield(data.movie_doc,'avg_proj');
        end
        if isfield(data.movie_doc,'DR_proj')
            data.movie_doc = rmfield(data.movie_doc,'DR_proj');
        end
        if isfield(data.movie_doc,'movie_stack')
            data.movie_doc = rmfield(data.movie_doc,'movie_stack');
        end
    end
    if isfield(data,'avg_proj')
        data = rmfield(data,'avg_proj');
    end
    if isfield(data,'DR_proj')
        data = rmfield(data,'DR_proj');
    end
    if isfield(data,'large_proj')
        data = rmfield(data,'large_proj');
    end
end

if ~isequal(data.mode,'Linescan') && ~isequal(data.mode,'freehand')
    save([pathname '/' filename],'data','-v7.3')
else
    save([pathname '/' filename],'data','-v7.3')
end


data = data_original;

function save_tif_movie_Callback(hObject, eventdata, handles)
disp('saving tif movie')
global data
options.append = 1;

if isequal(data.mode,'freehand')
    imagen = data.movie_doc.movie_ruido;
    scanPath = data.freehand_scan - min(data.freehand_scan,[],2) + 1;
    num_rows = ceil(max(scanPath(1,:)))-floor(min(scanPath(1,:)))+1;
    num_col = ceil(max(scanPath(2,:)))-floor(min(scanPath(2,:)))+1;
    
    for ind_fr=1:data.movie_doc.num_frames
        tic
        imagen_aux = imagen(ind_fr,:);
        aux = zeros(num_rows,num_col);
        oneD_scan_path = twoD_to_oneD(num_rows,round(scanPath)');
        aux(oneD_scan_path) = imagen_aux;
        imagen_aux = aux;
        saveastiff(uint16(imagen_aux),[data.path 'tiff_movie_from_lineScan.tif'],options);
        tElapsed = toc;
        fprintf('Frame %i out of %i. Elapsed time : %.3f s.\n', ind_fr, data.movie_doc.num_frames, tElapsed)
    end
else
    for ind_fr = 1:data.movie_doc.num_frames
        tic
        aux = uint16(data.movie_doc.movie_ruido(ind_fr,:));
        aux = reshape(aux,data.linesPerFrame,data.pixels_per_line);
        saveastiff(aux,[data.path 'tiff_movie.tif'],options);
        tElapsed = toc;
        fprintf('Frame %i out of %i. Elapsed time : %.3f s.\n', ind_fr, data.movie_doc.num_frames, tElapsed)
    end
end

function export_rois_for_fiji_Callback(hObject, eventdata, handles)
global data

if isfield(data,'path')
    save_folder_name = uigetdir( [data.path], 'Select folder to export ROIs');
else
    save_folder_name = uigetdir( '' , 'Select folder to export ROIs');
end

saveNameFig = [save_folder_name, '\numberedROIs.fig'];
saveNameTif = [save_folder_name, '\numberedROIs.tif'];
saveNameROIs = [save_folder_name,'\exportedROIs.tif'];
saveNameContour = [save_folder_name,'\contourROIs.tif'];
Y = data.movie_doc.movie_ruido';
nRows = data.linesPerFrame; nCol = data.pixels_per_line;
if isfield(data,'CNimage')
    CN = data.CNimage;
else
    CN = correlation_image(Y,8,nRows,nCol);
end
A = data.A;
figure; plot_contours_monocromatic(A,CN,[],1);
savefig(gcf,saveNameFig);
saveas(gcf,saveNameTif);
close(gcf);
%export multitiff with all ROIs
ROI = reshape(A>0,nRows,nCol,[]);
res = saveastiff(uint16(ROI),saveNameROIs);
%export multitiff with repeated contours
contourROIs = zeros(nRows,nCol);
for i = 1:data.numero_neuronas
    border = squeeze(data.roi(i,:,:));
    border(:,sum(border,1)==0)=[];
    for j = 1:size(border,2)
        contourROIs(border(1,j),border(2,j))=1;
    end
end
contourROIs = repmat(contourROIs,1,1,data.duration);
res = saveastiff(uint16(contourROIs),saveNameContour);
h = msgbox('ROIs saved');

%      More

function FOV_correlation_menu_Callback(hObject, eventdata, handles)
%this function calculates for each pixel in the image the correlation with
%its neighbours. It uses a code from labrigger: http://labrigger.com/blog/2013/06/13/local-cross-corr-images/
global data
if isfield(data,'movie_doc')
    video = reshape(data.movie_doc.movie_ruido,size(data.movie_doc.movie_ruido,1),data.linesPerFrame,data.pixels_per_line);
    figure
    subplot(1,2,1)
    imagesc(squeeze(max(video,[],1)))
    title('Max projection')
    colormap('Hot')
    if ~isequal(data.mode,'Linescan') && ~isequal(data.mode,'freehand'); axis image; else axis square; end
    subplot(1,2,2)
    imagesc(squeeze(data.CNimage))
    title('Correlation projection')
    colormap('Hot')
    if ~isequal(data.mode,'Linescan') && ~isequal(data.mode,'freehand'); axis image; else axis square; end
    
else
    errordlg('? No data!')
end

function plot_ROIs_numbered_Callback(hObject,eventdata,handles)
%this function plot the correlation projection between neighboring pixels
%and, on top of that, the contour of the ROIs numbered according to their
%activity (from the "most active" to the "least active").
global data;
if ispc
    save_dir = [data.path 'Analyses\'];
else
    save_dir = [data.path 'Analyses/'];
end
if ~exist(save_dir)
    mkdir(save_dir);
end

Y = data.movie_doc.movie_ruido';
if ~isequal(data.mode,'Linescan') && ~isequal(data.mode,'freehand')
    d1 = data.linesPerFrame; d2 = data.pixels_per_line;
    if isfield(data,'CNimage')
        CN = data.CNimage;
    else
        CN = correlation_image(Y,8,d1,d2);
    end
    %plot ROIs
    A_or = data.A;
    figure; plot_contours(A_or,CN,[],1); colormap('gray'); colorbar;
    saveas(gcf,[save_dir, 'ROIs_numbered.png']);
    savefig(gcf,[save_dir, 'ROIs_numbered.fig']);
else
    ref = data.reference_image;
    A2 = zeros(size(data.reference_image,1)*size(data.reference_image,2),size(data.A,2));
    for k  = 1:size(data.A,2)
        roi_dots = squeeze(data.roi(k,:,:));
        roi_dots(:,roi_dots(1,:)==0) = [];
        coord1D = twoD_to_oneD(size(data.reference_image,1),roi_dots');
        A2(coord1D,k) = 1;
    end
    figure; plot_contours(A2,ref,[],1); colormap('gray'); colorbar;
    saveas(gcf,[save_dir, 'ROIs_numbered.png']);
    savefig(gcf,[save_dir, 'ROIs_numbered.fig']);
end

% figure; imagesc(data.reference_image); colormap(gray);
% for k = 1:data.numero_neuronas
% hold on; plot(squeeze(data.rois_inside(k,2,:)),squeeze(data.rois_inside(k,1,:)),'r.','MarkerSize',10);
% end

%plot traces fluo
nColumns = 3;
nRighe = ceil(data.numero_neuronas/nColumns); %numero di tracce da plottare
figure;
set(gcf,'Color','w','Units','normalized','Position',[0 0 1 1]); %sfondo della figura bianco
for i = 1:data.numero_neuronas
    pos = (mod(i-1,nRighe))*nColumns + 1 + fix((i-1)/nRighe);
    ax = subplot(nRighe,nColumns,pos);
    plot(data.activities(i,:),'k','linewidth',3);
    set(gca,'visible','off','Box','off','XTick',[],'YTick',[]); %non disegna i box delle figure, gli assi, e i label degli assi
    %     ylabel(num2str(i),
    text(ax,-0.1,0.3,num2str(i),'FontSize',16,'Fontweight','bold','Units','normalized');
    %     legend(num2str(i),'Location','westoutside');
end
saveas(gcf,[save_dir, 'F_df_numbered.png']);
savefig(gcf,[save_dir, 'F_df_numbered.fig']);
%plot traces deconvolved
if isfield(data,'C_df')
    figure;
    set(gcf,'Color','w','Units','normalized','Position',[0 0 1 1]); %sfondo della figura bianco
    for i = 1:data.numero_neuronas
        pos = (mod(i-1,nRighe))*nColumns + 1 + fix((i-1)/nRighe);
        ax = subplot(nRighe,nColumns,pos);
        plot(data.C_df(i,:),'k','linewidth',3);
        set(gca,'visible','off','Box','off','XTick',[],'YTick',[]); %non disegna i box delle figure, gli assi, e i label degli assi
        %     ylabel(num2str(i),
        text(ax,-0.1,0.3,num2str(i),'FontSize',16,'Fontweight','bold','Units','normalized');
        %     legend(num2str(i),'Location','westoutside');
    end
    saveas(gcf,[save_dir, 'C_df_numbered.png']);
    savefig(gcf,[save_dir, 'C_df_numbered.fig']);
end

function correlation_activities_Callback(hObject,eventdata,handles)
%This function plot the correlation matrix between the raw fluorescence
%activities of the ROIs and the correlation matrix between the denoised
%calcium activities of the ROIs
global data;
if ispc
    save_dir = [data.path 'Analyses\'];
else
    save_dir = [data.path 'Analyses/'];
end
if ~exist(save_dir)
    mkdir(save_dir);
end
figure;
%correlation RAW fluorescence
if isfield(data,'Fraw')
    ax1 = subplot(1,2,1); imagesc(corrcoef(data.Fraw'));  caxis([-1 1]); colorbar;
    xlabel('ID ROI'); ylabel('ID ROI');
    title('Corr raw fluorescence'); axis('square');
    csvwrite([save_dir, 'correlationMatrix_Fraw'],corrcoef(data.Fraw'));
else
    ax1 = subplot(1,2,1); imagesc(corrcoef(data.activities_original'));  caxis([-1 1]); colorbar;
    xlabel('ID ROI'); ylabel('ID ROI');
    title('Corr raw fluorescence'); axis('square');
    csvwrite([save_dir, 'correlationMatrix_Fraw'],corrcoef(data.activities_original'));
end
% %correlation C_sp (denoised and demixed)
% ax2 = subplot(1,3,2); imagesc(corrcoef(data.C')); caxis([-1 1]);
% title('Corr demixed fluorescence'); axis('square');
%correlation C_df (denoised, demixed and fitted to model)
if isfield(data,'C_df')
    ax2 = subplot(1,2,2); imagesc(corrcoef(data.C_df')); caxis([-1 1]); colorbar;
    xlabel('ID ROI'); ylabel('ID ROI');
    title('Corr denoised and demixed fluorescence'); axis('square');
    csvwrite([save_dir, 'correlationMatrix_Cdf'],corrcoef(data.C_df'));
end

function raster_plot_Callback(hObject,eventdata,handles)
%this function plot the raster plot of the denoided calcium traces, the
%peaks of those traces, the inferred spike "rate" and a thresholded version
%of the inferred spike "rate"
global data;
if ispc
    save_dir = [data.path 'Analyses\'];
else
    save_dir = [data.path 'Analyses/'];
end
if ~exist(save_dir)
    mkdir(save_dir);
end

figure;
imagesc(data.frameTimes,1:data.numero_neuronas,data.activities); colorbar; %plot C_df
title('DF/F0'); xlabel('time (s)'); ylabel('ROI ID');
csvwrite([save_dir, 'F_df'], data.activities);

if isfield(data,'C_df')
    figure;
    imagesc(data.frameTimes,1:data.numero_neuronas,data.C_df); colorbar; %plot C_df
    title('C\_df'); xlabel('time (s)'); ylabel('ROI ID');
    csvwrite([save_dir, 'C_df'], data.C_df);
end

% Set parameters

function set_projection_parameters_Callback(hObject,eventdata,handles)
%this function plot the raster plot of the denoided calcium traces, the
%peaks of those traces, the inferred spike "rate" and a thresholded version
%of the inferred spike "rate"
global data;

prompt = {'Width avg/DR projection window (s):','Width SLS movie avg window (s):'};
dlgtitle = 'Set GUI projection parameters';
dims = [1 55];
definput = {num2str(data.average_window_choose_roi),num2str(data.running_average_linescan)};
opts.Resize = 'on';
answer = inputdlg(prompt,dlgtitle,dims,definput,opts);
if ~isempty(answer)
    if ~isempty(answer{1})
        data.average_window_choose_roi = str2num(answer{1});
    else
        data.average_window_choose_roi = 2;
    end
    if ~isempty(answer{2})
        data.running_average_linescan = str2num(answer{2});
    else
        data.running_average_linescan = 0.5;
    end
end


function set_motion_parameters_Callback(hObject,eventdata,handles)
%this function plot the raster plot of the denoided calcium traces, the
%peaks of those traces, the inferred spike "rate" and a thresholded version
%of the inferred spike "rate"
global data;

prompt = {'RIGID. Bin width (px):','RIGID. max_shift (px):', 'RIGID. Upsampling factor for subpixel registration:',...
    'RIGID. Template window width (s)',...
    'NON RIGID. Grid width (px):','NON RIGID. Grid height (px):','NON RIGID. Degree of patches upsampling (px):',...
    'NON RIGID. Bin width (px):','NON RIGID. max_shift (px):', 'NON RIGID. Maximum deviation from rigid shift (px):',...
    'NON RIGID. Upsampling factor for subpixel registration:', 'NON RIGID. Template window width (s)'};
dlgtitle = 'Set GUI motion artefacts correction parameters';
dims = [1 60];
definput = {num2str(data.motion_rigid.bin_width),num2str(data.motion_rigid.max_shift),...
    num2str(data.motion_rigid.us_fac), num2str(data.motion_rigid.avg_width),...
    num2str(data.motion_non_rigid.grid_size(1)),...
    num2str(data.motion_non_rigid.grid_size(2)), num2str(data.motion_non_rigid.mot_uf),...
    num2str(data.motion_non_rigid.bin_width), num2str(data.motion_non_rigid.max_shift),...
    num2str(data.motion_non_rigid.max_dev), num2str(data.motion_non_rigid.us_fac),...
    num2str(data.motion_rigid.avg_width)};
opts.Resize = 'on';
answer = inputdlg(prompt,dlgtitle,dims,definput,opts);
if ~isempty(answer)
    if ~isempty(answer{1})
        data.motion_rigid.bin_width = str2num(answer{1});
    else
        data.motion_rigid.bin_width = 50;
    end
    if ~isempty(answer{2})
        data.motion_rigid.max_shift = str2num(answer{2});
    else
        data.motion_rigid.max_shift = 15;
    end
    if ~isempty(answer{3})
        data.motion_rigid.us_fac = str2num(answer{3});
    else
        data.motion_rigid.us_fac = 50;
    end
    if ~isempty(answer{4})
        data.motion_rigid.avg_width = str2num(answer{4});
    else
        data.motion_rigid.avg_width = 10;
    end
    if ~isempty(answer{5})
        if ~isempty(answer{6})
            data.motion_non_rigid.grid_size = [str2num(answer{5}), str2num(answer{6})];
        else
            data.motion_non_rigid.grid_size = [str2num(answer{5}), str2num(answer{5})];
        end
    else
        if ~isempty(answer{6})
            data.motion_non_rigid.grid_size = [str2num(answer{6}), str2num(answer{6})];
        else
            data.motion_non_rigid.grid_size = [64,64];
        end
    end
    if ~isempty(answer{7})
        data.motion_non_rigid.mot_uf = str2num(answer{7});
    else
        data.motion_non_rigid.mot_uf = 4;
    end
    if ~isempty(answer{8})
        data.motion_non_rigid.bin_width = str2num(answer{8});
    else
        data.motion_non_rigid.bin_width = 50;
    end
    if ~isempty(answer{9})
        data.motion_non_rigid.max_shift = str2num(answer{9});
    else
        data.motion_non_rigid.max_shift = 8;
    end
    if ~isempty(answer{10})
        data.motion_non_rigid.max_dev = str2num(answer{10});
    else
        data.motion_non_rigid.max_dev = 4;
    end
    if ~isempty(answer{11})
        data.motion_non_rigid.us_fac = str2num(answer{11});
    else
        data.motion_non_rigid.us_fac = 20;
    end
    if ~isempty(answer{12})
        data.motion_non_rigid.avg_width = str2num(answer{12});
    else
        data.motion_non_rigid.avg_width = 10;
    end
end

function set_segmentation_parameters_Callback(hObject,eventdata,handles)
%this function plot the raster plot of the denoided calcium traces, the
%peaks of those traces, the inferred spike "rate" and a thresholded version
%of the inferred spike "rate"
global data;

prompt = {'Min number of px per ROI:'};
dlgtitle = 'Set segmentation parameters';
dims = [1 55];
definput = {num2str(data.min_px_roi)};
opts.Resize = 'on';
answer = inputdlg(prompt,dlgtitle,dims,definput,opts);
if ~isempty(answer)
    if ~isempty(answer{1})
        data.min_px_roi = str2num(answer{1});
    else
        data.min_px_roi = 5;
    end

end

%Elapsed Time%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function elap_time_Callback(hObject, eventdata, handles)

function elap_time_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%SUPPORT FUNCTIONS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%auxiliary functions%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_movie(handle)
global data
imagen = data.movie_doc.movie_ruido;

if ~isequal(data.mode,'Linescan') && ~isequal(data.mode,'freehand')
    aux = average_slash_max(imagen(data.current_stack,:));
    aux = reshape(aux, data.linesPerFrame,[]);
    data.imagen = aux;
    
    imagen = aux;
else
    aux = data.reference_image;
    data.imagen = aux;
    
    imagen = aux;
end
data.frame_plot = round(get(handle,'value'));
if min(imagen(:))< max(imagen(:))
    data.limites = [min(imagen(:)) max(imagen(:))];
else
    data.limites = [min(imagen(:)) max(imagen(:))+1];
end
set(handle,'value',1)
data.frame_plot = 1;

set(data.handles.imagen,'cdata',imagen)
set(data.handles.axes_handles_imagen,'XTick',[],'YTick',[])

set(data.handles.axes_handles_imagen,'clim',data.limites);
if ~isequal(data.mode,'Linescan') && ~isequal(data.mode,'freehand')
    axis(data.handles.axes_handles_imagen,'image');
    set(data.handles.axes_handles_imagen,...
        'xlim',[0.5 data.pixels_per_line + 0.5],'ylim',[0.5 data.linesPerFrame + 0.5]);
else
    axis(data.handles.axes_handles_imagen,'square');
    set(data.handles.axes_handles_imagen,...
        'xlim',[0.5 size(imagen,2) + 0.5],'ylim',[0.5 size(imagen,1) + 0.5]);
    %     axis(data.handles.axes_handles_imagen,'image');
    %     set(data.handles.axes_handles_imagen,...
    %         'xlim',[0.5 data.pixels_per_line + 0.5],'ylim',[0.5 data.linesPerFrame + 0.5]);
    
end
colormap(data.handles.axes_handles_imagen,gray)

%slider function%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function slider1_Callback(hObject, eventdata, handles)
%just change the frame shown in the GUI figure keeping the ROIs there.
%(XXX it might be better to do this as you do pass_frames (ploting the
%image and bringing it to the bottom)so you dont have to plot everytime the
%ROIs)
global data
data.frame_plot = round(get(handles.slider1,'value'));
data.current_stack = max([data.frame_plot-data.average_window_choose_roi_current,1]):...
    min([data.frame_plot+data.average_window_choose_roi_current,data.duration]);

if ~isequal(data.mode,'Linescan') && ~isequal(data.mode,'freehand')
    imagen = data.movie_doc.movie_ruido;
    
    imagen = imagen(data.frame_plot,:);
    imagen = reshape(imagen,data.linesPerFrame,[]);
    set(data.handles.imagen,'cdata',imagen)
    set(data.handles.axes_handles_imagen,'XTick',[],'YTick',[])
    % set(data.handles.axes_handles_imagen,'xlim',[0.5 data.linesPerFrame + 0.5],'ylim',[0.5 data.pixels_per_line + 0.5]);
    set(data.handles.axes_handles_imagen,'clim',[min(imagen(:)) max(imagen(:))]);
    
    colormap(data.handles.axes_handles_imagen,gray)
    hold(data.handles.axes_handles_imagen,'on')
    if data.prediction_made
        for ind_n=1:data.numero_neuronas
            roi_dots = squeeze(data.roi(ind_n,:,:));
            roi_dots(:,roi_dots(1,:)==0) = [];
            delete(data.handles.outline_rois(ind_n,:))
            data.handles.outline_rois(ind_n,:) = plot(data.handles.axes_handles_imagen,roi_dots(2,:),roi_dots(1,:),'.','markersize',2,'color',data.colores(ind_n,:));
        end
        
        hold(data.handles.axes_handles_imagen,'off')
        
        
    end
else
    %     if isfield(data,'handle_frame_indicator_II')
    %         delete(data.handle_frame_indicator_II)
    %     end
    %     hold(data.handles.axes_handles_imagen,'on')
    %     data.handle_frame_indicator_II = plot(data.handles.axes_handles_imagen,[1,data.pixels_per_line],data.frame_plot*ones(1,2),'color',[1 0 0]);
    %     hold(data.handles.axes_handles_imagen,'off')
end
if isfield(data,'handle_frame_indicator')
    delete(data.handle_frame_indicator)
    
    paso = (max(data.activities(:))-min(data.activities(:)))/2;
    t = min(data.activities(:))-paso:paso:max(data.activities(:))+paso;
    hold(data.handles.axes_handles_activity,'on')
    data.handle_frame_indicator = plot(data.handles.axes_handles_activity,ones(1,numel(t))*data.frameTimes(data.frame_plot),t,'color',[.7 .7 .7]);
    hold(data.handles.axes_handles_activity,'off')
end
set(handles.num_frame_slider,'string',['Scroll frames - current frame: ' num2str(round(get(handles.slider1,'value')))])

%close GUI function%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function figure1_DeleteFcn(hObject, eventdata, handles)
global data
ButtonName = questdlg('did you save the data?', 'Answer!', 'No!', 'Yes!','No!');
if isequal(ButtonName,'No!')
    
    data_original = data;
    
    if isfield(data,'file')
        [filename, pathname, filterindex] = uiputfile( '*.mat','save the data',[data.path data.file(1:end-4) '.mat']);
    else
        [filename, pathname, filterindex] = uiputfile( '*.mat','save the data','NAME.mat');
    end
    if filterindex==0
        return
    end
    if isfield(data,'handles')
        data = rmfield(data,'handles');
    end
    if isfield(data,'line_handles')
        data = rmfield(data,'line_handles');
        data = rmfield(data,'line_bg_handles');
    end
    
    if ~isequal(data.mode,'Linescan') && ~isequal(data.mode,'freehand')
        save([pathname '/' filename(1:end-4) '_rois_for_samples.mat'],'data','-v7.3')
    else
        save([pathname '/' filename],'data','-v7.3')
    end
    data = data_original;
end
recent.size_area_roi = data.size_area_roi;
recent.fluorescence_threshold = data.fluorescence_threshold;
recent.path = data.path;%#ok<STRNU>
save('recent','recent')
clear -global data

%listbox function%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function neurons_list_Callback(hObject, eventdata, handles)
%just change the frame shown in the GUI figure keeping the ROIs there.
%(XXX it might be better to do this as you do pass_frames (ploting the
%image and bringing it to the bottom)so you dont have to plot everytime the
%ROIs)
global data
neurona_elegida = get(handles.neurons_list,'value');
if data.neurona_elegida == neurona_elegida
    if data.figure_activities~=0
        set(0,'currentFigure',data.figure_activities)
        if data.CNMF == 1
            timing = squeeze(data.pixelsTimes(data.neurona_elegida,:));
            subplot(2,3,[1,4]);
            imagesc(data.imagen); colormap(gray); hold on;...
                contour(reshape(data.A(:,neurona_elegida)>0,size(data.imagen)),'r');...
                axis('image'); title(['ROI n. ', num2str(neurona_elegida)]);
            subplot(2,3,[2,3]);...
                plot(timing, (data.activities_original(neurona_elegida,:)-...
                mean(data.activities_original(neurona_elegida,:)))/...
                std(data.activities_original(neurona_elegida,:)),'k','linewidth',2 );...
                xlim([timing(1), timing(end)]);...
                title(['Mean fluorescence trace']);...
                xlabel('time (s)'); ylabel('Zscores');
            subplot(2,3,[5,6]);...
                plot(timing, (data.activities_deconvolved(neurona_elegida,:)-...
                mean(data.activities_deconvolved(neurona_elegida,:)))/...
                std(data.activities_deconvolved(neurona_elegida,:)),'r','linewidth',2 );...
                xlim([timing(1), timing(end)]);
            title(['Calcium florescence generated trace']);...
                xlabel('time (s)'); ylabel('Zscores');
        else
            hold on
            timing = squeeze(data.pixelsTimes(data.neurona_elegida,:));
            activity = data.activities(data.neurona_elegida,:)-mean(data.activities(data.neurona_elegida,:));
            plot(timing,activity,'linewidth',2)
            hold off
        end
    else
        tam_screen = get(0,'ScreenSize');
        %this is the figure in which ROIs will be drawn
        data.figure_activities = figure('CloseRequestFcn',@close_fnc_neurons_activities,'OuterPosition',[10 10 tam_screen(3) tam_screen(4)]);
        
        if data.CNMF == 1
            timing = squeeze(data.pixelsTimes(data.neurona_elegida,:));
            subplot(2,3,[1,4]);...
                imagesc(data.imagen); colormap(gray); hold on;...
                contour(reshape(data.A(:,neurona_elegida)>0,size(data.imagen)),'r');...
                axis('image'); title(['ROI n. ', num2str(neurona_elegida)]);
            subplot(2,3,[2,3]);...
                plot(timing, (data.activities_original(neurona_elegida,:)-...
                mean(data.activities_original(neurona_elegida,:)))/...
                std(data.activities_original(neurona_elegida,:)),'k','linewidth',2 );...
                xlim([timing(1), timing(end)]);...
                title(['Mean fluorescence trace']);...
                xlabel('time (s)'); ylabel('Zscores');
            subplot(2,3,[5,6]);...
                plot(timing, (data.activities_deconvolved(neurona_elegida,:)-...
                mean(data.activities_deconvolved(neurona_elegida,:)))/...
                std(data.activities_deconvolved(neurona_elegida,:)),'r','linewidth',2 );...
                xlim([timing(1), timing(end)]);
            title(['Calcium florescence generated trace']);...
                xlabel('time (s)'); ylabel('Zscores');
        else
            
            timing = squeeze(data.pixelsTimes(data.neurona_elegida,:));
            activity = data.activities(data.neurona_elegida,:)-mean(data.activities(data.neurona_elegida,:));
            plot(timing,activity,'linewidth',2)
        end
        
        if isfield(data,'stimulus')
            hold on
            for ind=1:numel(data.stimulus{1})
                plot(data.stimulus{1}(ind)*ones(1,2)/1000,[min(activity) max(activity)],'--k')
            end
            hold off
        end
    end
    
else
    s = findobj(data.handles.axes_handles_imagen,'color',[1 0 0]);
    if ~isempty(s)
        delete(s)
    end
    hold(data.handles.axes_handles_imagen,'on')
    roi_dots = squeeze(data.roi(neurona_elegida,:,:));
    roi_dots(:,roi_dots(1,:)==0) = [];
    plot(data.handles.axes_handles_imagen,roi_dots(2,:),roi_dots(1,:),'*','color',[1 0 0]);
    hold(data.handles.axes_handles_imagen,'off')
    
    s = findobj(data.handles.axes_handles_activity,'color',[1 0 0]);
    if ~isempty(s)
        delete(s)
    end
    hold(data.handles.axes_handles_activity,'on')
    if data.CNMF == 1
        activity = squeeze(data.activities_deconvolved(neurona_elegida,:));
        %         activity = squeeze(data.activities(neurona_elegida,:));
    else
        activity = squeeze(data.activities(neurona_elegida,:));
    end
    timing = squeeze(data.pixelsTimes(neurona_elegida,:));
    plot(data.handles.axes_handles_activity,timing,activity,'color',[1 0 0],'linewidth',2);
    hold(data.handles.axes_handles_activity,'off')
end
data.neurona_elegida = neurona_elegida;

function close_fnc_neurons_activities(~,~)
global data
data.figure_activities = 0;
delete(gcf)

% --- Executes during object creation, after setting all properties.
function neurons_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to neurons_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function slider1_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


