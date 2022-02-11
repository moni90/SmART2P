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
process_opt.down_rate = 0.1;
process_opt.background = 'Yes'; %'no'
process_opt.local = 'No'; %'no','NoRMCorr','SNR'
process_opt.neuropil = 'No'; %'surround','PCA'
if strcmp(process_flag, 'Yes')
    [data, ~] = sls_large_artefacts_PCA(data, process_opt); %detect large artefacts and CUT acquisition if necessary
    [rois_f_raw,neuropil_raw,snr_raw] = extract_ls_fluo(data.movie_doc.movie_ruido', ...
        data.A, data.ring, data.surrounding, data.framePeriod);
    data_raw = sls_deconvolution(data.movie_doc.movie_ruido',data,rois_f_raw,rois_f_raw,data.framePeriod);
    rois_ca_raw = data_raw.C_df;
    [movie_no_backgr,backgr_m] = sls_subtract_background(data,process_opt);
    figure;
    subplot(2,1,1);
    imagesc(data.frameTimes,[],data.movie_doc.movie_ruido'); colorbar;
    xlabel('time (s)'); ylabel('pixels');
    subplot(2,1,2);
    imagesc(data.frameTimes,[],movie_no_backgr); colorbar;
    xlabel('time (s)'); ylabel('pixels');

    
    [rois_f_noback,neuropil_noback,snr_noback] = extract_ls_fluo(movie_no_backgr, data.A, data.ring, data.surrounding, data.framePeriod);
    framePeriod_noback = data.framePeriod;
    data_noback = sls_deconvolution(movie_no_backgr,data,rois_f_noback,rois_f_noback,framePeriod_noback);
    rois_ca_noback = data_noback.C_df;
    
    figure;
    subplot(2,1,1);
    imagesc(data.frameTimes,[],rois_f_raw); colorbar; caxis([0, max([rois_f_raw(:); rois_f_noback(:)])])
    xlabel('time (s)'); ylabel('ROIs');
    subplot(2,1,2);
    imagesc(data.frameTimes,[],rois_f_noback); colorbar; caxis([0, max([rois_f_raw(:); rois_f_noback(:)])])
    xlabel('time (s)'); ylabel('ROIs');
    
    figure;
    subplot(2,1,1);
    imagesc(corr(rois_f_raw')); colorbar; caxis([-1,1]);
    xlabel('ROI ID'); ylabel('ROI ID');
    subplot(2,1,2);
    imagesc(corr(rois_f_noback')); colorbar; caxis([-1,1]);
    xlabel('ROI ID'); ylabel('ROI ID');
    
    figure;
    subplot(2,1,1);
    imagesc(data.frameTimes,[],rois_ca_raw); colorbar; caxis([0, max([rois_ca_raw(:); rois_ca_noback(:)])])
    xlabel('time (s)'); ylabel('ROIs');
    subplot(2,1,2);
    imagesc(data.frameTimes,[],rois_ca_noback); colorbar; caxis([0, max([rois_ca_raw(:); rois_ca_noback(:)])])
    xlabel('time (s)'); ylabel('ROIs');
    
    figure;
    subplot(2,1,1);
    imagesc(corr(rois_ca_raw')); colorbar; caxis([-1,1]);
    xlabel('ROI ID'); ylabel('ROI ID');
    subplot(2,1,2);
    imagesc(corr(rois_ca_noback')); colorbar; caxis([-1,1]);
    xlabel('ROI ID'); ylabel('ROI ID');
    
    process_opt.local = 'SNR';
    [rois_f0, rois_f_SNR, neuropil0, neuropil_SNR, snr0, snr_SNR] = reassign_px_snr(movie_no_backgr, data.A, data.ring, data.surrounding, data.freehand_scan, data.framePeriod);
    framePeriod_SNR = data.framePeriod;
    data_SNR = sls_deconvolution(movie_no_backgr,data,rois_f_SNR,rois_f_noback,framePeriod_SNR);
    rois_ca_SNR = data_SNR.C_df;
    %     if ~strcmp(process_opt.neuropil,'No')
    %         neuropil = zeros(size_f);
    %     end
    process_opt.local = 'NoRMCorr';
    n_rows = size(data.reference_image,1);
    n_col = size(data.reference_image,2);
    scan_path = data.freehand_scan;
    [time_down, movie_down, rois_f0_down, rois_f_NoRM, neuropil0_down, neuropil_NoRM,...
        snr0_down, snr_NoRM] = reassign_px_NoRM(movie_no_backgr',...
        data.A, data.ring, data.surrounding, process_opt.down_rate,...
        n_rows, n_col, scan_path, data.framePeriod);
    framePeriod_NoRM = data.framePeriod*round(1/(data.framePeriod*process_opt.down_rate));
    %downsample the movie
    SLS_rate = 1/data.framePeriod;
    down_fact = round(SLS_rate/process_opt.down_rate);
    down_period_true = data.framePeriod*down_fact;
    movie_avg = movmean(movie_no_backgr,down_fact,1);
    movie_down = movie_avg(:,1:down_fact:end);
    rois_f_noback_avg = movmean(rois_f_noback,down_fact,2);
    rois_f_noback_down = rois_f_noback_avg(:,1:down_fact:end);
    data_NoRM = sls_deconvolution(movie_down,data,rois_f_NoRM,rois_f_noback_down,framePeriod_NoRM);
    rois_ca_NoRM = data_NoRM.C_df;
    
    figure;
    subplot(3,1,1); imagesc(data.frameTimes,[],rois_f_noback); colorbar; title('no reassigment'); caxis([0, max([rois_f_noback(:); rois_f_SNR(:); rois_f_NoRM(:)])])
    subplot(3,1,2); imagesc(data.frameTimes,[],rois_f_SNR); colorbar; title('SNR-based reassigment'); caxis([0, max([rois_f_noback(:); rois_f_SNR(:); rois_f_NoRM(:)])])
    subplot(3,1,3); imagesc(time_down,[],rois_f_NoRM); colorbar; title('NoRMCorr-based reassigment'); caxis([0, max([rois_f_noback(:); rois_f_SNR(:); rois_f_NoRM(:)])])
    
    figure;
    plot([snr_noback(:) snr_SNR(:) snr_NoRM(:)]','-o'); xlabel('ROI'); ylabel('SNR');
    legend('no reassignment','SNR-based px reassignment','NoRMCorr-based reassignment');
    figure;
    scatter(snr_noback(:), snr_SNR(:));
    hold on; plot(0:1:ceil(max([snr_noback(:); snr_SNR(:)])),0:1:ceil(max([snr_noback(:); snr_SNR(:)])),'--k');
    xlabel('no reassignment'); ylabel('SNR-based px reassignment');
    figure;
    scatter(snr_noback(:), snr_NoRM(:));
    hold on; plot(0:1:ceil(max([snr_noback(:); snr_NoRM(:)])),0:1:ceil(max([snr_noback(:); snr_NoRM(:)])),'--k');
    xlabel('no reassignment'); ylabel('NoRMCorr-based px reassignment');
    
    figure;
    subplot(3,1,1); imagesc(data.frameTimes,[],rois_ca_noback); colorbar; title('no reassigment'); caxis([0, max([rois_ca_noback(:); rois_ca_SNR(:); rois_ca_NoRM(:)])])
    subplot(3,1,2); imagesc(data.frameTimes,[],rois_ca_SNR); colorbar; title('SNR-based reassigment'); caxis([0, max([rois_ca_noback(:); rois_ca_SNR(:); rois_ca_NoRM(:)])])
    subplot(3,1,3); imagesc(time_down,[],rois_ca_NoRM); colorbar; title('NoRMCorr-based reassigment'); caxis([0, max([rois_ca_noback(:); rois_ca_SNR(:); rois_ca_NoRM(:)])])
    
    snr_ca_noback = zeros(size(rois_ca_noback,1),1);
    snr_ca_SNR = zeros(size(rois_ca_noback,1),1);
    snr_ca_NoRM = zeros(size(rois_ca_noback,1),1);
    for id_roi = 1:size(rois_ca_noback,1)
        snr_ca_noback(id_roi) = 10^(snr(rois_ca_noback(id_roi,:),rois_f_noback(id_roi,:)-rois_ca_noback(id_roi,:))/10);
        snr_ca_SNR(id_roi) = 10^(snr(rois_ca_SNR(id_roi,:),rois_f_SNR(id_roi,:)-rois_ca_SNR(id_roi,:))/10);
        snr_ca_NoRM(id_roi) = 10^(snr(rois_ca_NoRM(id_roi,:),rois_f_NoRM(id_roi,:)-rois_ca_NoRM(id_roi,:))/10);
    end
    
    figure;
    plot([snr_ca_noback(:) snr_ca_SNR(:) snr_ca_NoRM(:)],'-o'); xlabel('ROI'); ylabel('SNR deconvolved');
    legend('no reassignment','SNR-based px reassignment','NoRMCorr-based reassignment');
    figure;
    scatter(snr_ca_noback(:), snr_ca_SNR(:));
    hold on; plot(0:1e-12:max([snr_ca_noback(:); snr_ca_SNR(:)]),0:1e-12:max([snr_ca_noback(:); snr_ca_SNR(:)]),'--k');
    xlabel('no reassignment'); ylabel('SNR-based px reassignment');
    figure;
    scatter(snr_ca_noback(:), snr_ca_NoRM(:));
    hold on; plot(0:1e-12:max([snr_ca_noback(:); snr_ca_NoRM(:)]),0:1e-12:max([snr_ca_noback(:); snr_ca_NoRM(:)]),'--k');
    xlabel('no reassignment'); ylabel('NoRMCorr-based px reassignment');

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