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

%%
% if anesthetized == 1
%     id_keep_def = [1 4 5 11 17 26 27 32 33 34 35 37 40 42 45 46 47 48 49 148 149 ...
%         150 151 152 153 154 155 156 157 158 159 160 164 167 171 172 175 176 177 ...
%         178 180 181 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 ...
%         204 205 206 207 208 209 210 211 212 213 214 215 216 223 226 228 229 235 ...
%         245 246 247 250 251 252 253 254 255 256];
% else
%     id_keep_def = [6 12 13 22 23 24 25 26 27 28]; %awake
% end
id_keep_def = 1:1:length(id_keep2);
down_rate = [0.1 1 Inf];

%% run analyses
err_data = string([]);
% time_neuropil_raw = NaN * ones(length(data_folder),1);
time_neuropil_noback = NaN * ones(length(data_folder),1);
time_neuropil_noback_SNR = NaN * ones(length(data_folder),1);
time_neuropil_noback_NoRM = NaN * ones(length(data_folder),length(down_rate));


% snr_f_avg_neuropil_raw = NaN * ones(length(data_folder),1);
snr_f_avg_noback = NaN * ones(length(data_folder),1);
snr_f_avg_neuropil_noback = NaN * ones(length(data_folder),1);
snr_f_avg_neuropilPCA_noback = NaN * ones(length(data_folder),1);
snr_f_avg_noback_SNR = NaN * ones(length(data_folder),1);
snr_f_avg_neuropil_noback_SNR = NaN * ones(length(data_folder),1);
snr_f_avg_neuropilPCA_noback_SNR = NaN * ones(length(data_folder),1);
snr_f_avg_noback_NoRM = NaN * ones(length(data_folder),length(down_rate));
snr_f_avg_neuropil_noback_NoRM= NaN * ones(length(data_folder),length(down_rate));
snr_f_avg_neuropilPCA_noback_NoRM= NaN * ones(length(data_folder),length(down_rate));
corr_f_avg_raw = NaN * ones(length(data_folder),1);
corr_f_avg_noback = NaN * ones(length(data_folder),1);
corr_f_avg_neuropil_noback = NaN * ones(length(data_folder),1);
corr_f_avg_neuropilPCA_noback = NaN * ones(length(data_folder),1);
corr_f_avg_noback_SNR = NaN * ones(length(data_folder),1);
corr_f_avg_neuropil_noback_SNR = NaN * ones(length(data_folder),1);
corr_f_avg_neuropilPCA_noback_SNR = NaN * ones(length(data_folder),1);
corr_f_avg_noback_NoRM= NaN * ones(length(data_folder),length(down_rate));
corr_f_avg_neuropil_noback_NoRM= NaN * ones(length(data_folder),length(down_rate));
corr_f_avg_neuropilPCA_noback_NoRM= NaN * ones(length(data_folder),length(down_rate));

% snr_ca_avg_neuropil_raw = NaN * ones(length(data_folder),1);
snr_ca_avg_noback = NaN * ones(length(data_folder),1);
snr_ca_avg_neuropil_noback = NaN * ones(length(data_folder),1);
snr_ca_avg_neuropilPCA_noback = NaN * ones(length(data_folder),1);
snr_ca_avg_noback_SNR = NaN * ones(length(data_folder),1);
snr_ca_avg_neuropil_noback_SNR = NaN * ones(length(data_folder),1);
snr_ca_avg_neuropilPCA_noback_SNR = NaN * ones(length(data_folder),1);
snr_ca_avg_noback_NoRM = NaN * ones(length(data_folder),length(down_rate));
snr_ca_avg_neuropil_noback_NoRM= NaN * ones(length(data_folder),length(down_rate));
snr_ca_avg_neuropilPCA_noback_NoRM= NaN * ones(length(data_folder),length(down_rate));
corr_ca_avg_raw = NaN * ones(length(data_folder),1);
corr_ca_avg_noback = NaN * ones(length(data_folder),1);
corr_ca_avg_neuropil_noback = NaN * ones(length(data_folder),1);
corr_ca_avg_neuropilPCA_noback = NaN * ones(length(data_folder),1);
corr_ca_avg_noback_SNR = NaN * ones(length(data_folder),1);
corr_ca_avg_neuropil_noback_SNR = NaN * ones(length(data_folder),1);
corr_ca_avg_neuropilPCA_noback_SNR = NaN * ones(length(data_folder),1);
corr_ca_avg_noback_NoRM= NaN * ones(length(data_folder),length(down_rate));
corr_ca_avg_neuropil_noback_NoRM= NaN * ones(length(data_folder),length(down_rate));
corr_ca_avg_neuropilPCA_noback_NoRM= NaN * ones(length(data_folder),length(down_rate));


%%
for id_exp = 1:length(id_keep_def)
    disp(id_exp);
    try
        large_artefacts_save_path = [save_path char(data_day(id_keep_def(id_exp))) char(data_name(id_keep_def(id_exp)))];
        local_artefacts_diff_rate_load_data = [large_artefacts_save_path 'local_artefacts_NoRM_diff_rate_v2.mat'];
        load(local_artefacts_diff_rate_load_data);
        
        neuropil_subtracted_diff_rate_save_name = [large_artefacts_save_path 'neuropil_subtracted_diff_rate.mat'];
        
        %load background subtracted data
        background_load_data = [large_artefacts_save_path 'no_background.mat'];
        load(background_load_data);
        %load local processed data
        local_artefacts_SNR_load_data = [large_artefacts_save_path 'local_artefacts_SNR.mat'];
        load(local_artefacts_SNR_load_data);
%         local_artefacts_NoRM_load_data = [large_artefacts_save_path 'local_artefacts_NoRM.mat'];
%         if exist(local_artefacts_NoRM_load_data)
%             load(local_artefacts_NoRM_load_data);
%         end
        
        
        if exist(neuropil_subtracted_diff_rate_save_name)
            load(neuropil_subtracted_diff_rate_save_name);
        else
            %load data
            large_artefacts_load_data = [large_artefacts_save_path 'data_cut_PCA.mat'];
            load(large_artefacts_load_data);
            %register ROIs
            data = register_ROIs_ls(data,ref_ROIs(id_keep_def(id_exp)));
            close
            
            %subtract neuropil from data without background
            tic;
            [rois_neuro_ring,snr_ring,rois_neuro_pca,neuropil_pca, snr_pca] = subtract_neuropil_local(rois_f_noback, neuropil_noback, data.framePeriod);
            rois_f_noback_noneuropil = rois_neuro_ring;
            snr_f_noback_noneuropil = snr_ring;
            rois_f_noback_noneuropil_pca = rois_neuro_pca;
            snr_f_noback_noneuropil_pca = snr_pca;
            time_temp_neuropil_noback = toc;
            data_temp = sls_deconvolution(movie_no_backgr,data,rois_f_noback_noneuropil,rois_f_noback,data.framePeriod);
            rois_ca_noback_noneuropil = data_temp.C_df;
            clear data_temp;
            data_temp = sls_deconvolution(movie_no_backgr,data,rois_f_noback_noneuropil_pca,rois_f_noback,data.framePeriod);
            rois_ca_noback_noneuropil_pca = data_temp.C_df;
            clear data_temp;
            snr_ca_noback_noneuropil = zeros(size(rois_ca_noback_noneuropil,1),1);
            snr_ca_noback_noneuropil_pca = zeros(size(rois_ca_noback_noneuropil_pca,1),1);
            for id_roi = 1:size(rois_ca_noback_noneuropil,1)
                snr_ca_noback_noneuropil(id_roi) =...
                    10^(snr(rois_ca_noback_noneuropil(id_roi,:),rois_f_noback_noneuropil(id_roi,:)-rois_ca_noback_noneuropil(id_roi,:))/10);
                snr_ca_noback_noneuropil_pca(id_roi) =...
                    10^(snr(rois_ca_noback_noneuropil_pca(id_roi,:),rois_f_noback_noneuropil_pca(id_roi,:)-rois_ca_noback_noneuropil_pca(id_roi,:))/10);
            end
            corr_fluo_noback = corr(rois_f_noback');
            corr_ca_noback = corr(rois_ca_noback');
            corr_fluo_noback_noneuropil = corr(rois_f_noback_noneuropil');
            corr_ca_noback_noneuropil = corr(rois_ca_noback_noneuropil');
            corr_fluo_noback_noneuropil_pca = corr(rois_f_noback_noneuropil_pca');
            corr_ca_noback_noneuropil_pca = corr(rois_ca_noback_noneuropil_pca');
            
            %subtract neuropil from data without background and corrected
            %with SNR
            tic;
            [rois_neuro_ring,snr_ring,rois_neuro_pca,neuropil_pca, snr_pca] = subtract_neuropil_local(rois_f_SNR, neuropil_SNR, framePeriod_SNR);
            rois_f_noback_SNR_noneuropil = rois_neuro_ring;
            snr_f_noback_SNR_noneuropil = snr_ring;
            rois_f_noback_SNR_noneuropil_pca = rois_neuro_pca;
            snr_f_noback_SNR_noneuropil_pca = snr_pca;
            time_temp_neuropil_noback_SNR = toc;
            data_temp = sls_deconvolution(movie_no_backgr,data,rois_f_noback_SNR_noneuropil,rois_f_noback,data.framePeriod);
            rois_ca_noback_SNR_noneuropil = data_temp.C_df;
            clear data_temp;
            data_temp = sls_deconvolution(movie_no_backgr,data,rois_f_noback_SNR_noneuropil_pca,rois_f_noback,data.framePeriod);
            rois_ca_noback_SNR_noneuropil_pca = data_temp.C_df;
            clear data_temp;
            snr_ca_noback_SNR_noneuropil = zeros(size(rois_ca_noback_SNR_noneuropil,1),1);
            snr_ca_noback_SNR_noneuropil_pca = zeros(size(rois_ca_noback_SNR_noneuropil_pca,1),1);
            for id_roi = 1:size(rois_ca_noback_SNR_noneuropil,1)
                snr_ca_noback_SNR_noneuropil(id_roi) =...
                    10^(snr(rois_ca_noback_SNR_noneuropil(id_roi,:),rois_f_noback_SNR_noneuropil(id_roi,:)-rois_ca_noback_SNR_noneuropil(id_roi,:))/10);
                snr_ca_noback_SNR_noneuropil_pca(id_roi) =...
                    10^(snr(rois_ca_noback_SNR_noneuropil_pca(id_roi,:),rois_f_noback_SNR_noneuropil_pca(id_roi,:)-rois_ca_noback_SNR_noneuropil_pca(id_roi,:))/10);
            end
            corr_fluo_noback_SNR = corr(rois_f_SNR');
            corr_ca_noback_SNR = corr(rois_ca_SNR');
            corr_fluo_noback_SNR_noneuropil = corr(rois_f_noback_SNR_noneuropil');
            corr_ca_noback_SNR_noneuropil = corr(rois_ca_noback_SNR_noneuropil');
            corr_fluo_noback_SNR_noneuropil_pca = corr(rois_f_noback_SNR_noneuropil_pca');
            corr_ca_noback_SNR_noneuropil_pca = corr(rois_ca_noback_SNR_noneuropil_pca');
            
            save(neuropil_subtracted_diff_rate_save_name,...
                'rois_f_noback_noneuropil', 'snr_f_noback_noneuropil','rois_ca_noback_noneuropil',...
                'snr_ca_noback_noneuropil','corr_fluo_noback_noneuropil','corr_ca_noback_noneuropil',...
                'rois_f_noback_noneuropil_pca', 'snr_f_noback_noneuropil_pca','rois_ca_noback_noneuropil_pca',...
                'snr_ca_noback_noneuropil_pca','corr_fluo_noback_noneuropil_pca','corr_ca_noback_noneuropil_pca',...
                'corr_fluo_noback','corr_ca_noback','time_temp_neuropil_noback',...
                'rois_f_noback_SNR_noneuropil','snr_f_noback_SNR_noneuropil','rois_ca_noback_SNR_noneuropil',...
                'snr_ca_noback_SNR_noneuropil','corr_fluo_noback_SNR_noneuropil','corr_ca_noback_SNR_noneuropil',...
                'rois_f_noback_SNR_noneuropil_pca','snr_f_noback_SNR_noneuropil_pca','rois_ca_noback_SNR_noneuropil_pca',...
                'snr_ca_noback_SNR_noneuropil_pca','corr_fluo_noback_SNR_noneuropil_pca','corr_ca_noback_SNR_noneuropil_pca',...
                'corr_fluo_noback_SNR','corr_ca_noback_SNR','time_temp_neuropil_noback_SNR',...
                '-v7.3');
            
            if data_ref_box(id_keep_def(id_exp))==1
                down_rate = [0.1 1 1/data.framePeriod];
               
                snr_f_noback_NoRM_noneuropil = zeros(size(rois_ca_noback,1),length(down_rate));
                snr_ca_noback_NoRM_noneuropil = zeros(size(rois_ca_noback,1),length(down_rate));
                time_temp_neuropil_noback_NoRM = zeros(1,length(down_rate));
                rois_f_noback_NoRM_noneuropil = zeros(size(rois_ca_noback,1),size(rois_ca_noback,2),length(down_rate));
                rois_ca_noback_NoRM_noneuropil = zeros(size(rois_ca_noback,1),size(rois_ca_noback,2),length(down_rate));
                snr_f_noback_NoRM_noneuropil_pca = zeros(size(rois_ca_noback,1),length(down_rate));
                snr_ca_noback_NoRM_noneuropil_pca = zeros(size(rois_ca_noback,1),length(down_rate));
                rois_f_noback_NoRM_noneuropil_pca = zeros(size(rois_ca_noback,1),size(rois_ca_noback,2),length(down_rate));
                rois_ca_noback_NoRM_noneuropil_pca = zeros(size(rois_ca_noback,1),size(rois_ca_noback,2),length(down_rate));
%                 neuropil_NoRM = zeros(size(rois_ca_noback,1),size(rois_ca_noback,2),length(down_rate));
                corr_fluo_noback_NoRM = zeros(size(rois_ca_noback,1),size(rois_ca_noback,1),length(down_rate));
                corr_ca_noback_NoRM = zeros(size(rois_ca_noback,1),size(rois_ca_noback,1),length(down_rate));
                corr_fluo_noback_NoRM_noneuropil = zeros(size(rois_ca_noback,1),size(rois_ca_noback,1),length(down_rate));
                corr_ca_noback_NoRM_noneuropil = zeros(size(rois_ca_noback,1),size(rois_ca_noback,1),length(down_rate));
                corr_fluo_noback_NoRM_noneuropil_pca = zeros(size(rois_ca_noback,1),size(rois_ca_noback,1),length(down_rate));
                corr_ca_noback_NoRM_noneuropil_pca = zeros(size(rois_ca_noback,1),size(rois_ca_noback,1),length(down_rate));
                
                for i_rate = 1:length(down_rate)
                    %subtract neuropil from data without background and corrected
                    %with NoRM
                    tic;
                    [rois_neuro_ring,snr_ring,rois_neuro_pca,neuropil_pca, snr_pca] = subtract_neuropil_local(rois_f_NoRM(:,:,i_rate), neuropil_NoRM(:,:,i_rate), data.framePeriod);
                    rois_f_noback_NoRM_noneuropil(:,:,i_rate) = rois_neuro_ring;
                    snr_f_noback_NoRM_noneuropil(:,i_rate) = snr_ring;
                    rois_f_noback_NoRM_noneuropil_pca(:,:,i_rate) = rois_neuro_pca;
                    snr_f_noback_NoRM_noneuropil_pca(:,i_rate) = snr_pca;
                    time_temp_neuropil_noback_NoRM(i_rate) = toc;
                    %downsample the movie
                    SLS_rate = 1/data.framePeriod;
                    down_fact = round(SLS_rate/down_rate(i_rate));
                    down_period_true = data.framePeriod*down_fact;
                    movie_avg = movmean(movie_no_backgr,down_fact,1);
                    rois_f_noback_avg = movmean(rois_f_noback,down_fact,2);
                    data_NoRM = sls_deconvolution(movie_avg,data,rois_f_noback_NoRM_noneuropil(:,:,i_rate),rois_f_noback_avg,data.framePeriod);
                    rois_ca_noback_NoRM_noneuropil(:,:,i_rate) = data_NoRM.C_df;
                    data_NoRM = sls_deconvolution(movie_avg,data,rois_f_noback_NoRM_noneuropil_pca(:,:,i_rate),rois_f_noback_avg,data.framePeriod);
                    rois_ca_noback_NoRM_noneuropil_pca(:,:,i_rate) = data_NoRM.C_df;
                    clear data_NoRM;
                    
                    %                 snr_ca_noback_NoRM_noneuropil = zeros(size(rois_ca_noback_NoRM_noneuropil,1),1);
                    for id_roi = 1:size(rois_ca_noback_NoRM_noneuropil,1)
                        snr_ca_noback_NoRM_noneuropil(id_roi,i_rate) =...
                            10^(snr(rois_ca_noback_NoRM_noneuropil(id_roi,:),rois_f_noback_NoRM_noneuropil(id_roi,:)-rois_ca_noback_NoRM_noneuropil(id_roi,:))/10);
                        snr_ca_noback_NoRM_noneuropil_pca(id_roi,i_rate) =...
                            10^(snr(rois_ca_noback_NoRM_noneuropil_pca(id_roi,:),...
                            rois_f_noback_NoRM_noneuropil_pca(id_roi,:)-rois_ca_noback_NoRM_noneuropil_pca(id_roi,:))/10);
                    
                    end
                    corr_fluo_noback_NoRM(:,:,i_rate) = corr(rois_f_NoRM(:,:,i_rate)');
                    corr_ca_noback_NoRM(:,:,i_rate) = corr(rois_ca_NoRM(:,:,i_rate)');
                    corr_fluo_noback_NoRM_noneuropil(:,:,i_rate) = corr(rois_f_noback_NoRM_noneuropil(:,:,i_rate)');
                    corr_ca_noback_NoRM_noneuropil(:,:,i_rate) = corr(rois_ca_noback_NoRM_noneuropil(:,:,i_rate)');
                    corr_fluo_noback_NoRM_noneuropil_pca(:,:,i_rate) = corr(rois_f_noback_NoRM_noneuropil_pca(:,:,i_rate)');
                    corr_ca_noback_NoRM_noneuropil_pca(:,:,i_rate) = corr(rois_ca_noback_NoRM_noneuropil_pca(:,:,i_rate)');
                end
                
                save(neuropil_subtracted_diff_rate_save_name,...
                    'rois_f_noback_NoRM_noneuropil', 'snr_f_noback_NoRM_noneuropil',...
                    'rois_ca_noback_NoRM_noneuropil','snr_ca_noback_NoRM_noneuropil',...
                    'rois_f_noback_NoRM_noneuropil_pca', 'snr_f_noback_NoRM_noneuropil_pca',...
                    'rois_ca_noback_NoRM_noneuropil_pca','snr_ca_noback_NoRM_noneuropil_pca',...
                    'corr_fluo_noback_NoRM','corr_ca_noback_NoRM',...
                    'corr_fluo_noback_NoRM_noneuropil','corr_ca_noback_NoRM_noneuropil',...
                    'corr_fluo_noback_NoRM_noneuropil_pca','corr_ca_noback_NoRM_noneuropil_pca',...
                    'time_temp_neuropil_noback_NoRM','-append');
            end

        end
        time_neuropil_noback(id_exp) = time_temp_neuropil_noback;
        time_neuropil_noback_SNR(id_exp) = time_temp_neuropil_noback_SNR;
        
        snr_f_avg_noback(id_exp) = nanmean(snr_noback);
        snr_f_avg_neuropil_noback(id_exp) = nanmean(snr_f_noback_noneuropil-snr_noback);
        snr_f_avg_neuropilPCA_noback(id_exp) = nanmean(snr_f_noback_noneuropil_pca-snr_noback);
        snr_f_avg_noback_SNR(id_exp) = nanmean(snr_SNR-snr_noback);
        snr_f_avg_neuropil_noback_SNR(id_exp) = nanmean(snr_f_noback_SNR_noneuropil-snr_noback);
        snr_f_avg_neuropilPCA_noback_SNR(id_exp) = nanmean(snr_f_noback_SNR_noneuropil_pca-snr_noback);
        snr_ca_avg_noback(id_exp) = nanmean(snr_ca_noback-snr_noback);
        snr_ca_avg_neuropil_noback(id_exp) = nanmean(snr_ca_noback_noneuropil-snr_noback);
        snr_ca_avg_neuropilPCA_noback(id_exp) = nanmean(snr_ca_noback_noneuropil_pca-snr_noback);
        snr_ca_avg_noback_SNR(id_exp) = nanmean(snr_ca_SNR-snr_noback);
        snr_ca_avg_neuropil_noback_SNR(id_exp) = nanmean(snr_ca_noback_SNR_noneuropil-snr_noback);
        snr_ca_avg_neuropilPCA_noback_SNR(id_exp) = nanmean(snr_ca_noback_SNR_noneuropil_pca-snr_noback);

        low_diag = tril(NaN*ones(size(rois_f_noback_noneuropil,1)));
        corr_f_avg_raw(id_exp) = nanmean(corr_fluo_before(find(1-isnan(low_diag))));
        corr_f_avg_noback(id_exp) = nanmean(corr_fluo_noback(find(1-isnan(low_diag)))-corr_fluo_before(find(1-isnan(low_diag))));
        corr_f_avg_neuropil_noback(id_exp) = nanmean(corr_fluo_noback_noneuropil(find(1-isnan(low_diag)))-corr_fluo_before(find(1-isnan(low_diag))));
        corr_f_avg_neuropilPCA_noback(id_exp) = nanmean(corr_fluo_noback_noneuropil_pca(find(1-isnan(low_diag)))-corr_fluo_before(find(1-isnan(low_diag))));
        corr_f_avg_noback_SNR(id_exp) = nanmean(corr_fluo_noback_SNR(find(1-isnan(low_diag)))-corr_fluo_before(find(1-isnan(low_diag))));
        corr_f_avg_neuropil_noback_SNR(id_exp) = nanmean(corr_fluo_noback_SNR_noneuropil(find(1-isnan(low_diag)))-corr_fluo_before(find(1-isnan(low_diag))));
        corr_f_avg_neuropilPCA_noback_SNR(id_exp) = nanmean(corr_fluo_noback_SNR_noneuropil_pca(find(1-isnan(low_diag)))-corr_fluo_before(find(1-isnan(low_diag))));
        corr_ca_avg_raw(id_exp) = nanmean(corr_ca_before(find(1-isnan(low_diag)))-corr_fluo_before(find(1-isnan(low_diag))));
        corr_ca_avg_noback(id_exp) = nanmean(corr_ca_noback(find(1-isnan(low_diag)))-corr_fluo_before(find(1-isnan(low_diag))));
        corr_ca_avg_neuropil_noback(id_exp) = nanmean(corr_ca_noback_noneuropil(find(1-isnan(low_diag)))-corr_fluo_before(find(1-isnan(low_diag))));
        corr_ca_avg_neuropilPCA_noback(id_exp) = nanmean(corr_ca_noback_noneuropil_pca(find(1-isnan(low_diag)))-corr_fluo_before(find(1-isnan(low_diag))));
        corr_ca_avg_noback_SNR(id_exp) = nanmean(corr_ca_noback_SNR(find(1-isnan(low_diag)))-corr_fluo_before(find(1-isnan(low_diag))));
        corr_ca_avg_neuropil_noback_SNR(id_exp) = nanmean(corr_ca_noback_SNR_noneuropil(find(1-isnan(low_diag)))-corr_fluo_before(find(1-isnan(low_diag))));
        corr_ca_avg_neuropilPCA_noback_SNR(id_exp) = nanmean(corr_ca_noback_SNR_noneuropil_pca(find(1-isnan(low_diag)))-corr_fluo_before(find(1-isnan(low_diag))));

        if data_ref_box(id_keep_def(id_exp))==1
            time_neuropil_noback_NoRM(id_exp,:) = time_temp_neuropil_noback_NoRM;
            snr_f_avg_noback_NoRM(id_exp,:) = nanmean(snr_NoRM - repmat(snr_noback,1,length(down_rate)),1);
            snr_f_avg_neuropil_noback_NoRM(id_exp,:) = nanmean(snr_f_noback_NoRM_noneuropil - repmat(snr_noback,1,length(down_rate)),1);
            snr_f_avg_neuropilPCA_noback_NoRM(id_exp,:) = nanmean(snr_f_noback_NoRM_noneuropil_pca - repmat(snr_noback,1,length(down_rate)),1);
            snr_ca_avg_noback_NoRM(id_exp,:) = nanmean(snr_ca_NoRM - repmat(snr_noback,1,length(down_rate)),1);
            snr_ca_avg_neuropil_noback_NoRM(id_exp,:) = nanmean(snr_ca_noback_NoRM_noneuropil - repmat(snr_noback,1,length(down_rate)),1);
            snr_ca_avg_neuropilPCA_noback_NoRM(id_exp,:) = nanmean(snr_ca_noback_NoRM_noneuropil_pca - repmat(snr_noback,1,length(down_rate)),1);
            for i_rate = 1:length(down_rate)
                corr_fluo_temp = corr_fluo_noback_NoRM(:,:,i_rate);
                corr_f_avg_noback_NoRM(id_exp,i_rate) = nanmean(corr_fluo_temp(find(1-isnan(low_diag)))-corr_fluo_before(find(1-isnan(low_diag))));
                corr_fluo_temp = corr_fluo_noback_NoRM_noneuropil(:,:,i_rate);
                corr_f_avg_neuropil_noback_NoRM(id_exp,i_rate) = nanmean(corr_fluo_temp(find(1-isnan(low_diag)))-corr_fluo_before(find(1-isnan(low_diag))));
                corr_fluo_temp = corr_fluo_noback_NoRM_noneuropil_pca(:,:,i_rate);
                corr_f_avg_neuropilPCA_noback_NoRM(id_exp,i_rate) = nanmean(corr_fluo_temp(find(1-isnan(low_diag)))-corr_fluo_before(find(1-isnan(low_diag))));
                corr_ca_temp = corr_ca_noback_NoRM(:,:,i_rate);
                corr_ca_avg_noback_NoRM(id_exp,i_rate) = nanmean(corr_ca_temp(find(1-isnan(low_diag)))-corr_fluo_before(find(1-isnan(low_diag))));
                corr_ca_temp = corr_ca_noback_NoRM_noneuropil(:,:,i_rate);
                corr_ca_avg_neuropil_noback_NoRM(id_exp,i_rate) = nanmean(corr_ca_temp(find(1-isnan(low_diag)))-corr_fluo_before(find(1-isnan(low_diag))));
                corr_ca_temp = corr_ca_noback_NoRM_noneuropil_pca(:,:,i_rate);
                corr_ca_avg_neuropilPCA_noback_NoRM(id_exp,i_rate) = nanmean(corr_ca_temp(find(1-isnan(low_diag)))-corr_fluo_before(find(1-isnan(low_diag))));
            end
        end
        
        clear data;
    catch
        err_data = [err_data; string([char(data_day(id_exp)) char(data_name(id_exp))])];
    end
    
end

%% save results
neuropil_table = array2table([time_neuropil_noback(:) time_neuropil_noback_SNR(:) time_neuropil_noback_NoRM...
    snr_f_avg_noback(:) snr_f_avg_neuropil_noback(:) snr_f_avg_neuropilPCA_noback(:) snr_f_avg_noback_SNR(:)...
    snr_f_avg_neuropil_noback_SNR(:)...
    snr_f_avg_noback_NoRM...
    snr_f_avg_neuropil_noback_NoRM...
    snr_f_avg_neuropilPCA_noback_NoRM...
    snr_ca_avg_noback(:) snr_ca_avg_neuropil_noback(:) snr_ca_avg_neuropilPCA_noback(:)...
    snr_ca_avg_noback_SNR(:) snr_ca_avg_neuropil_noback_SNR(:) snr_ca_avg_neuropilPCA_noback_SNR(:)...
    snr_ca_avg_noback_NoRM...
    snr_ca_avg_neuropil_noback_NoRM...
    snr_ca_avg_neuropilPCA_noback_NoRM...
    corr_f_avg_raw(:) corr_f_avg_noback(:) corr_f_avg_neuropil_noback(:) corr_f_avg_neuropilPCA_noback(:)...
    corr_f_avg_noback_SNR(:) corr_f_avg_neuropil_noback_SNR(:) corr_f_avg_neuropilPCA_noback_SNR(:)...
    corr_f_avg_noback_NoRM...
    corr_f_avg_neuropil_noback_NoRM...
    corr_f_avg_neuropilPCA_noback_NoRM...
    corr_ca_avg_raw(:) corr_ca_avg_noback(:) corr_ca_avg_neuropil_noback(:) corr_ca_avg_neuropilPCA_noback(:)...
    corr_ca_avg_noback_SNR(:) corr_ca_avg_neuropil_noback_SNR(:) corr_ca_avg_neuropilPCA_noback_SNR(:)...
    corr_ca_avg_noback_NoRM...
    corr_ca_avg_neuropil_noback_NoRM...
    corr_ca_avg_neuropilPCA_noback_NoRM],...
    'VariableNames',{'time_neuropil_noback','time_neuropil_noback_SNR',...
    'time_neuropil_noback_NoRM_01','time_neuropil_noback_NoRM_1','time_neuropil_noback_NoRM',...
    'snr_f_avg_noback','snr_f_avg_neuropil_noback','snr_f_avg_neuropilPCA_noback','snr_f_avg_noback_SNR',...
    'snr_f_avg_neuropil_noback_SNR',...
    'snr_f_avg_noback_NoRM_01','snr_f_avg_noback_NoRM_1','snr_f_avg_noback_NoRM',...
    'snr_f_avg_neuropil_noback_NoRM_01','snr_f_avg_neuropil_noback_NoRM_1','snr_f_avg_neuropil_noback_NoRM',...
    'snr_f_avg_neuropilPCA_noback_NoRM_01','snr_f_avg_neuropilPCA_noback_NoRM_1','snr_f_avg_neuropilPCA_noback_NoRM',...
    'snr_ca_avg_noback','snr_ca_avg_neuropil_noback','snr_ca_avg_neuropilPCA_noback',...
    'snr_ca_avg_noback_SNR','snr_ca_avg_neuropil_noback_SNR','snr_ca_avg_neuropilPCA_noback_SNR',...
    'snr_ca_avg_noback_NoRM_01','snr_ca_avg_noback_NoRM_1','snr_ca_avg_noback_NoRM',...
    'snr_ca_avg_neuropil_noback_NoRM_01','snr_ca_avg_neuropil_noback_NoRM_1','snr_ca_avg_neuropil_noback_NoRM',...
    'snr_ca_avg_neuropilPCA_noback_NoRM_01','snr_ca_avg_neuropilPCA_noback_NoRM_1','snr_ca_avg_neuropilPCA_noback_NoRM',...
    'corr_f_avg_raw','corr_f_avg_noback','corr_f_avg_neuropil_noback','corr_f_avg_neuropilPCA_noback',...
    'corr_f_avg_noback_SNR','corr_f_avg_neuropil_noback_SNR','corr_f_avg_neuropilPCA_noback_SNR',...
    'corr_f_avg_noback_NoRM_01','corr_f_avg_noback_NoRM_1','corr_f_avg_noback_NoRM',...
    'corr_f_avg_neuropil_noback_NoRM_01','corr_f_avg_neuropil_noback_NoRM_1','corr_f_avg_neuropil_noback_NoRM',...
    'corr_f_avg_neuropilPCA_noback_NoRM_01','corr_f_avg_neuropilPCA_noback_NoRM_1','corr_f_avg_neuropilPCA_noback_NoRM',...
    'corr_ca_avg_raw','corr_ca_avg_noback','corr_ca_avg_neuropil_noback','corr_ca_avg_neuropilPCA_noback',...
    'corr_ca_avg_noback_SNR','corr_ca_avg_neuropil_noback_SNR','corr_ca_avg_neuropilPCA_noback_SNR',...
    'corr_ca_avg_noback_NoRM_01','corr_ca_avg_noback_NoRM_1','corr_ca_avg_noback_NoRM',...
    'corr_ca_avg_neuropil_noback_NoRM_01','corr_ca_avg_neuropil_noback_NoRM_1','corr_ca_avg_neuropil_noback_NoRM'...
    'corr_ca_avg_neuropilPCA_noback_NoRM_01','corr_ca_avg_neuropilPCA_noback_NoRM_1','corr_ca_avg_neuropilPCA_noback_NoRM'});

if anesthetized == 1
    writetable(neuropil_table,[save_path_0 'anesthetized_neuropil_summary_diff_rate.csv']);
%     writetable(local_artefacts_pooled_table,[save_path_0 'anesthetized_neuropil_pooled.csv']);
else
    writetable(neuropil_table,[save_path_0 'awake_neuropil_summary_diff_rate.csv']);
%     writetable(local_artefacts_pooled_table,[save_path_0 'awake_neuropil_pooled.csv']);
end

%%
data_surround_keep = data_surround(id_keep_def);
% data_surround_original = data_surround;
data_surround_keep(data_surround_keep>=2)=2;

% snr_f_avg_noback = snr_f_avg_noback(id_keep_def);
% snr_f_avg_neuropil_noback = snr_f_avg_neuropil_noback(id_keep_def);
% snr_f_avg_noback_NoRM = snr_f_avg_noback_NoRM(id_keep_def,:);
% snr_f_avg_noback_SNR = snr_f_avg_noback_SNR(id_keep_def);
% snr_f_avg_neuropil_noback_SNR = snr_f_avg_neuropil_noback_SNR(id_keep_def);
% snr_f_avg_neuropil_noback_NoRM = snr_f_avg_neuropil_noback_NoRM(id_keep_def,:);

figure; 
surr_array = unique(data_surround_keep);
for i_s = 1:length(surr_array)
    snr_f_noback_temp = snr_f_avg_noback(find(data_surround_keep==surr_array(i_s)));
    snr_f_noback_neuropil_temp = snr_f_avg_neuropil_noback(find(data_surround_keep==surr_array(i_s)));
    snr_f_noback_neuropilPCA_temp = snr_f_avg_neuropilPCA_noback(data_surround_keep==surr_array(i_s));
    snr_f_noback_SNR_temp = snr_f_avg_noback_SNR(find(data_surround_keep==surr_array(i_s)));
    snr_f_noback_SNR_neuropil_temp = snr_f_avg_neuropil_noback_SNR(find(data_surround_keep==surr_array(i_s)));
    snr_f_noback_SNR_neuropilPCA_temp = snr_f_avg_neuropilPCA_noback_SNR(find(data_surround_keep==surr_array(i_s)));
    snr_f_noback_NoRM_temp = snr_f_avg_noback_NoRM(find(data_surround_keep==surr_array(i_s)),:);
    snr_f_noback_NoRM_neuropil_temp = snr_f_avg_neuropil_noback_NoRM(find(data_surround_keep==surr_array(i_s)),:);
    snr_f_noback_NoRM_neuropilPCA_temp = snr_f_avg_neuropilPCA_noback_NoRM(find(data_surround_keep==surr_array(i_s)),:);
%     snr_ca_noback_temp = snr_ca_avg_noback(find(data_surround==data_surround(i_s)));
%     snr_ca_SNR_temp = snr_ca_avg_SNR(find(data_surround==data_surround(i_s)));
%     snr_ca_NoRM_temp = snr_ca_avg_NoRM(find(data_surround==data_surround(i_s)));
    subplot(3,1,i_s);
    hold on; boxplot([snr_f_noback_temp(:), snr_f_noback_neuropil_temp(:), snr_f_noback_neuropilPCA_temp(:), ...
        snr_f_noback_SNR_temp(:),  snr_f_noback_SNR_neuropil_temp(:),  snr_f_noback_SNR_neuropilPCA_temp(:),...
        snr_f_noback_NoRM_temp, snr_f_noback_NoRM_neuropil_temp, snr_f_noback_NoRM_neuropilPCA_temp],...
        'Labels',{'no back','no back, no neuropil','no neuropil PCA','SNR','SNR, no neuropil','SNR, no neuropil PCA',...
        'NoRM 0.1','NoRM 1','NoRM',...
        'NoRM, no neuropil 0.1','NoRM, no neuropil 1','NoRM, no neuropil',...
        'NoRM, no neuropil PCA 0.1','NoRM, no neuropil PCA 1','NoRM, no neuropil PCA'});
    ylabel('SNR fluo');
    title(['surround=' num2str(surr_array(i_s))]);
end

%%
data_surround_keep = data_surround(id_keep_def);
% data_surround_original = data_surround;
data_surround_keep(data_surround_keep>=2)=2;

% snr_f_avg_noback = snr_f_avg_noback(id_keep_def);
% snr_f_avg_neuropil_noback = snr_f_avg_neuropil_noback(id_keep_def);
% snr_f_avg_noback_NoRM = snr_f_avg_noback_NoRM(id_keep_def,:);
% snr_f_avg_noback_SNR = snr_f_avg_noback_SNR(id_keep_def);
% snr_f_avg_neuropil_noback_SNR = snr_f_avg_neuropil_noback_SNR(id_keep_def);
% snr_f_avg_neuropil_noback_NoRM = snr_f_avg_neuropil_noback_NoRM(id_keep_def,:);

figure; 
surr_array = unique(data_surround_keep);
for i_s = 1:length(surr_array)
    corr_f_noback_temp = corr_f_avg_noback(find(data_surround_keep==surr_array(i_s)));
    corr_f_noback_neuropil_temp = corr_f_avg_neuropil_noback(find(data_surround_keep==surr_array(i_s)));
    corr_f_noback_neuropilPCA_temp = corr_f_avg_neuropilPCA_noback(find(data_surround_keep==surr_array(i_s)));
    corr_f_noback_SNR_temp = corr_f_avg_noback_SNR(find(data_surround_keep==surr_array(i_s)));
    corr_f_noback_SNR_neuropil_temp = corr_f_avg_neuropil_noback_SNR(find(data_surround_keep==surr_array(i_s)));
    corr_f_noback_SNR_neuropilPCA_temp = corr_f_avg_neuropilPCA_noback_SNR(find(data_surround_keep==surr_array(i_s)));
    corr_f_noback_NoRM_temp = corr_f_avg_noback_NoRM(find(data_surround_keep==surr_array(i_s)),:);
    corr_f_noback_NoRM_neuropil_temp = corr_f_avg_neuropil_noback_NoRM(find(data_surround_keep==surr_array(i_s)),:);
    corr_f_noback_NoRM_neuropilPCA_temp = corr_f_avg_neuropilPCA_noback_NoRM(find(data_surround_keep==surr_array(i_s)),:);
%     snr_ca_noback_temp = snr_ca_avg_noback(find(data_surround==data_surround(i_s)));
%     snr_ca_SNR_temp = snr_ca_avg_SNR(find(data_surround==data_surround(i_s)));
%     snr_ca_NoRM_temp = snr_ca_avg_NoRM(find(data_surround==data_surround(i_s)));
    subplot(3,1,i_s);
    hold on; boxplot([corr_f_noback_temp(:), corr_f_noback_neuropil_temp(:), corr_f_noback_neuropilPCA_temp(:), ...
        corr_f_noback_SNR_temp(:),  corr_f_noback_SNR_neuropil_temp(:),  corr_f_noback_SNR_neuropilPCA_temp(:),...
        corr_f_noback_NoRM_temp, corr_f_noback_NoRM_neuropil_temp, corr_f_noback_NoRM_neuropilPCA_temp],...
        'Labels',{'no back','no back, no neuropil','no neuropil PCA','SNR','SNR, no neuropil','SNR, no neuropil PCA',...
        'NoRM 0.1','NoRM 1','NoRM',...
        'NoRM, no neuropil 0.1','NoRM, no neuropil 1','NoRM, no neuropil',...
        'NoRM, no neuropil PCA 0.1','NoRM, no neuropil PCA 1','NoRM, no neuropil PCA'});
    ylabel('corr fluo');
    title(['surround=' num2str(surr_array(i_s))]);
end
