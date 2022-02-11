%demo of data processing (raster)

%% add some functions to Matlab path
if ispc
    addpath(genpath('.\CaImAn-MATLAB-master'));
    addpath(genpath('.\utilities'));
    addpath(genpath('.\NoRMCorre-master'));
else
    addpath(genpath('./CaImAn-MATLAB-master'));
    addpath(genpath('./utilities'));
    addpath(genpath('./NoRMCorre-master'));
end

%% set files to use
if ispc
    import_TS_path = '.\ex_raster_tiff_movie.tiff';
    import_TS_xml = '.\ex_raster_tiff_movie.xml';
    reference_segmentation = '.\ex_raster_ROIs.mat';
else
    import_TS_path = '/Users/monica/Documents/Monica/lineScan/linescan/archivio/2018 01 28/t4baseline-881';%/MotionCorrection/movieCorrectedNonRigid.tif';%'./ex_raster_tiff_movie.tiff';
    import_TS_xml = '/Users/monica/Documents/Monica/lineScan/linescan/archivio/2018 01 28/t4baseline-881/t4baseline-881.xml';%'./ex_raster_tiff_movie.xml';
    reference_segmentation = '/Users/monica/Documents/Monica/lineScan/linescan/archivio/2018 01 28/t4baseline-881/segementation_post.mat';%'./ex_raster_ROIs.xml';
end

%% initialize data structure
options.mode = 'raster';
data = inizialize_data(import_TS_path,options);

%% extract info from .xml
data = extract_metadata_raster(data,import_TS_xml);

%% load TS
single_tiff = 0;
data = import_raster_tiff(data,import_TS_path,single_tiff);
%plot average projection
figure;
imagesc(nanmean(reshape(data.movie_doc.movie_ruido',data.linesPerFrame,data.pixels_per_line,[]),3));
colormap('gray'); colorbar;

%% import ROIs
flag_align_ROIs = 1;
data = import_and_align_ROIs(data,reference_segmentation,flag_align_ROIs);
%plot ROIs and activities
figure;
subplot(2,1,1);
plot_contours(1*(data.A>0),data.CNimage,1,1);
colormap(gca,'gray'); colorbar;
subplot(2,1,2);
if isfield(data,'C_df')
    imagesc(data.frameTimes,[], data.C_df); colormap(gca,'jet'); colorbar;
else
    imagesc(data.frameTimes,[], data.activities); colormap(gca,'jet'); colorbar;
end
xlabel('time (s)'); ylabel('ROIs ID');

%% draw SLS
traj_choice = 'half of the pixels';
surround_px = 2;
%build scan trajectory that passes through all ROIs
[scan_traj, neurons_tags, data] = build_SLS_trajectory(data,traj_choice);
figure;
imagen = max(data.movie_doc.movie_ruido(1:data.duration,:),[],1);
imagen = reshape(imagen, data.linesPerFrame,[]);
imagesc(imagen); colormap('gray');
hold on;
plot(scan_traj(2,:),scan_traj(1,:),'-','color','y');
%add surround to each ROI
data = select_surround_px(data,surround_px);
data = update_SLS_trajectory(data);
figure;
imagesc(imagen); colormap('gray');
hold on;
plot(data.scan_traj(2,:),data.scan_traj(1,:),'-','color','m');
distancia =  sum(sqrt(diff(data.scan_traj(1,:)).^2 + diff(data.scan_traj(2,:)).^2));
title(num2str(distancia));
%add reference box at the end of trajectory
box_center = [125 125]; %ref box center
box_size = 20; %ref box half size
data = add_box(data,box_center,box_size);
figure;
imagesc(imagen); colormap('gray');
hold on;
plot(data.scan_traj(2,:),data.scan_traj(1,:),'-','color','m');
distancia =  sum(sqrt(diff(data.scan_traj(1,:)).^2 + diff(data.scan_traj(2,:)).^2));
title(num2str(distancia));

if ispc
    save_dir = [data.path 'SLS_trajectory\'];
else
    save_dir = [data.path 'SLS_trajectory/'];
end
save_SLS_trajectory(data,save_dir);
