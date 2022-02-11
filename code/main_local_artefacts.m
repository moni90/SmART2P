%COUNT cut in acquisitions due to large motion artefacts

%% add functions to path
addpath(genpath('./CaImAn-MATLAB-master'));
addpath(genpath('./utilities'));
addpath(genpath('./NoRMCorre-master'));
working_dir = pwd;

save_path_0 = '/media/DATA/mmoroni/software_sls_project/analyses/';
%% initialize data
csv_data = '../data/data_table_server.csv';
data_folder_0 = readmatrix(csv_data,'Range','A:A','OutputType','string');
animal_state_0 = readmatrix(csv_data,'Range','B:B','OutputType','string');
data_day_0 = readmatrix(csv_data,'Range','C:C','OutputType','string');
data_name_0 = readmatrix(csv_data,'Range','D:D','OutputType','string');
data_surround_0 = readmatrix(csv_data,'Range','F:F','OutputType','double');
data_ref_box_0 = readmatrix(csv_data,'Range','G:G','OutputType','double');
ref_ROIs_0 = readmatrix(csv_data,'Range','I:I','OutputType','string');

anesthetized = 1; %flag to analyze awake/anesthetized animals data
downsample_flag = 0;


%filter data
if anesthetized == 1
    id_keep = find(animal_state_0 == 'anesthetized/');
    save_path = [save_path_0 'anesthetized/'];
else
    id_keep = find(animal_state_0 == 'awake/');
    save_path = [save_path_0 'awake/'];
end
data_folder = data_folder_0(id_keep);
animal_state = animal_state_0(id_keep);
data_day = data_day_0(id_keep);
data_name = data_name_0(id_keep);
data_surround = data_surround_0(id_keep);
data_ref_box = data_ref_box_0(id_keep);
ref_ROIs = ref_ROIs_0(id_keep);

%keep only with reference segmentation
id_keep2 = find(1-ismissing(ref_ROIs));
data_folder = data_folder(id_keep2);
animal_state = animal_state(id_keep2);
data_day = data_day(id_keep2);
data_name = data_name(id_keep2);
data_surround = data_surround(id_keep2);
data_ref_box = data_ref_box(id_keep2);
ref_ROIs = ref_ROIs(id_keep2);

% %keep only with reference box
% id_keep3 = find(data_ref_box);
% data_folder = data_folder(id_keep3);
% animal_state = animal_state(id_keep3);
% data_day = data_day(id_keep3);
% data_name = data_name(id_keep3);
% data_surround = data_surround(id_keep3);
% data_ref_box = data_ref_box(id_keep3);
% ref_ROIs = ref_ROIs(id_keep3);


%% run analyses
err_data = string([]);
time_SNR = NaN * ones(length(data_folder),1);
time_NoRM = NaN * ones(length(data_folder),1);
num_ROIs = NaN * ones(length(data_folder),1);

snr_f_avg_noback = NaN * ones(length(data_folder),1);
snr_f_avg_SNR = NaN * ones(length(data_folder),1);
snr_f_avg_NoRM = NaN * ones(length(data_folder),1);

surr_pooled = [];
surr_pooled_NoRM = [];

snr_f_pooled_noback = [];
snr_f_pooled_SNR = [];
snr_f_pooled_NoRM = [];

snr_ca_avg_noback = NaN * ones(length(data_folder),1);
snr_ca_avg_SNR = NaN * ones(length(data_folder),1);
snr_ca_avg_NoRM = NaN * ones(length(data_folder),1);

snr_ca_pooled_noback = [];
snr_ca_pooled_SNR = [];
snr_ca_pooled_NoRM = [];
%%
%%
for id_exp = 1:length(data_folder)
    disp(id_exp);
    try
        large_artefacts_save_path = [save_path char(data_day(id_exp)) char(data_name(id_exp))];
        
        if downsample_flag
            local_artefacts_SNR_save_name = [large_artefacts_save_path 'local_artefacts_SNR.mat'];
            local_artefacts_NoRM_save_name = [large_artefacts_save_path 'local_artefacts_NoRM.mat'];
        else
            local_artefacts_SNR_save_name = [large_artefacts_save_path 'local_artefacts_SNR.mat'];
            local_artefacts_NoRM_save_name = [large_artefacts_save_path 'local_artefacts_NoRM_nodown.mat'];
        end
        %load background subtracted data
        background_load_data = [large_artefacts_save_path 'no_background.mat'];
        load(background_load_data);
        
        if exist(local_artefacts_SNR_save_name)
            load(local_artefacts_SNR_save_name);
            if data_ref_box(id_exp)==1
                if exist(local_artefacts_NoRM_save_name)
                    load(local_artefacts_NoRM_save_name);
                else
                    %load data
                    large_artefacts_load_data = [large_artefacts_save_path 'data_cut_PCA.mat'];
                    load(large_artefacts_load_data);
                    %register ROIs
                    data = register_ROIs_ls(data,ref_ROIs(id_exp));
                    close
                    tic;
                    n_rows = size(data.reference_image,1);
                    n_col = size(data.reference_image,2);
                    scan_path = data.freehand_scan;
                    process_opt.down_rate = 2;
                    [time_down, movie_down, rois_f0_down, rois_f_NoRM, neuropil0_down, neuropil_NoRM,...
                        snr0_down, snr_NoRM,shift_x_NoRM,shift_y_NoRM] = reassign_px_NoRM(movie_no_backgr',...
                        data.A, data.ring, data.surrounding, process_opt.down_rate,...
                        n_rows, n_col, scan_path, data.framePeriod, downsample_flag);
                    close(gcf); close(gcf);
                    if downsample_flag
                        framePeriod_NoRM = data.framePeriod*round(1/(data.framePeriod*process_opt.down_rate));
                    else
                        framePeriod_NoRM = data.framePeriod;
                    end
                    time_temp_NoRM = toc;
                    %downsample the movie
                    SLS_rate = 1/data.framePeriod;
                    down_fact = round(SLS_rate/process_opt.down_rate);
                    down_period_true = data.framePeriod*down_fact;
                    movie_avg = movmean(movie_no_backgr,down_fact,1);
                    if downsample_flag
                        movie_down = movie_avg(:,1:down_fact:end);
                    else
                        down_rate = SLS_rate;
                        down_fact = round(SLS_rate/down_rate);
                        down_period_true = framePeriod*down_fact;
                        movie_down = movie_avg;
                    end
                    rois_f_noback_avg = movmean(rois_f_noback,down_fact,2);
                    rois_f_noback_down = rois_f_noback_avg(:,1:down_fact:end);
                    data_NoRM = sls_deconvolution(movie_down,data,rois_f_NoRM,rois_f_noback_down,framePeriod_NoRM);
                    rois_ca_NoRM = data_NoRM.C_df;
                    clear data_NoRM;
                    
                    snr_ca_NoRM = zeros(size(rois_ca_noback,1),1);
                    for id_roi = 1:size(rois_ca_noback,1)
                        snr_ca_NoRM(id_roi) = 10^(snr(rois_ca_NoRM(id_roi,:),rois_f_NoRM(id_roi,:)-rois_ca_NoRM(id_roi,:))/10);
                    end
                    save(local_artefacts_NoRM_save_name,'rois_f_NoRM', 'neuropil_NoRM',...
                        'snr_NoRM','framePeriod_NoRM','time_temp_NoRM','rois_ca_NoRM',...
                        'snr_ca_NoRM','shift_x_NoRM','shift_y_NoRM','-v7.3');
                end
            end
        else
            %load data
            large_artefacts_load_data = [large_artefacts_save_path 'data_cut_PCA.mat'];
            load(large_artefacts_load_data);
            %register ROIs
            data = register_ROIs_ls(data,ref_ROIs(id_exp));
            close
            
            %use SNR-based pixels reassignment
            tic;
            [rois_f0, rois_f_SNR, neuropil0, neuropil_SNR, snr0, snr_SNR,shift_x_roi,shift_y_roi] = reassign_px_snr(movie_no_backgr, data.A, data.ring, data.surrounding, data.freehand_scan, data.framePeriod);
            framePeriod_SNR = data.framePeriod;
            time_temp_SNR = toc;
            data_SNR = sls_deconvolution(movie_no_backgr,data,rois_f_SNR,rois_f_noback,framePeriod_SNR);
            rois_ca_SNR = data_SNR.C_df;
            clear data_SNR;
            snr_ca_SNR = zeros(size(rois_ca_noback,1),1);
            for id_roi = 1:size(rois_ca_noback,1)
                snr_ca_SNR(id_roi) = 10^(snr(rois_ca_SNR(id_roi,:),rois_f_SNR(id_roi,:)-rois_ca_SNR(id_roi,:))/10);
            end
            save(local_artefacts_SNR_save_name,'rois_f_SNR', 'neuropil_SNR',...
                'snr_SNR','framePeriod_SNR','time_temp_SNR','rois_ca_SNR',...
                'snr_ca_SNR','shift_x_roi','shift_y_roi','-v7.3');
            
            if data_ref_box(id_exp)==1
                if exist(local_artefacts_NoRM_save_name)
                    load(local_artefacts_NoRM_save_name);
                else
                    tic;
                    n_rows = size(data.reference_image,1);
                    n_col = size(data.reference_image,2);
                    scan_path = data.freehand_scan;
                    process_opt.down_rate = 2;
                    [time_down, movie_down, rois_f0_down, rois_f_NoRM, neuropil0_down, neuropil_NoRM,...
                        snr0_down, snr_NoRM,shift_x_NoRM,shift_y_NoRM] = reassign_px_NoRM(movie_no_backgr',...
                        data.A, data.ring, data.surrounding, process_opt.down_rate,...
                        n_rows, n_col, scan_path, data.framePeriod, downsample_flag);
                    close(gcf); close(gcf);
                    if downsample_flag
                        framePeriod_NoRM = data.framePeriod*round(1/(data.framePeriod*process_opt.down_rate));
                    else
                        framePeriod_NoRM = data.framePeriod;
                    end
                    time_temp_NoRM = toc;
                    %downsample the movie
                    SLS_rate = 1/data.framePeriod;
                    down_fact = round(SLS_rate/process_opt.down_rate);
                    down_period_true = data.framePeriod*down_fact;
                    movie_avg = movmean(movie_no_backgr,down_fact,1);
                    if downsample_flag
                        movie_down = movie_avg(:,1:down_fact:end);
                    else
                        down_rate = SLS_rate;
                        down_fact = round(SLS_rate/down_rate);
                        down_period_true = framePeriod*down_fact;
                        movie_down = movie_avg;
                    end
                    rois_f_noback_avg = movmean(rois_f_noback,down_fact,2);
                    rois_f_noback_down = rois_f_noback_avg(:,1:down_fact:end);
                    data_NoRM = sls_deconvolution(movie_down,data,rois_f_NoRM,rois_f_noback_down,framePeriod_NoRM);
                    rois_ca_NoRM = data_NoRM.C_df;
                    clear data_NoRM;
                    
                    snr_ca_NoRM = zeros(size(rois_ca_noback,1),1);
                    for id_roi = 1:size(rois_ca_noback,1)
                        snr_ca_NoRM(id_roi) = 10^(snr(rois_ca_NoRM(id_roi,:),rois_f_NoRM(id_roi,:)-rois_ca_NoRM(id_roi,:))/10);
                    end
                    save(local_artefacts_NoRM_save_name,'rois_f_NoRM', 'neuropil_NoRM',...
                        'snr_NoRM','framePeriod_NoRM','time_temp_NoRM','rois_ca_NoRM',...
                        'snr_ca_NoRM','shift_x_NoRM','shift_y_NoRM','-v7.3');
                end
            end
            
            %             figure;
            %             subplot(3,1,1); imagesc(data.frameTimes,[],rois_f_noback); colorbar; title('no reassigment'); caxis([0, max([rois_f_noback(:); rois_f_SNR(:); rois_f_NoRM(:)])])
            %             subplot(3,1,2); imagesc(data.frameTimes,[],rois_f_SNR); colorbar; title('SNR-based reassigment'); caxis([0, max([rois_f_noback(:); rois_f_SNR(:); rois_f_NoRM(:)])])
            %             subplot(3,1,3); imagesc(time_down,[],rois_f_NoRM); colorbar; title('NoRMCorr-based reassigment'); caxis([0, max([rois_f_noback(:); rois_f_SNR(:); rois_f_NoRM(:)])])
            %
            %             figure;
            %             subplot(2,2,[1,2]); plot([snr_noback(:) snr_SNR(:) snr_NoRM(:)],'-o'); xlabel('ROI'); ylabel('SNR');
            %             legend('no reassignment','SNR-based px reassignment','NoRMCorr-based reassignment');
            %             subplot(2,2,3);
            %             scatter(snr_noback(:), snr_SNR(:));
            %             hold on; plot(0:1:ceil(max([snr_noback(:); snr_SNR(:)])),0:1:ceil(max([snr_noback(:); snr_SNR(:)])),'--k');
            %             xlabel('no reassignment'); ylabel('SNR-based px reassignment');
            %             subplot(2,2,4);
            %             scatter(snr_noback(:), snr_NoRM(:));
            %             hold on; plot(0:1:ceil(max([snr_noback(:); snr_NoRM(:)])),0:1:ceil(max([snr_noback(:); snr_NoRM(:)])),'--k');
            %             xlabel('no reassignment'); ylabel('NoRMCorr-based px reassignment');
            %
            %             figure;
            %             subplot(3,1,1); imagesc(data.frameTimes,[],rois_ca_noback); colorbar; title('no reassigment'); caxis([0, max([rois_ca_noback(:); rois_ca_SNR(:); rois_ca_NoRM(:)])])
            %             subplot(3,1,2); imagesc(data.frameTimes,[],rois_ca_SNR); colorbar; title('SNR-based reassigment'); caxis([0, max([rois_ca_noback(:); rois_ca_SNR(:); rois_ca_NoRM(:)])])
            %             subplot(3,1,3); imagesc(time_down,[],rois_ca_NoRM); colorbar; title('NoRMCorr-based reassigment'); caxis([0, max([rois_ca_noback(:); rois_ca_SNR(:); rois_ca_NoRM(:)])])
            %
            %             figure;
            %             subplot(2,2,[1,2]); plot([snr_ca_noback(:) snr_ca_SNR(:) snr_ca_NoRM(:)],'-o'); xlabel('ROI'); ylabel('SNR deconvolved');
            %             legend('no reassignment','SNR-based px reassignment','NoRMCorr-based reassignment');
            %             subplot(2,2,3);
            %             scatter(snr_ca_noback(:), snr_ca_SNR(:));
            %             hold on; plot(0:1e-12:max([snr_ca_noback(:); snr_ca_SNR(:)]),0:1e-12:max([snr_ca_noback(:); snr_ca_SNR(:)]),'--k');
            %             xlabel('no reassignment'); ylabel('SNR-based px reassignment');
            %             subplot(2,2,4);
            %             scatter(snr_ca_noback(:), snr_ca_NoRM(:));
            %             hold on; plot(0:1e-12:max([snr_ca_noback(:); snr_ca_NoRM(:)]),0:1e-12:max([snr_ca_noback(:); snr_ca_NoRM(:)]),'--k');
            %             xlabel('no reassignment'); ylabel('NoRMCorr-based px reassignment');
        end
        time_SNR(id_exp) = time_temp_SNR;
        num_ROIs(id_exp) = length(snr_noback);
        surr_pooled = [surr_pooled; data_surround(id_exp)*ones(length(snr_noback),1)];
        
        snr_f_avg_noback(id_exp) = nanmean(snr_noback);
        snr_f_avg_SNR(id_exp) = nanmean(snr_SNR);
        
        snr_f_pooled_noback = [snr_f_pooled_noback; snr_noback];
        snr_f_pooled_SNR = [snr_f_pooled_SNR; snr_SNR];
        
        snr_ca_avg_noback(id_exp) = nanmean(snr_ca_noback);
        snr_ca_avg_SNR(id_exp) = nanmean(snr_ca_SNR);
        
        snr_ca_pooled_noback = [snr_ca_pooled_noback; snr_ca_noback];
        snr_ca_pooled_SNR = [snr_ca_pooled_SNR; snr_ca_SNR];
        
        if data_ref_box(id_exp)==1
            time_NoRM(id_exp) = time_temp_NoRM;
            surr_pooled_NoRM = [surr_pooled_NoRM; data_surround(id_exp)*ones(length(snr_NoRM),1)];
            
            snr_f_avg_NoRM(id_exp) = nanmean(snr_NoRM);
            snr_f_pooled_NoRM = [snr_f_pooled_NoRM; snr_NoRM];
            snr_ca_avg_NoRM(id_exp) = nanmean(snr_ca_NoRM);
            snr_ca_pooled_NoRM = [snr_ca_pooled_NoRM; snr_ca_NoRM];
        end
        
        clear data;
    catch
        err_data = [err_data; string([char(data_day(id_exp)) char(data_name(id_exp))])];
    end
    
end

%% save results
local_artefacts_table = array2table([time_SNR(:) time_NoRM(:) snr_f_avg_noback(:)...
    snr_f_avg_SNR(:) snr_f_avg_NoRM(:) snr_ca_avg_noback(:)...
    snr_ca_avg_SNR(:) snr_ca_avg_NoRM(:),num_ROIs(:)],...
    'VariableNames',{'time_SNR','time_NoRM','snr_f_avg_noback','snr_f_avg_SNR',...
    'snr_f_avg_NoRM', 'snr_ca_avg_noback', 'snr_ca_avg_SNR', 'snr_ca_avg_NoRM','num_ROIs'});
surr_pooled_NoRM_temp = NaN*ones(length(surr_pooled),1);
surr_pooled_NoRM_temp(1:length(surr_pooled_NoRM)) = surr_pooled_NoRM;
snr_f_pooled_NoRM_temp = NaN*ones(length(surr_pooled),1);
snr_f_pooled_NoRM_temp(1:length(snr_f_pooled_NoRM)) = snr_f_pooled_NoRM;
snr_ca_pooled_NoRM_temp = NaN*ones(length(surr_pooled),1);
snr_ca_pooled_NoRM_temp(1:length(snr_ca_pooled_NoRM)) = snr_ca_pooled_NoRM;
local_artefacts_pooled_table = array2table([surr_pooled(:) surr_pooled_NoRM_temp(:) snr_f_pooled_noback(:) snr_f_pooled_SNR(:)...
    snr_f_pooled_NoRM_temp(:) snr_ca_pooled_noback(:) snr_ca_pooled_SNR(:) snr_ca_pooled_NoRM_temp(:)],...
    'VariableNames',{'surr_pooled', 'surr_pooled_NoRM_temp', 'snr_f_pooled_noback', 'snr_f_pooled_SNR',...
    'snr_f_pooled_NoRM_temp', 'snr_ca_pooled_noback', 'snr_ca_pooled_SNR', 'snr_ca_pooled_NoRM_temp'});
if anesthetized == 1
    if downsample_flag
        writetable(local_artefacts_table,[save_path_0 'anesthetized_local_artefacts_summary.csv']);
        writetable(local_artefacts_pooled_table,[save_path_0 'anesthetized_local_artefacts_pooled.csv']);
    else
        writetable(local_artefacts_table,[save_path_0 'anesthetized_local_artefacts_summary_nodown.csv']);
        writetable(local_artefacts_pooled_table,[save_path_0 'anesthetized_local_artefacts_pooled_nodown.csv']);
    end
else
    if downsample_flag
        writetable(local_artefacts_table,[save_path_0 'awake_local_artefacts_summary.csv']);
        writetable(local_artefacts_pooled_table,[save_path_0 'awake_local_artefacts_pooled.csv']);
    else
        writetable(local_artefacts_table,[save_path_0 'awake_local_artefacts_summary_nodown.csv']);
        writetable(local_artefacts_pooled_table,[save_path_0 'awake_local_artefacts_pooled_nodown.csv']);
    end
end


%% plot some stats

figure; histogram(time_SNR); hold on; histogram(time_NoRM);
legend('SNR','NoRMCorr');
xlabel('processing time local artefacts (s)'); ylabel('num acquisitions');
disp(['SNR comput time=' num2str(nanmean(time_SNR)) '+/-' num2str(nanstd(time_SNR)/sqrt(sum(1-isnan(time_SNR)))) '(mean+/-sem)']);
disp(['NoRMCorr comput time=' num2str(nanmean(time_NoRM)) '+/-' num2str(nanstd(time_NoRM)/sqrt(sum(1-isnan(time_NoRM)))) '(mean+/-sem)']);

figure; scatter(n_lines(id_keep2).*pixels_per_line(id_keep2),time_comp_SNR);
ylabel('processing time local SNR (s)'); xlabel('num SL lines * num px per SL');

figure; scatter(n_lines(id_keep2),time_comp_SNR);
ylabel('processing time local SNR (s)'); xlabel('num SL lines');

figure; scatter(num_ROIs,time_SNR);
ylabel('processing time local SNR (s)'); xlabel('num ROIs');

figure; scatter(data_surround,time_SNR);
ylabel('processing time local SNR (s)'); xlabel('px surround');

figure; scatter(sls_duration(id_keep2),time_SNR);
ylabel('processing time local SNR (s)'); xlabel('duration (s)');


figure; scatter(n_lines(id_keep2).*pixels_per_line(id_keep2),time_comp_NoRM);
ylabel('processing time local NoRM (s)'); xlabel('num SL lines * num px per SL');

figure; scatter(n_lines(id_keep2),time_comp_NoRM);
ylabel('processing time local NoRM (s)'); xlabel('num SL lines');

figure; scatter(pixels_per_line(id_keep2),time_comp_NoRM);
ylabel('processing time local NoRM (s)'); xlabel('num px per SL');

figure;
surr_array = unique(surr_pooled);
for i_s = 1:length(surr_array)
    snr_f_noback_temp = snr_f_pooled_noback(find(surr_pooled==surr_array(i_s)));
    snr_f_SNR_temp = snr_f_pooled_SNR(find(surr_pooled==surr_array(i_s)));
    snr_f_NoRM_temp = snr_f_pooled_NoRM(find(surr_pooled_NoRM==surr_array(i_s)));
    b_w = 10;
    subplot(2,3,i_s);
    hold on; histogram(snr_f_noback_temp,'binWidth',b_w);
    hold on; histogram(snr_f_SNR_temp,'binWidth',b_w);
    hold on; histogram(snr_f_NoRM_temp,'binWidth',b_w);
    legend('NO local process','SNR','NoRMCorr');
    xlabel('average SNR fluo'); ylabel('num acquisitions');
    title(['surround=' num2str(surr_array(i_s))]);
end

figure;
surr_array = unique(surr_pooled);
for i_s = 1:length(surr_array)
    snr_ca_noback_temp = snr_ca_pooled_noback(find(surr_pooled==surr_array(i_s)));
    snr_ca_SNR_temp = snr_ca_pooled_SNR(find(surr_pooled==surr_array(i_s)));
    snr_ca_NoRM_temp = snr_ca_pooled_NoRM(find(surr_pooled_NoRM==surr_array(i_s)));
    b_w = 1e-7;
    subplot(2,3,i_s);
    hold on; histogram(snr_ca_noback_temp,'binWidth',b_w);
    hold on; histogram(snr_ca_SNR_temp,'binWidth',b_w);
    hold on; histogram(snr_ca_NoRM_temp,'binWidth',b_w);
    legend('NO local process','SNR','NoRMCorr');
    xlabel('average SNR fluo'); ylabel('num acquisitions');
    title(['surround=' num2str(surr_array(i_s))]);
end

b_w = 50;
figure; histogram(snr_f_pooled_noback,'binWidth',b_w);
hold on; histogram(snr_f_pooled_SNR,'binWidth',b_w);
hold on; histogram(snr_f_pooled_NoRM,'binWidth',b_w);
legend('NO local process','SNR','NoRMCorr');
xlabel('average SNR fluo'); ylabel('num acquisitions');
disp(['average SNR without local processing=' num2str(nanmean(snr_f_pooled_noback)) '+/-' num2str(nanstd(snr_f_pooled_noback)/sqrt(sum(1-isnan(snr_f_pooled_noback)))) '(mean+/-sem)']);
disp(['average SNR after SNR-based correction=' num2str(nanmean(snr_f_pooled_SNR)) '+/-' num2str(nanstd(snr_f_pooled_SNR)/sqrt(sum(1-isnan(snr_f_pooled_SNR)))) '(mean+/-sem)']);
disp(['average SNR after NoRMCorr-based correction=' num2str(nanmean(snr_f_pooled_NoRM)) '+/-' num2str(nanstd(snr_f_pooled_NoRM)/sqrt(sum(1-isnan(snr_f_pooled_NoRM)))) '(mean+/-sem)']);

b_w = 5e-8;
figure; histogram(snr_ca_pooled_noback,'binWidth',b_w);
hold on; histogram(snr_ca_pooled_SNR,'binWidth',b_w);
hold on; histogram(snr_ca_pooled_NoRM,'binWidth',b_w);
legend('NO local process','SNR','NoRMCorr');
xlabel('average SNR deconvolved'); ylabel('num acquisitions');
disp(['average SNR without local processing=' num2str(nanmean(snr_ca_pooled_noback)) '+/-' num2str(nanstd(snr_ca_pooled_noback)/sqrt(sum(1-isnan(snr_ca_pooled_noback)))) '(mean+/-sem)']);
disp(['average SNR after SNR-based correction=' num2str(nanmean(snr_ca_pooled_SNR)) '+/-' num2str(nanstd(snr_ca_pooled_SNR)/sqrt(sum(1-isnan(snr_ca_pooled_SNR)))) '(mean+/-sem)']);
disp(['average SNR after NoRMCorr-based correction=' num2str(nanmean(snr_ca_pooled_NoRM)) '+/-' num2str(nanstd(snr_ca_pooled_NoRM)/sqrt(sum(1-isnan(snr_ca_pooled_NoRM)))) '(mean+/-sem)']);

figure;
surr_array = unique(data_surround);
for i_s = 1:length(surr_array)
    snr_f_noback_temp = snr_f_avg_noback(find(data_surround==surr_array(i_s)));
    snr_f_SNR_temp = snr_f_avg_SNR(find(data_surround==surr_array(i_s)));
    snr_f_NoRM_temp = snr_f_avg_NoRM(find(data_surround==surr_array(i_s)));
    %     snr_ca_noback_temp = snr_ca_avg_noback(find(data_surround==data_surround(i_s)));
    %     snr_ca_SNR_temp = snr_ca_avg_SNR(find(data_surround==data_surround(i_s)));
    %     snr_ca_NoRM_temp = snr_ca_avg_NoRM(find(data_surround==data_surround(i_s)));
    subplot(2,5,i_s);
    hold on; scatter(snr_f_noback_temp, snr_f_SNR_temp);
    hold on; plot(nanmin([snr_f_noback_temp; snr_f_SNR_temp]):1:nanmax([snr_f_noback_temp; snr_f_SNR_temp]),...
        nanmin([snr_f_noback_temp; snr_f_SNR_temp]):1:nanmax([snr_f_noback_temp; snr_f_SNR_temp]),'--k');
    xlabel('SNR fluo without local processing'); ylabel('SNR fluo after SNR-based correction');
    title(['surround=' num2str(surr_array(i_s))]);
    subplot(2,5,5+i_s);
    hold on; scatter(snr_f_noback_temp, snr_f_NoRM_temp);
    hold on; plot(nanmin([snr_f_noback_temp; snr_f_NoRM_temp]):1:nanmax([snr_f_noback_temp; snr_f_NoRM_temp]),...
        nanmin([snr_f_noback_temp; snr_f_NoRM_temp]):1:nanmax([snr_f_noback_temp; snr_f_NoRM_temp]),'--k');
    xlabel('SNR fluo without local processing'); ylabel('SNR fluo after NoRMCorr-based correction');
    title(['surround=' num2str(surr_array(i_s))]);
end

data_surround_0 = data_surround;
data_surround(data_surround>=3)=3;

box_plot_snr = figure;
surr_array = unique(data_surround);
for i_s = 1:length(surr_array)
    snr_f_noback_temp = snr_f_avg_noback(find(data_surround==surr_array(i_s)));
    snr_f_SNR_temp = snr_f_avg_SNR(find(data_surround==surr_array(i_s)));
    snr_f_NoRM_temp = snr_f_avg_NoRM(find(data_surround==surr_array(i_s)));
    
    figure(box_plot_snr);
    subplot(2,3,i_s);
    hold on; boxplot([snr_f_noback_temp(:), snr_f_SNR_temp(:), ...
        snr_f_NoRM_temp(:)],...
        'Labels',{'no back','no back, SNR','no back, NoRM'},...
        'PlotStyle','traditional','orientation','horizontal');
    ylabel('SNR fluo');
    title(['surround=' num2str(surr_array(i_s))]);
    %
    %     mm = nanmean([snr_f_noback_temp(:), snr_f_SNR_temp(:), ...
    %         snr_f_NoRM_temp(:)],1)
    %     ss = nanstd([snr_f_noback_temp(:), snr_f_SNR_temp(:), ...
    %         snr_f_NoRM_temp(:)],1)./sqrt(sum(1-isnan([snr_f_noback_temp(:), snr_f_SNR_temp(:), ...
    %         snr_f_NoRM_temp(:)])))
    %
    [p,tbl,stats] = kruskalwallis([snr_f_noback_temp(:), snr_f_SNR_temp(:), ...
        snr_f_NoRM_temp(:)],...
        {'no back','no back, SNR','no back, NoRM'});
    figure;
    c = multcompare(stats)
    title(['SNR. surround=' num2str(surr_array(i_s))]);
end


figure;
surr_array = unique(data_surround);
for i_s = 1:length(surr_array)
    snr_ca_noback_temp = snr_ca_avg_noback(find(data_surround==surr_array(i_s)));
    snr_ca_SNR_temp = snr_ca_avg_SNR(find(data_surround==surr_array(i_s)));
    snr_ca_NoRM_temp = snr_ca_avg_NoRM(find(data_surround==surr_array(i_s)));
    subplot(2,5,i_s);
    hold on; scatter(snr_ca_noback_temp, snr_ca_SNR_temp);
    hold on; plot(nanmin([snr_ca_noback_temp; snr_ca_SNR_temp]):1e-10:nanmax([snr_ca_noback_temp; snr_ca_SNR_temp]),...
        nanmin([snr_ca_noback_temp; snr_ca_SNR_temp]):1e-10:nanmax([snr_ca_noback_temp; snr_ca_SNR_temp]),'--k');
    xlabel('SNR deconv without local processing'); ylabel('SNR deconv after SNR-based correction');
    title(['surround=' num2str(surr_array(i_s))]);
    subplot(2,5,5+i_s);
    hold on; scatter(snr_ca_noback_temp, snr_ca_NoRM_temp);
    hold on; plot(nanmin([snr_ca_noback_temp; snr_ca_NoRM_temp]):1e-10:nanmax([snr_ca_noback_temp; snr_ca_NoRM_temp]),...
        nanmin([snr_ca_noback_temp; snr_ca_NoRM_temp]):1e-10:nanmax([snr_ca_noback_temp; snr_ca_NoRM_temp]),'--k');
    xlabel('SNR deconv without local processing'); ylabel('SNR deconv after NoRMCorr-based correction');
    title(['surround=' num2str(surr_array(i_s))]);
end

figure; scatter(snr_f_avg_noback, snr_f_avg_SNR);
hold on; plot(-1:1:1,-1:1:1,'--k');
xlabel('SNR fluo without local processing'); ylabel('SNR fluo after SNR-based correction');
disp(['average SNR without local processing=' num2str(nanmean(snr_f_avg_noback)) '+/-' num2str(nanstd(snr_f_avg_noback)/sqrt(sum(1-isnan(snr_f_avg_noback)))) '(mean+/-sem)']);
disp(['average SNR after SNR-based correction=' num2str(nanmean(snr_f_avg_SNR)) '+/-' num2str(nanstd(snr_f_avg_SNR)/sqrt(sum(1-isnan(snr_f_avg_SNR)))) '(mean+/-sem)']);

figure; scatter(snr_f_avg_noback, snr_f_avg_NoRM);
hold on; plot(-1:1:1,-1:1:1,'--k');
xlabel('SNR fluo without local processing'); ylabel('SNR fluo after NoRMCorr-based correction');
disp(['average SNR without local processing=' num2str(nanmean(snr_f_avg_noback)) '+/-' num2str(nanstd(snr_f_avg_noback)/sqrt(sum(1-isnan(snr_f_avg_noback)))) '(mean+/-sem)']);
disp(['average SNR after NoRMCorr-based correction=' num2str(nanmean(snr_f_avg_NoRM)) '+/-' num2str(nanstd(snr_f_avg_NoRM)/sqrt(sum(1-isnan(snr_f_avg_NoRM)))) '(mean+/-sem)']);

figure; scatter(snr_ca_avg_noback, snr_ca_avg_SNR);
hold on; plot(-1:1:1,-1:1:1,'--k');
xlabel('SNR deconvolved without local processing'); ylabel('SNR deconvolved after SNR-based correction');
disp(['average SNR without local processing=' num2str(nanmean(snr_ca_avg_noback)) '+/-' num2str(nanstd(snr_ca_avg_noback)/sqrt(sum(1-isnan(snr_ca_avg_noback)))) '(mean+/-sem)']);
disp(['average SNR after SNR-based correction=' num2str(nanmean(snr_ca_avg_SNR)) '+/-' num2str(nanstd(snr_ca_avg_SNR)/sqrt(sum(1-isnan(snr_ca_avg_SNR)))) '(mean+/-sem)']);

figure; scatter(snr_ca_avg_noback, snr_ca_avg_NoRM);
hold on; plot(-1:1:1,-1:1:1,'--k');
xlabel('SNR deconvolved without local processing'); ylabel('SNR deconvolved after NoRMCorr-based correction');
disp(['average SNR without local processing=' num2str(nanmean(snr_ca_avg_noback)) '+/-' num2str(nanstd(snr_ca_avg_noback)/sqrt(sum(1-isnan(snr_ca_avg_noback)))) '(mean+/-sem)']);
disp(['average SNR after NoRMCorr-based correction=' num2str(nanmean(snr_ca_avg_NoRM)) '+/-' num2str(nanstd(snr_ca_avg_NoRM)/sqrt(sum(1-isnan(snr_ca_avg_NoRM)))) '(mean+/-sem)']);
