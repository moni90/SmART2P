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

% %keep only with reference box
% id_keep3 = find(data_ref_box);
% data_folder = data_folder(id_keep3);
% animal_state = animal_state(id_keep3);
% data_day = data_day(id_keep3);
% data_name = data_name(id_keep3);
% data_surround = data_surround(id_keep3);
% data_ref_box = data_ref_box(id_keep3);
% ref_ROIs = ref_ROIs(id_keep3);


%%
if anesthetized == 1
    id_keep_def = [1 4 5 11 17 26 27 32 33 34 35 37 40 42 45 46 47 48 49 148 149 ...
        150 151 152 153 154 155 156 157 158 159 160 164 167 171 172 175 176 177 ...
        178 180 181 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 ...
        204 205 206 207 208 209 210 211 212 213 214 215 216 223 226 228 229 235 ...
        245 246 247 250 251 252 253 254 255 256];
else
    id_keep_def = [6 12 13 22 23 24 25 26 27 28]; %awake
end

% id_keep_def = 1:1:length(id_keep2);
% id_keep_def = find(data_ref_box);
down_rate = [0.1 1 Inf];
%% run analyses
err_data = string([]);
time_SNR = NaN * ones(length(id_keep_def),1);
time_NoRM = NaN * ones(length(id_keep_def),length(down_rate));
num_ROIs = NaN * ones(length(id_keep_def),length(down_rate));

snr_f_avg_noback = NaN * ones(length(id_keep_def),length(down_rate));
snr_f_avg_SNR = NaN * ones(length(id_keep_def),1);
snr_f_avg_NoRM = NaN * ones(length(id_keep_def),length(down_rate));

surr_pooled = [];
surr_pooled_NoRM = [];

snr_f_pooled_noback = [];
snr_f_pooled_SNR = [];
snr_f_pooled_NoRM = [];

snr_ca_avg_noback = NaN * ones(length(id_keep_def),length(down_rate));
snr_ca_avg_SNR = NaN * ones(length(id_keep_def),1);
snr_ca_avg_NoRM = NaN * ones(length(id_keep_def),length(down_rate));

snr_ca_pooled_noback = [];
snr_ca_pooled_SNR = [];
snr_ca_pooled_NoRM = [];

corr_x_artefacts = zeros(length(down_rate)+1,length(down_rate)+1,length(id_keep_def));
corr_y_artefacts = zeros(length(down_rate)+1,length(down_rate)+1,length(id_keep_def));
%%
for id_exp = 1:length(id_keep_def)
    disp(id_exp);
    try
        large_artefacts_save_path = [save_path char(data_day(id_keep_def(id_exp))) char(data_name(id_keep_def(id_exp)))];
        
        local_artefacts_diff_rate_save_name = [large_artefacts_save_path 'local_artefacts_NoRM_diff_rate_v2.mat'];
        
        if exist(local_artefacts_diff_rate_save_name)
            load(local_artefacts_diff_rate_save_name);
            background_load_data = [large_artefacts_save_path 'no_background.mat'];
            load(background_load_data);
        else
            %load background subtracted data
            background_load_data = [large_artefacts_save_path 'no_background.mat'];
            load(background_load_data);
            
            
            %load data
            large_artefacts_load_data = [large_artefacts_save_path 'data_cut_PCA.mat'];
            load(large_artefacts_load_data);
            %register ROIs
            data = register_ROIs_ls(data,ref_ROIs(id_keep_def(id_exp)));
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
            
            save(local_artefacts_diff_rate_save_name,...
                    'shift_x_roi','shift_y_roi','snr_ca_SNR','snr_SNR',...
                    'time_temp_SNR','rois_f_SNR','rois_ca_SNR',...
                    'neuropil_SNR','-v7.3');
                
            if data_ref_box(id_keep_def(id_exp))==1
%                 tic;
                n_rows = size(data.reference_image,1);
                n_col = size(data.reference_image,2);
                scan_path = data.freehand_scan;
%                 process_opt.down_rate = 2;
                
                down_rate = [0.1 1 1/data.framePeriod];
                shift_x_NoRM = zeros(length(down_rate),size(movie_no_backgr,2));
                shift_y_NoRM = zeros(length(down_rate),size(movie_no_backgr,2));
                shift_x_fig = figure;
                shift_y_fig = figure;
                snr_NoRM = zeros(size(rois_ca_noback,1),length(down_rate));
                snr_ca_NoRM = zeros(size(rois_ca_noback,1),length(down_rate));
                time_temp_NoRM = zeros(1,length(down_rate));
                rois_f_NoRM = zeros(size(rois_ca_noback,1),size(rois_ca_noback,2),length(down_rate));
                rois_ca_NoRM = zeros(size(rois_ca_noback,1),size(rois_ca_noback,2),length(down_rate));
                neuropil_NoRM = zeros(size(rois_ca_noback,1),size(rois_ca_noback,2),length(down_rate));
                for i_rate = 1:length(down_rate)
                    tic;
                    [time_down, movie_down, rois_f0_down, rois_f_NoRM_temp, neuropil0_down, neuropil_NoRM_temp,...
                        snr0_down, snr_NoRM_temp,shift_x_NoRM(i_rate,:),shift_y_NoRM(i_rate,:)] = reassign_px_NoRM_keep_rate(movie_no_backgr',...
                        data.A, data.ring, data.surrounding, down_rate(i_rate),...
                        n_rows, n_col, scan_path, data.framePeriod);
                    close(gcf); close(gcf);
                    rois_f_NoRM(:,:,i_rate) = rois_f_NoRM_temp;
                    neuropil_NoRM(:,:,i_rate) = neuropil_NoRM_temp;
                    snr_NoRM(:,i_rate) = snr_NoRM_temp;
                    figure(shift_x_fig); hold on;
                    subplot(length(down_rate),1,i_rate); plot(shift_x_NoRM(i_rate,:));
                    figure(shift_y_fig); hold on;
                    subplot(length(down_rate),1,i_rate); plot(shift_y_NoRM(i_rate,:));
                    framePeriod_NoRM = data.framePeriod*round(1/(data.framePeriod*down_rate(i_rate)));
                    time_temp_NoRM(i_rate) = toc;
                    %downsample the movie
                    SLS_rate = 1/data.framePeriod;
                    down_fact = round(SLS_rate/down_rate(i_rate));
                    down_period_true = data.framePeriod*down_fact;
                    movie_avg = movmean(movie_no_backgr,down_fact,1);
                    rois_f_noback_avg = movmean(rois_f_noback,down_fact,2);
                    data_NoRM = sls_deconvolution(movie_avg,data,rois_f_NoRM(:,:,i_rate),rois_f_noback_avg,data.framePeriod);
                    rois_ca_NoRM(:,:,i_rate) = data_NoRM.C_df;
                    clear data_NoRM;
                    
%                     snr_ca_NoRM = zeros(size(rois_ca_noback,1),1);
                    for id_roi = 1:size(rois_ca_noback,1)
                        snr_ca_NoRM(id_roi,i_rate) = 10^(snr(rois_ca_NoRM(id_roi,:),rois_f_NoRM(id_roi,:)-rois_ca_NoRM(id_roi,:))/10);
                    end
                end
                
                save(local_artefacts_diff_rate_save_name,'time_down','shift_x_NoRM', 'shift_y_NoRM',...
                    'snr_ca_NoRM','snr_NoRM','time_temp_NoRM','rois_f_NoRM','rois_ca_NoRM',...
                    'neuropil_NoRM','-append');
            end
        end
        if data_ref_box(id_keep_def(id_exp))==1
            time_last = find(time_down>=10, 1, 'first');
            corr_y_mat = zeros(size(shift_y_NoRM,1)+1,size(shift_y_NoRM,1)+1,size(shift_y_roi,1));
            corr_x_mat = zeros(size(shift_x_NoRM,1)+1,size(shift_x_NoRM,1)+1,size(shift_x_roi,1));
            for id_roi = 1:size(shift_y_roi,1)
                corr_y_mat(:,:,id_roi) = corr([shift_y_roi(id_roi,1:end-time_last)' shift_y_NoRM(:,1:end-time_last)']);
                corr_x_mat(:,:,id_roi) = corr([shift_x_roi(id_roi,1:end-time_last)' shift_x_NoRM(:,1:end-time_last)']);
            end
%             figure;
%             subplot(1,2,1);
%             imagesc(nanmax(corr_y_mat,[],3)); colorbar;
%             subplot(1,2,2);
%             imagesc(nanmax(corr_x_mat,[],3)); colorbar;
            
            corr_x_artefacts(:,:,id_exp) = nanmax(corr_x_mat,[],3);
            corr_y_artefacts(:,:,id_exp) = nanmax(corr_y_mat,[],3);
            
%             figure;
%             subplot(1,2,1);
%             imagesc(corr([nanmean(shift_y_roi(:,1:end-time_last),1)' shift_y_NoRM(:,1:end-time_last)']))
%             colorbar; title('dy');
%             subplot(1,2,2);
%             imagesc(corr([nanmean(shift_x_roi(:,1:end-time_last),1)' shift_x_NoRM(:,1:end-time_last)']))
%             colorbar; title('dx');
            clear data;
            
            time_NoRM(id_exp,:) = time_temp_NoRM;
            snr_f_avg_NoRM(id_exp,:) = nanmean(snr_NoRM,1);
            snr_ca_avg_NoRM(id_exp,:) = nanmean(snr_ca_NoRM,1);
        end
        
        time_SNR(id_exp) = time_temp_SNR;
        
        snr_f_avg_noback(id_exp) = nanmean(snr_noback);
        snr_ca_avg_noback(id_exp) = nanmean(snr_ca_noback);
        
        snr_f_avg_SNR(id_exp) = nanmean(snr_SNR);
        snr_ca_avg_SNR(id_exp) = nanmean(snr_ca_SNR);
        
    catch
        err_data = [err_data; string([char(data_day(id_exp)) char(data_name(id_exp))])];
    end
    
end
%%
figure;
boxplot([snr_f_avg_SNR snr_f_avg_NoRM],...
    'Labels',{'SNR','NoRM 0.1Hz','NoRM 1Hz','NoRM'});
%     'Labels',{'SNR','NoRM 0.1Hz','NoRM 0.5Hz','NoRM 1Hz','NoRM 5Hz','NoRM 10Hz','NoRM'});
data_surround = data_surround(id_keep_def);
%%
box_plot_corr = figure; 
surr_array = unique(data_surround);
surr_array(surr_array>2)=2;
for i_s = 1:length(unique(surr_array))
    snr_f_avg_SNR_temp =  snr_f_avg_SNR(data_surround==surr_array(i_s));
    snr_f_avg_NoRM_temp =  snr_f_avg_NoRM(data_surround==surr_array(i_s),:);
    figure(box_plot_corr);    
    subplot(2,2,i_s);
    hold on; boxplot([snr_f_avg_SNR_temp snr_f_avg_NoRM_temp],...
        'Labels',{'SNR','NoRM 0.1Hz','NoRM 1Hz',...
        'NoRM'},'PlotStyle','traditional',...
        'orientation','horizontal');
%     'Labels',{'SNR','NoRM 0.1Hz','NoRM 0.5Hz','NoRM 1Hz',...
%         'NoRM 5Hz','NoRM 10Hz','NoRM'},'PlotStyle','traditional',...
%         'orientation','horizontal');
    ylabel('snr');
    title(['surround=' num2str(surr_array(i_s))]);
    [p,tbl,stats] = kruskalwallis([snr_f_avg_SNR_temp(:), snr_f_avg_NoRM_temp],...
    {'SNR','NoRM 0.1Hz','NoRM 1Hz','NoRM'});
%     {'SNR','NoRM 0.1Hz','NoRM 0.5Hz','NoRM 1Hz',...
%         'NoRM 5Hz','NoRM 10Hz','NoRM'});
    figure;
    c = multcompare(stats);
    title(['SNR. surround=' num2str(surr_array(i_s))]);
end
%%
box_plot_corr = figure; 
data_surround_temp = data_surround;
% data_surround_temp(data_surround_temp>2)=2;
data_surround_temp(data_surround_temp>0)=1;
surr_array = unique(data_surround_temp);
% surr_array(surr_array>2)=3;
for i_s = 1:length(unique(surr_array))
    snr_f_avg_noback_temp =  snr_f_avg_noback(data_surround_temp==surr_array(i_s));
    snr_f_avg_SNR_temp =  snr_f_avg_SNR(data_surround_temp==surr_array(i_s));
    snr_f_avg_NoRM_temp =  snr_f_avg_NoRM(data_surround_temp==surr_array(i_s),:);
    figure(box_plot_corr);    
    subplot(2,2,i_s);
    hold on; boxplot([snr_f_avg_noback_temp snr_f_avg_SNR_temp snr_f_avg_NoRM_temp],...
        'Labels',{'no back','SNR','NoRM 0.1Hz','NoRM 1Hz',...
        'NoRM'},'PlotStyle','traditional',...
        'orientation','horizontal');
    ylabel('snr');
    title(['surround=' num2str(surr_array(i_s))]);
    [p,tbl,stats] = kruskalwallis([snr_f_avg_noback_temp(:) snr_f_avg_SNR_temp(:), snr_f_avg_NoRM_temp],...
    {'no back','SNR','NoRM 0.1Hz','NoRM 1Hz','NoRM'});
    figure;
    c = multcompare(stats);
    title(['SNR. surround=' num2str(surr_array(i_s))]);
end

%%
figure;
subplot(2,2,1);
imagesc(nanmean(corr_x_artefacts,3)); caxis([0 1]);
title('mean dx'); colorbar;
subplot(2,2,2);
imagesc(nanmean(corr_y_artefacts,3)); caxis([0 1]);
title('mean dy'); colorbar;
subplot(2,2,3);
imagesc(nanstd(corr_x_artefacts,[],3)/sqrt(size(corr_x_artefacts,3))); %caxis([-1 1]);
title('SEM dx'); colorbar;
subplot(2,2,4);
imagesc(nanstd(corr_y_artefacts,[],3)/sqrt(size(corr_x_artefacts,3))); %caxis([-1 1]);
title('SEM dy'); colorbar;