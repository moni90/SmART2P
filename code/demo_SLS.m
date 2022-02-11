% demo SLS import and processing
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
    import_TS_path = '.\ex_SLS_dir';
    import_TS_xml = '.\ex_SLS_movie.xml';
    reference_segmentation = '.\ex_segmentation_ROIs.mat';
else
%     import_TS_path = '/media/DATA/mmoroni/software_sls_project/data/awake/2017_06_07/traj1-642/';%/MotionCorrection/movieCorrectedNonRigid.tif';%'./ex_SLS_dir';
%     import_TS_xml = '/media/DATA/mmoroni/software_sls_project/data/awake/2017_06_07/traj1-642/traj1-642.xml';%'./ex_SLS_movie.xml';
%     reference_segmentation = '/media/DATA/mmoroni/software_sls_project/data/awake/2017_06_07/ref3-2625.mat';%'./ex_segmentation_ROIs.mat';
%     import_TS_path = '/media/DATA/mmoroni/software_sls_project/data/awake/2017_06_07/traj9 rota surround largo-650/';%/MotionCorrection/movieCorrectedNonRigid.tif';%'./ex_SLS_dir';
%     import_TS_xml = '/media/DATA/mmoroni/software_sls_project/data/awake/2017_06_07/traj9 rota surround largo-650/traj9 rota surround largo-650.xml';%'./ex_SLS_movie.xml';
%     reference_segmentation = '/media/DATA/mmoroni/software_sls_project/data/awake/2017_06_07/ref7 rota-2629.mat';%'./ex_segmentation_ROIs.mat';
    import_TS_path = '/media/DATA/mmoroni/software_sls_project/data/anesthetized/2017_12_28/ls8stim8surr3-151/';
    import_TS_xml = '/media/DATA/mmoroni/software_sls_project/data/anesthetized/2017_12_28/ls8stim8surr3-151/ls8stim8surr3-151.xml';
    reference_segmentation = '/media/DATA/mmoroni/software_sls_project/data/anesthetized/2017_12_28/ls5stim5surr0-147/reference_post.mat';
end

%% initialize data structure
options.mode = 'freehand';
data = inizialize_data(import_TS_path,options);

%% extract info from .xml
data = extract_metadata_sls(data,import_TS_xml);

%% import SLS acquisition
num_frames = NaN;%NaN; %NaN for all
data = import_sls_tiff(data,num_frames);

%% register ROIs from reference segmentation
data = register_ROIs_ls(data,reference_segmentation);

%% process data
process_flag = 'Yes';
process_opt.large_artefacts = 'Yes';
process_opt.ref_box = 'Yes';
process_opt.down_rate = 2;
process_opt.background = 'Yes'; %'no'
process_opt.local = 'NoRMCorr'; %'no','NoRMCorr','SNR'
process_opt.neuropil = 'No'; %'surround','PCA'
if strcmp(process_flag, 'Yes')
    [data, ~] = sls_large_artefacts_PCA(data, process_opt); %detect large artefacts and CUT acquisition if necessary
    [rois_f_raw,neuropil_raw,snr_raw] = extract_ls_fluo(data.movie_doc.movie_ruido', ...
        data.A, data.ring, data.surrounding, data.framePeriod);
    [movie_no_backgr,backgr_m] = sls_subtract_background(data,process_opt);
    figure;
    subplot(2,1,1);
    imagesc(data.frameTimes,[],data.movie_doc.movie_ruido'); colorbar;
    xlabel('time (s)'); ylabel('pixels');
    subplot(2,1,2);
    imagesc(data.frameTimes,[],movie_no_backgr); colorbar;
    xlabel('time (s)'); ylabel('pixels');
    switch process_opt.local
        case 'No'
            [rois_f_correct,neuropil,snr_correct] = extract_ls_fluo(movie_no_backgr, data.A, data.ring, data.surrounding, data.framePeriod);
            framePeriod = data.framePeriod;
        case 'SNR'
            [rois_f0, rois_f_correct, neuropil0, neuropil, snr0, snr_correct] = reassign_px_snr(movie_no_backgr, data.A, data.ring, data.surrounding, data.framePeriod);
            framePeriod = data.framePeriod;
            if ~strcmp(process_opt.neuropil,'No')
                neuropil = zeros(size_f);
            end
        case 'NoRMCorr'
            n_rows = size(data.reference_image,1);
            n_col = size(data.reference_image,2);
            scan_path = data.freehand_scan;
            [time_down, movie_down, rois_f0_down, rois_f_correct, neuropil0_down, neuropil,...
                snr0_down, snr_correct] = reassign_px_NoRM(movie_no_backgr',...
                data.A, data.ring, data.surrounding, process_opt.down_rate,...
                n_rows, n_col, scan_path, data.framePeriod);
            framePeriod = data.framePeriod*round(1/(data.framePeriod*process_opt.down_rate));
    end
    if strcmp(process_opt.neuropil,'No')
        rois_f_def = rois_f_correct;
        snr_def = snr_correct;
    else
        [rois_neuro_ring,snr_ring,rois_neuro_pca,neuropil_pca, snr_pca] = subtract_neuropil_local(rois_f_correct, neuropil, framePeriod);
        if strcmp(process_opt.neuropil,'surround')
            rois_f_def = rois_neuro_ring;
            snr_def = snr_ring;
        elseif strcmp(process_opt.neuropil,'PCA')
            rois_f_def = rois_neuro_pca;
            snr_def = snr_pca;
        end
    end
    data = sls_deconvolution(movie_no_backgr,data,rois_f_def,rois_f_raw,framePeriod);
else
    [rois_f_raw,neuropil_raw,snr_raw] = extract_ls_fluo(data.movie_doc.movie_ruido',...
        data.A, data.ring, data.surround, data.framePeriod);
    data.Fraw = rois_f_raw;

end

figure;
if isfield(data,'C_df') && ~isempty(data.C_df)
    subplot(2,1,1);
    imagesc(data.frameTimes,[],data.Fraw); colorbar;
    xlabel('time'); ylabel('ROIs'); title('Raw fluorescence');
    subplot(2,1,2);
    imagesc(data.frameTimes,[],data.C_df); colorbar;
    xlabel('time'); ylabel('ROIs'); title('Deconvolved calcium activity');
else
    imagesc(data.frameTimes,[],data.Fraw); colorbar;
    xlabel('time'); ylabel('ROIs'); title('Raw fluorescence');
end