function [data] = process_ls_data(data,process_flag)

if strcmp(process_flag,'Yes')
    save_figs_quest_dlg = questdlg('Would you like to save intermediate figures?',...
        'Save intermediate figures','Yes','No','No');
    switch save_figs_quest_dlg
        case 'Yes'
            data.save_all_figs = 1;
            save_path = fullfile(data.path, 'Analyses');
            if ~exist(save_path)
                mkdir(save_path);
            end
        case 'No'
            data.save_all_figs = 0;
    end
    data.CNMF=1;
    %estimate large motion artefacts using PCA
    %ask the user whether to use the reference box
    ref_box_quest_dlg = questdlg('Would you like to use the reference box?',...
        'Reference box','Yes','No','No');
    switch ref_box_quest_dlg
        case 'Yes'
            options.ref_box = 'Yes';
            prompt = {'Enter downsampled rate'};
            dlg_title = ['Frame rate = ' num2str(1/data.framePeriod)];
            num_lines = 1;
            defaultans = {'0','0'};
            answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
            down_rate = str2double(answer{1});
            if down_rate==0 || down_rate>1/data.framePeriod
                down_rate = 1/data.framePeriod;
            end
            options.down_rate = down_rate;
        case 'No'
            options.ref_box = 'No';
    end
    fig_loading = uifigure;
    d = uiprogressdlg(fig_loading,'Title','Detecting large artefacts',...
        'Indeterminate','on');
    drawnow
    [data, ~, pca_motion_fig, ref_box_fig, motion_fig] = sls_large_artefacts_PCA(data, options);
    
    if data.save_all_figs
        saveas(pca_motion_fig,fullfile(save_path, 'SLS_large_artefacts_PC1.png'));
        savefig(pca_motion_fig,fullfile(save_path, 'SLS_large_artefacts_PC1.fig'));
        if ~isempty(ref_box_fig)
            saveas(ref_box_fig,fullfile(save_path, 'SLS_reference_box.png'));
            savefig(ref_box_fig,fullfile(save_path, 'SLS_reference_box.fig'));
        end
        if ~isempty(motion_fig)
            saveas(motion_fig,fullfile(save_path, 'SLS_large_artefacts_NoRMCorre.png'));
            savefig(motion_fig,fullfile(save_path, 'SLS_large_artefacts_NoRMCorre.fig'));
        end
    end
    
    
    close(d)
    close(fig_loading)
    close(pca_motion_fig)
    if ~isempty(ref_box_fig)
        close(ref_box_fig)
    end
    if ~isempty(motion_fig)
        close(motion_fig)
    end
    
    %global data;
    movie = data.movie_doc.movie_ruido';
    rois_px = data.A;
    surrounding_px = data.surrounding;
    ring_px = data.ring;
    neuropil_px = data.neuropil;
    
    %extract raw traces
    [rois_f_raw,neuropil_raw,snr_raw] = extract_ls_fluo(movie, rois_px, ring_px, surrounding_px, data.framePeriod);
    
    %subtract background activity (activity in px far from ROIs) and let the
    %user select the activity to use for further processing 
    fig_loading = uifigure;
    d = uiprogressdlg(fig_loading,'Title','Background activity estimate',...
        'Indeterminate','on');
    drawnow
    [movie_temp, backgr_temp] = subtract_neuropil_global(movie, neuropil_px);
    fig_backgr = figure('Units', 'Normalized', 'OuterPosition', [0.1 0.1 0.8 0.8]);
    subplot(3,1,1); imagesc(data.frameTimes,[],movie); colorbar;
    xlabel('time (s)'); ylabel('trajectory px'); title('Raw activity');
    subplot(3,1,2); plot(data.frameTimes,backgr_temp); colorbar;
    xlabel('time (s)'); ylabel('Background PC'); title('Background activity estimate');
    xlim([data.frameTimes(1), data.frameTimes(end)])
    subplot(3,1,3); imagesc(data.frameTimes,[],movie_temp); colorbar;
    xlabel('time (s)'); ylabel('trajectory px'); title('Background subtracted activity');
    if data.save_all_figs
        saveas(fig_backgr,fullfile(save_path, 'SLS_background_subtraction.png'));
        savefig(fig_backgr,fullfile(save_path, 'SLS_background_subtraction.fig'));
    end
    close(d)
    close(fig_loading)

    background_quest_dlg = questdlg('Would you like to subtract the background activity?',...
        'Background','No','Yes','Yes');
    close(fig_backgr)
    switch background_quest_dlg
        case 'No'
            movie_no_backgr = movie;
            backgr_m = zeros(size(movie,2),1);
        case 'Yes'
            movie_no_backgr = movie_temp;
            backgr_m = backgr_temp;
            clear movie_temp; clear backgr_temp;
    end
    
    %reassign px to ROIs using a criterion based on SNR and, if exist, the
    %motion estimated in the reference box
    fig_loading = uifigure;
    d = uiprogressdlg(fig_loading,'Title','Local motion artefacts correction',...
        'Indeterminate','on');
    drawnow
    [rois_f,neuropil,snr] = extract_ls_fluo(movie_no_backgr, rois_px, ring_px, surrounding_px,data.framePeriod);
    [rois_f0, rois_f_SNR, neuropil0, neuropil_SNR, snr0, snr_SNR] = reassign_px_snr(movie_no_backgr, rois_px, ring_px, surrounding_px, data.freehand_scan, data.framePeriod);
    if strcmp(options.ref_box,'Yes')
        n_rows = size(data.reference_image,1);
        n_col = size(data.reference_image,2);
        scan_path = data.freehand_scan;
        [time_down, movie_down, rois_f0_down, rois_f_NoRM, neuropil0_down, neuropil_NoRM, snr0_down, snr_NoRM, ~, ~, ref_box_fig, motion_fig] = reassign_px_NoRM_keep_rate(movie_no_backgr', rois_px, ring_px, surrounding_px, down_rate, n_rows, n_col, scan_path, data.framePeriod);
        close(ref_box_fig);
        close(motion_fig);
         
        fig_local_mot = figure('Units', 'Normalized', 'OuterPosition', [0.1 0.1 0.8 0.8]);
        subplot(4,1,1); imagesc(data.frameTimes,[],rois_f); colorbar;
        xlabel('time (s)'); ylabel('ROIs'); title('no reassigment');
        subplot(4,1,2); imagesc(data.frameTimes,[],rois_f_SNR); colorbar;
        xlabel('time (s)'); ylabel('ROIs'); title('SNR-based reassigment');
        subplot(4,1,3); imagesc(time_down,[],rois_f_NoRM); colorbar;
        xlabel('time (s)'); ylabel('ROIs'); title('NoRMCorr-based reassigment');
        subplot(4,1,4); plot([snr(:) snr_SNR(:) snr_NoRM(:)],'-o'); xlabel('ROI'); ylabel('SNR');
        legend('no reassignment','SNR-based px reassignment','NoRMCorr-based reassignment');
    else
        fig_local_mot = figure('Units', 'Normalized', 'OuterPosition', [0.1 0.1 0.8 0.8]);
        subplot(3,1,1); imagesc(data.frameTimes,[],rois_f); colorbar;
        xlabel('time (s)'); ylabel('ROIs'); title('no reassigment');
        subplot(3,1,2); imagesc(data.frameTimes,[],rois_f_SNR); colorbar;
        xlabel('time (s)'); ylabel('ROIs'); title('SNR-based reassigment');
        subplot(3,1,3); plot([snr(:) snr_SNR(:)],'-o'); xlabel('ROI'); ylabel('SNR');
        legend('no reassignment','SNR-based px reassignment');
    end
    if data.save_all_figs
        saveas(fig_local_mot,fullfile(save_path, 'SLS_local_artefacts.png'));
        savefig(fig_local_mot,fullfile(save_path, 'SLS_local_artefacts.fig'));
    end
    close(d)
    close(fig_loading)
    local_mot_quest_dlg = questdlg('Would you like to correct locally for small artefacts?',...
        'Local motion','No','Yes, use SNR','Yes, use NoRMCorre on ref box','No');
    close(fig_local_mot)
    
    fig_loading = uifigure;
    d = uiprogressdlg(fig_loading,'Title','Local neuropil subtraction',...
        'Indeterminate','on');
    drawnow
    switch local_mot_quest_dlg
        case 'No'
            rois_def = rois_f;
            snr_def = snr;
            [rois_neuro_ring,snr_ring,rois_neuro_pca,neuropil_pca, snr_pca] = subtract_neuropil_local(rois_def, neuropil, data.framePeriod);
            linePeriod = data.framePeriod;
        case 'Yes, use SNR'
            rois_def = rois_f_SNR;
            snr_def = snr_SNR;
            [rois_neuro_ring,snr_ring,rois_neuro_pca,neuropil_pca, snr_pca] = subtract_neuropil_local(rois_def, neuropil_SNR, data.framePeriod);
            linePeriod = data.framePeriod;
        case 'Yes, use NoRMCorre on ref box'
            rois_def = rois_f_NoRM;
            snr_def = snr_NoRM;
            [rois_neuro_ring,snr_ring,rois_neuro_pca,neuropil_pca, snr_pca] = subtract_neuropil_local(rois_def, neuropil_NoRM, data.framePeriod*round(1/(data.framePeriod*down_rate)));
            linePeriod = data.framePeriod*round(1/(data.framePeriod*down_rate));
    end
    close(d)
    close(fig_loading)
    
    fig_local_neuropil = figure('Units', 'Normalized', 'OuterPosition', [0.1 0.1 0.8 0.8]);
    subplot(4,1,1); imagesc(rois_def); colorbar;
    xlabel('time (s)'); ylabel('ROIs'); title('No neuropil subtraction');
    subplot(4,1,2); imagesc(rois_neuro_ring); colorbar;
    xlabel('time (s)'); ylabel('ROIs'); title('Neuropil surround (Chen)');
    subplot(4,1,3); imagesc(rois_neuro_pca); colorbar;
    xlabel('time (s)'); ylabel('ROIs'); title('Neuropil PCA');
    subplot(4,1,4); plot([snr_def(:) snr_ring(:) snr_pca(:)],'-o');
    xlabel('time (s)'); ylabel('ROIs'); xlabel('ROI'); ylabel('SNR');
    legend('No neuropil subtraction','Neuropil surround (Chen)','Neuropil PCA');
    if data.save_all_figs
        saveas(fig_local_neuropil,fullfile(save_path, 'SLS_local_neuropil.png'));
        savefig(fig_local_neuropil,fullfile(save_path, 'SLS_local_neuropil.fig'));
    end
    
    neuropil_quest_dlg = questdlg('Would you like to subtract the neuropil?',...
        'Neuropil','No','Yes, use surround','Yes, use PCA','No');
    close(fig_local_neuropil)
    switch neuropil_quest_dlg
        case 'No'
            rois_no_neuropil = rois_def;
        case 'Yes, use surround'
            rois_no_neuropil = rois_neuro_ring;
        case 'Yes, use PCA'
            rois_no_neuropil = rois_neuro_pca;
    end
    
    fig_loading = uifigure;
    d = uiprogressdlg(fig_loading,'Title','Denoising and deconvolving final activity',...
        'Indeterminate','on');
    drawnow
    data = sls_deconvolution(movie_no_backgr,data,rois_no_neuropil,rois_f_raw,linePeriod);
    close(d)
    close(fig_loading)
else
    %global data;
    movie = data.movie_doc.movie_ruido';
    rois_px = data.A;
    surrounding_px = data.surrounding;
    ring_px = data.ring;
    neuropil_px = data.neuropil;

    data.CNMF=0;
    %extract raw traces
    [rois_f_raw,neuropil_raw,snr_raw] = extract_ls_fluo(movie, rois_px, ring_px, surrounding_px,data.framePeriod);
    data.Fraw = rois_f_raw;
end

baseline = mean(data.Fraw(data.Fraw<median(data.Fraw,2)));
data.activities = (data.Fraw-baseline)./baseline;
data.activities_original = data.Fraw;
if isfield(data,'C_df') && ~isempty(data.C_df)
    data.activities_deconvolved = data.C_df;
end
for ind_n=1:data.numero_neuronas
    pixels_delays = find(rois_px(:,ind_n))*data.dwellTime;
    data.pixelsTimes(ind_n,:) = mean(repmat(data.frameTimes',1,length(pixels_delays)) +...
        repmat(pixels_delays',numel(data.frameTimes),1),2);
end