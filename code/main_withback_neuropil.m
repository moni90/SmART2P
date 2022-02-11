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

anesthetized = 0; %flag to analyze awake/anesthetized animals data
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

%% run analyses
err_data = string([]);
% time_neuropil_raw = NaN * ones(length(data_folder),1);
time_neuropil_back = NaN * ones(length(data_folder),1);
time_neuropil_back_SNR = NaN * ones(length(data_folder),1);
time_neuropil_back_NoRM = NaN * ones(length(data_folder),1);


% snr_f_avg_neuropil_raw = NaN * ones(length(data_folder),1);
snr_f_avg_back = NaN * ones(length(data_folder),1); %snr raw
snr_f_avg_neuropil_back = NaN * ones(length(data_folder),1); %snr after neuropil subtraction
snr_f_avg_back_SNR = NaN * ones(length(data_folder),1); %snr after SNR-motion
snr_f_avg_neuropil_back_SNR = NaN * ones(length(data_folder),1); %snr after SNR-motion and neuropil subtraction
snr_f_avg_back_NoRM = NaN * ones(length(data_folder),1);
snr_f_avg_neuropil_back_NoRM= NaN * ones(length(data_folder),1);
% corr_f_avg_raw = NaN * ones(length(data_folder),1);
corr_f_avg_back = NaN * ones(length(data_folder),1);
corr_f_avg_neuropil_back = NaN * ones(length(data_folder),1);
corr_f_avg_back_SNR = NaN * ones(length(data_folder),1);
corr_f_avg_neuropil_back_SNR = NaN * ones(length(data_folder),1);
corr_f_avg_back_NoRM= NaN * ones(length(data_folder),1);
corr_f_avg_neuropil_back_NoRM= NaN * ones(length(data_folder),1);

% snr_ca_avg_neuropil_raw = NaN * ones(length(data_folder),1);
snr_ca_avg_back = NaN * ones(length(data_folder),1);
snr_ca_avg_neuropil_back = NaN * ones(length(data_folder),1);
snr_ca_avg_back_SNR = NaN * ones(length(data_folder),1);
snr_ca_avg_neuropil_back_SNR = NaN * ones(length(data_folder),1);
snr_ca_avg_back_NoRM = NaN * ones(length(data_folder),1);
snr_ca_avg_neuropil_back_NoRM= NaN * ones(length(data_folder),1);
% corr_ca_avg_raw = NaN * ones(length(data_folder),1);
corr_ca_avg_back = NaN * ones(length(data_folder),1);
corr_ca_avg_neuropil_back = NaN * ones(length(data_folder),1);
corr_ca_avg_back_SNR = NaN * ones(length(data_folder),1);
corr_ca_avg_neuropil_back_SNR = NaN * ones(length(data_folder),1);
corr_ca_avg_back_NoRM= NaN * ones(length(data_folder),1);
corr_ca_avg_neuropil_back_NoRM= NaN * ones(length(data_folder),1);

%%
for id_exp = 1:length(data_folder)
    disp(id_exp);
    try
        large_artefacts_save_path = [save_path char(data_day(id_exp)) char(data_name(id_exp))];

        if downsample_flag
            neuropil_subtracted_save_name = [large_artefacts_save_path 'withback_neuropil_subtracted.mat'];
        else
            neuropil_subtracted_save_name = [large_artefacts_save_path 'withback_neuropil_subtracted_nodown.mat'];
        end
%         %load background subtracted data
%         background_load_data = [large_artefacts_save_path 'no_background.mat'];
%         load(background_load_data);
        %load local processed data
        local_artefacts_SNR_load_data = [large_artefacts_save_path 'withback_local_artefacts_SNR.mat'];
        load(local_artefacts_SNR_load_data);
        if downsample_flag
            local_artefacts_NoRM_load_data = [large_artefacts_save_path 'withback_local_artefacts_NoRM.mat'];
            if exist(local_artefacts_NoRM_load_data)
                load(local_artefacts_NoRM_load_data);
            end
        else
            local_artefacts_NoRM_load_data = [large_artefacts_save_path 'withback_local_artefacts_NoRM_nodown.mat'];
            if exist(local_artefacts_NoRM_load_data)
                load(local_artefacts_NoRM_load_data);
            end
        end
        
        
        if exist(neuropil_subtracted_save_name)
            load(neuropil_subtracted_save_name);
        else
            %load data
            large_artefacts_load_data = [large_artefacts_save_path 'data_cut_PCA.mat'];
            load(large_artefacts_load_data);
            %register ROIs
            data = register_ROIs_ls(data,ref_ROIs(id_exp));
            close
            
            %subtract neuropil from data without background
            tic;
            [rois_neuro_ring,snr_ring,rois_neuro_pca,neuropil_pca, snr_pca] = subtract_neuropil_local(rois_f_raw, neuropil_raw, data.framePeriod);
            rois_f_back_noneuropil = rois_neuro_ring;
            snr_f_back_noneuropil = snr_ring;
            time_temp_neuropil_back = toc;
            data_temp = sls_deconvolution(data.movie_doc.movie_ruido',data,rois_f_back_noneuropil,rois_f_raw,data.framePeriod);
            rois_ca_back_noneuropil = data_temp.C_df;
            clear data_temp;
            snr_ca_back_noneuropil = zeros(size(rois_ca_back_noneuropil,1),1);
            for id_roi = 1:size(rois_ca_back_noneuropil,1)
                snr_ca_back_noneuropil(id_roi) =...
                    10^(snr(rois_ca_back_noneuropil(id_roi,:),rois_f_back_noneuropil(id_roi,:)-rois_ca_back_noneuropil(id_roi,:))/10);
            end
            corr_fluo_back = corr(rois_f_raw');
            corr_ca_back = corr(rois_ca_raw');
            corr_fluo_back_noneuropil = corr(rois_f_back_noneuropil');
            corr_ca_back_noneuropil = corr(rois_ca_back_noneuropil');
            
            %subtract neuropil from data without background and corrected
            %with SNR
            tic;
            [rois_neuro_ring,snr_ring,rois_neuro_pca,neuropil_pca, snr_pca] = subtract_neuropil_local(rois_f_SNR, neuropil_SNR, framePeriod_SNR);
            rois_f_back_SNR_noneuropil = rois_neuro_ring;
            snr_f_back_SNR_noneuropil = snr_ring;
            time_temp_neuropil_back_SNR = toc;
            data_temp = sls_deconvolution(data.movie_doc.movie_ruido',data,rois_f_back_SNR_noneuropil,rois_f_raw,data.framePeriod);
            rois_ca_back_SNR_noneuropil = data_temp.C_df;
            clear data_temp;
            snr_ca_back_SNR_noneuropil = zeros(size(rois_ca_back_SNR_noneuropil,1),1);
            for id_roi = 1:size(rois_ca_back_SNR_noneuropil,1)
                snr_ca_back_SNR_noneuropil(id_roi) =...
                    10^(snr(rois_ca_back_SNR_noneuropil(id_roi,:),rois_f_back_SNR_noneuropil(id_roi,:)-rois_ca_back_SNR_noneuropil(id_roi,:))/10);
            end
            corr_fluo_back_SNR = corr(rois_f_SNR');
            corr_ca_back_SNR = corr(rois_ca_SNR');
            corr_fluo_back_SNR_noneuropil = corr(rois_f_back_SNR_noneuropil');
            corr_ca_back_SNR_noneuropil = corr(rois_ca_back_SNR_noneuropil');
            
            save(neuropil_subtracted_save_name,...
                'rois_f_back_noneuropil', 'snr_f_back_noneuropil','rois_ca_back_noneuropil',...
                'snr_ca_back_noneuropil','corr_fluo_back_noneuropil','corr_ca_back_noneuropil',...
                'corr_fluo_back','corr_ca_back','time_temp_neuropil_back',...
                'rois_f_back_SNR_noneuropil','snr_f_back_SNR_noneuropil','rois_ca_back_SNR_noneuropil',...
                'snr_ca_back_SNR_noneuropil','corr_fluo_back_SNR_noneuropil','corr_ca_back_SNR_noneuropil',...
                'corr_fluo_back_SNR','corr_ca_back_SNR','time_temp_neuropil_back_SNR',...
                '-v7.3');
            
            if data_ref_box(id_exp)==1
                %subtract neuropil from data without background and corrected
                %with NoRM
                tic;
                [rois_neuro_ring,snr_ring,rois_neuro_pca,neuropil_pca, snr_pca] = subtract_neuropil_local(rois_f_NoRM, neuropil_NoRM, framePeriod_NoRM);
                rois_f_back_NoRM_noneuropil = rois_neuro_ring;
                snr_f_back_NoRM_noneuropil = snr_ring;
                time_temp_neuropil_back_NoRM = toc;
                %downsample the movie
                down_fact = round(framePeriod_NoRM/data.framePeriod);
                down_period_true = data.framePeriod*down_fact;
                movie_avg = movmean(data.movie_doc.movie_ruido',down_fact,1);
                movie_down = movie_avg(:,1:down_fact:end);
                rois_f_back_avg = movmean(rois_f_raw,down_fact,2);
                rois_f_back_down = rois_f_back_avg(:,1:down_fact:end);
                data_temp = sls_deconvolution(movie_down,data,rois_f_back_NoRM_noneuropil,rois_f_back_down,framePeriod_NoRM);
                rois_ca_back_NoRM_noneuropil = data_temp.C_df;
                clear data_temp;
                snr_ca_back_NoRM_noneuropil = zeros(size(rois_ca_back_NoRM_noneuropil,1),1);
                for id_roi = 1:size(rois_ca_back_NoRM_noneuropil,1)
                    snr_ca_back_NoRM_noneuropil(id_roi) =...
                        10^(snr(rois_ca_back_NoRM_noneuropil(id_roi,:),rois_f_back_NoRM_noneuropil(id_roi,:)-rois_ca_back_NoRM_noneuropil(id_roi,:))/10);
                end
                corr_fluo_back_NoRM = corr(rois_f_NoRM');
                corr_ca_back_NoRM = corr(rois_ca_NoRM');
                corr_fluo_back_NoRM_noneuropil = corr(rois_f_back_NoRM_noneuropil');
                corr_ca_back_NoRM_noneuropil = corr(rois_ca_back_NoRM_noneuropil');
                
                save(neuropil_subtracted_save_name,...
                'rois_f_back_NoRM_noneuropil', 'snr_f_back_NoRM_noneuropil',...
                'rois_ca_back_NoRM_noneuropil','snr_ca_back_NoRM_noneuropil',...
                'corr_fluo_back_NoRM','corr_ca_back_NoRM',...
                'corr_fluo_back_NoRM_noneuropil','corr_ca_back_NoRM_noneuropil',...
                'time_temp_neuropil_back_NoRM','-append');
            end

        end
        time_neuropil_back(id_exp) = time_temp_neuropil_back;
        time_neuropil_back_SNR(id_exp) = time_temp_neuropil_back_SNR;
        
        snr_f_avg_back(id_exp) = nanmean(snr_raw);
        snr_f_avg_neuropil_back(id_exp) = nanmean(snr_f_back_noneuropil);
        snr_f_avg_back_SNR(id_exp) = nanmean(snr_SNR);
        snr_f_avg_neuropil_back_SNR(id_exp) = nanmean(snr_f_back_SNR_noneuropil);
        snr_ca_avg_back(id_exp) = nanmean(snr_ca_raw);
        snr_ca_avg_neuropil_back(id_exp) = nanmean(snr_ca_back_noneuropil);
        snr_ca_avg_back_SNR(id_exp) = nanmean(snr_ca_SNR);
        snr_ca_avg_neuropil_back_SNR(id_exp) = nanmean(snr_ca_back_SNR_noneuropil);

        low_diag = tril(NaN*ones(size(rois_f_back_noneuropil,1)));
%         corr_f_avg_raw(id_exp) = nanmean(corr_fluo_before(find(1-isnan(low_diag))));
        corr_f_avg_back(id_exp) = nanmean(corr_fluo_back(find(1-isnan(low_diag))));
        corr_f_avg_neuropil_back(id_exp) = nanmean(corr_fluo_back_noneuropil(find(1-isnan(low_diag))));
        corr_f_avg_back_SNR(id_exp) = nanmean(corr_fluo_back_SNR(find(1-isnan(low_diag))));
        corr_f_avg_neuropil_back_SNR(id_exp) = nanmean(corr_fluo_back_SNR_noneuropil(find(1-isnan(low_diag))));
%         corr_ca_avg_raw(id_exp) = nanmean(corr_ca_before(find(1-isnan(low_diag))));
        corr_ca_avg_back(id_exp) = nanmean(corr_ca_back(find(1-isnan(low_diag))));
        corr_ca_avg_neuropil_back(id_exp) = nanmean(corr_ca_back_noneuropil(find(1-isnan(low_diag))));
        corr_ca_avg_back_SNR(id_exp) = nanmean(corr_ca_back_SNR(find(1-isnan(low_diag))));
        corr_ca_avg_neuropil_back_SNR(id_exp) = nanmean(corr_ca_back_SNR_noneuropil(find(1-isnan(low_diag))));

        if data_ref_box(id_exp)==1
            time_neuropil_back_NoRM(id_exp) = time_temp_neuropil_back_NoRM;
            snr_f_avg_back_NoRM(id_exp) = nanmean(snr_NoRM);
            snr_f_avg_neuropil_back_NoRM(id_exp) = nanmean(snr_f_back_NoRM_noneuropil);
            corr_f_avg_back_NoRM(id_exp) = nanmean(corr_fluo_back_NoRM(find(1-isnan(low_diag))));
            corr_f_avg_neuropil_back_NoRM(id_exp) = nanmean(corr_fluo_back_NoRM_noneuropil(find(1-isnan(low_diag))));
            snr_ca_avg_back_NoRM(id_exp) = nanmean(snr_ca_NoRM);
            snr_ca_avg_neuropil_back_NoRM(id_exp) = nanmean(snr_ca_back_NoRM_noneuropil);
            corr_ca_avg_back_NoRM(id_exp) = nanmean(corr_ca_back_NoRM(find(1-isnan(low_diag))));
            corr_ca_avg_neuropil_back_NoRM(id_exp) = nanmean(corr_ca_back_NoRM_noneuropil(find(1-isnan(low_diag))));
  
        end
        
        clear data;
    catch
        err_data = [err_data; string([char(data_day(id_exp)) char(data_name(id_exp))])];
    end
    
end

%% save results
neuropil_table = array2table([time_neuropil_back(:) time_neuropil_back_SNR(:) time_neuropil_back_NoRM(:)...
    snr_f_avg_back(:) snr_f_avg_neuropil_back(:) snr_f_avg_back_SNR(:) snr_f_avg_neuropil_back_SNR(:) snr_f_avg_back_NoRM(:) snr_f_avg_neuropil_back_NoRM(:)...
    snr_ca_avg_back(:) snr_ca_avg_neuropil_back(:) snr_ca_avg_back_SNR(:) snr_ca_avg_neuropil_back_SNR(:) snr_ca_avg_back_NoRM(:) snr_ca_avg_neuropil_back_NoRM(:)...
    corr_f_avg_back(:) corr_f_avg_neuropil_back(:)...
    corr_f_avg_back_SNR(:) corr_f_avg_neuropil_back_SNR(:)...
    corr_f_avg_back_NoRM(:) corr_f_avg_neuropil_back_NoRM(:)...
    corr_ca_avg_back(:) corr_ca_avg_neuropil_back(:)...
    corr_ca_avg_back_SNR(:) corr_ca_avg_neuropil_back_SNR(:)...
    corr_ca_avg_back_NoRM(:) corr_ca_avg_neuropil_back_NoRM(:)],...
    'VariableNames',{'time_neuropil_back', 'time_neuropil_back_SNR', 'time_neuropil_back_NoRM',...
    'snr_f_avg_back', 'snr_f_avg_neuropil_back', 'snr_f_avg_back_SNR', 'snr_f_avg_neuropil_back_SNR', 'snr_f_avg_back_NoRM', 'snr_f_avg_neuropil_back_NoRM',...
    'snr_ca_avg_back', 'snr_ca_avg_neuropil_back', 'snr_ca_avg_back_SNR', 'snr_ca_avg_neuropil_back_SNR', 'snr_ca_avg_back_NoRM', 'snr_ca_avg_neuropil_back_NoRM',...
    'corr_f_avg_back', 'corr_f_avg_neuropil_back',...
    'corr_f_avg_back_SNR', 'corr_f_avg_neuropil_back_SNR',...
    'corr_f_avg_back_NoRM', 'corr_f_avg_neuropil_back_NoRM',...
    'corr_ca_avg_back', 'corr_ca_avg_neuropil_back',...
    'corr_ca_avg_back_SNR', 'corr_ca_avg_neuropil_back_SNR',...
    'corr_ca_avg_back_NoRM', 'corr_ca_avg_neuropil_back_NoRM'});

if anesthetized == 1
    if downsample_flag
        writetable(neuropil_table,[save_path_0 'anesthetized_withback_neuropil_summary.csv']);
    else
        writetable(neuropil_table,[save_path_0 'anesthetized_withback_neuropil_summary_nodown.csv']);
    end
%     writetable(local_artefacts_pooled_table,[save_path_0 'anesthetized_neuropil_pooled.csv']);
else
    if downsample_flag
        writetable(neuropil_table,[save_path_0 'awake_withback_neuropil_summary.csv']);
    else
        writetable(neuropil_table,[save_path_0 'awake_withback_neuropil_summary_nodown.csv']);
    end
%     writetable(local_artefacts_pooled_table,[save_path_0 'awake_neuropil_pooled.csv']);
end


%% plot some stats

figure; histogram(time_neuropil_back); hold on; histogram(time_neuropil_back_SNR);
hold on; histogram(time_neuropil_back_NoRM);
legend('SNR','NoRMCorr','NoRM');
xlabel('processing time local artefacts (s)'); ylabel('num acquisitions');
disp(['no_back comput time=' num2str(nanmean(time_neuropil_back)) '+/-' num2str(nanstd(time_neuropil_back)/sqrt(sum(1-isnan(time_neuropil_back)))) '(mean+/-sem)']);
disp(['SNR comput time=' num2str(nanmean(time_neuropil_back_SNR)) '+/-' num2str(nanstd(time_neuropil_back_SNR)/sqrt(sum(1-isnan(time_neuropil_back_SNR)))) '(mean+/-sem)']);
disp(['NoRMCorr comput time=' num2str(nanmean(time_neuropil_back_NoRM)) '+/-' num2str(nanstd(time_neuropil_back_NoRM)/sqrt(sum(1-isnan(time_neuropil_back_NoRM)))) '(mean+/-sem)']);

% data_surround_original = data_surround;
data_surround(data_surround>=3)=3;

figure; 
surr_array = unique(data_surround);
for i_s = 1:length(surr_array)
    snr_f_back_temp = snr_f_avg_back(find(data_surround==surr_array(i_s)));
    snr_f_back_neuropil_temp = snr_f_avg_neuropil_back(find(data_surround==surr_array(i_s)));
    snr_f_back_SNR_temp = snr_f_avg_back_SNR(find(data_surround==surr_array(i_s)));
    snr_f_back_SNR_neuropil_temp = snr_f_avg_neuropil_back_SNR(find(data_surround==surr_array(i_s)));
    snr_f_back_NoRM_temp = snr_f_avg_back_NoRM(find(data_surround==surr_array(i_s)));
    snr_f_back_NoRM_neuropil_temp = snr_f_avg_neuropil_back_NoRM(find(data_surround==surr_array(i_s)));
%     snr_ca_noback_temp = snr_ca_avg_noback(find(data_surround==data_surround(i_s)));
%     snr_ca_SNR_temp = snr_ca_avg_SNR(find(data_surround==data_surround(i_s)));
%     snr_ca_NoRM_temp = snr_ca_avg_NoRM(find(data_surround==data_surround(i_s)));
    subplot(2,3,i_s);
    hold on; boxplot([snr_f_back_temp(:), snr_f_back_neuropil_temp(:), ...
        snr_f_back_SNR_temp(:),  snr_f_back_SNR_neuropil_temp(:),...
        snr_f_back_NoRM_temp(:), snr_f_back_NoRM_neuropil_temp(:)],...
        'Labels',{'back','back, no neuropil','SNR','SNR, no neuropil','NoRM','NoRM, no neuropil'});
    ylabel('SNR fluo');
    title(['surround=' num2str(surr_array(i_s))]);
end

figure; 
surr_array = unique(data_surround);
for i_s = 1:length(surr_array)
    snr_ca_back_temp = snr_ca_avg_back(find(data_surround==surr_array(i_s)));
    snr_ca_back_neuropil_temp = snr_ca_avg_neuropil_back(find(data_surround==surr_array(i_s)));
    snr_ca_back_SNR_temp = snr_ca_avg_back_SNR(find(data_surround==surr_array(i_s)));
    snr_ca_back_SNR_neuropil_temp = snr_ca_avg_neuropil_back_SNR(find(data_surround==surr_array(i_s)));
    snr_ca_back_NoRM_temp = snr_ca_avg_back_NoRM(find(data_surround==surr_array(i_s)));
    snr_ca_back_NoRM_neuropil_temp = snr_ca_avg_neuropil_back_NoRM(find(data_surround==surr_array(i_s)));
%     snr_ca_noback_temp = snr_ca_avg_noback(find(data_surround==data_surround(i_s)));
%     snr_ca_SNR_temp = snr_ca_avg_SNR(find(data_surround==data_surround(i_s)));
%     snr_ca_NoRM_temp = snr_ca_avg_NoRM(find(data_surround==data_surround(i_s)));
    subplot(2,3,i_s);
    hold on; boxplot([snr_ca_back_temp(:), snr_ca_back_neuropil_temp(:), ...
        snr_ca_back_SNR_temp(:),  snr_ca_back_SNR_neuropil_temp(:),...
        snr_ca_back_NoRM_temp(:), snr_ca_back_NoRM_neuropil_temp(:)],...
        'Labels',{'raw','raw, no neuropil','SNR','SNR, no neuropil','NoRM','NoRM, no neuropil'});
    ylabel('SNR deconvolved');
    title(['surround=' num2str(surr_array(i_s))]);
end

figure; 
surr_array = unique(data_surround);
for i_s = 1:length(surr_array)
    corr_f_back_temp = corr_f_avg_back(find(data_surround==surr_array(i_s)));
    corr_f_back_neuropil_temp = corr_f_avg_neuropil_back(find(data_surround==surr_array(i_s)));
    corr_f_back_SNR_temp = corr_f_avg_back_SNR(find(data_surround==surr_array(i_s)));
    corr_f_back_SNR_neuropil_temp = corr_f_avg_neuropil_back_SNR(find(data_surround==surr_array(i_s)));
    corr_f_back_NoRM_temp = corr_f_avg_back_NoRM(find(data_surround==surr_array(i_s)));
    corr_f_back_NoRM_neuropil_temp = corr_f_avg_neuropil_back_NoRM(find(data_surround==surr_array(i_s)));
%     snr_ca_noback_temp = snr_ca_avg_noback(find(data_surround==data_surround(i_s)));
%     snr_ca_SNR_temp = snr_ca_avg_SNR(find(data_surround==data_surround(i_s)));
%     snr_ca_NoRM_temp = snr_ca_avg_NoRM(find(data_surround==data_surround(i_s)));
    subplot(2,3,i_s);
    hold on; boxplot([corr_f_back_temp(:), corr_f_back_neuropil_temp(:), ...
        corr_f_back_SNR_temp(:), corr_f_back_SNR_neuropil_temp(:),...
        corr_f_back_NoRM_temp(:), corr_f_back_NoRM_neuropil_temp(:)],...
        'Labels',{'raw','raw, no neuropil','SNR','SNR, no neuropil','NoRM','NoRM, no neuropil'});
    ylabel('corr fluo');
    title(['surround=' num2str(surr_array(i_s))]);
end