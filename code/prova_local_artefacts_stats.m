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

%% select exp based on reference box
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

% snr_f_avg_neuropil_raw = NaN * ones(length(data_folder),1);
snr_f_avg_noback = NaN * ones(length(data_folder),1);
snr_f_avg_noback_SNR = NaN * ones(length(data_folder),1);
snr_f_avg_noback_NoRM = NaN * ones(length(data_folder),length(down_rate));
corr_f_avg_noback = NaN * ones(length(data_folder),1);
corr_f_avg_noback_SNR = NaN * ones(length(data_folder),1);
corr_f_avg_noback_NoRM= NaN * ones(length(data_folder),length(down_rate));

% snr_ca_avg_neuropil_raw = NaN * ones(length(data_folder),1);
snr_ca_avg_noback = NaN * ones(length(data_folder),1);
snr_ca_avg_noback_SNR = NaN * ones(length(data_folder),1);
snr_ca_avg_noback_NoRM = NaN * ones(length(data_folder),length(down_rate));
corr_ca_avg_noback = NaN * ones(length(data_folder),1);
corr_ca_avg_noback_SNR = NaN * ones(length(data_folder),1);
corr_ca_avg_noback_NoRM= NaN * ones(length(data_folder),length(down_rate));


% snr_f_avg_neuropil_raw = NaN * ones(length(data_folder),1);
snr_f_avg_raw = NaN * ones(length(data_folder),1);
snr_f_avg_back_SNR = NaN * ones(length(data_folder),1);
snr_f_avg_back_NoRM = NaN * ones(length(data_folder),length(down_rate));
corr_f_avg_raw = NaN * ones(length(data_folder),1);
corr_f_avg_back_SNR = NaN * ones(length(data_folder),1);
corr_f_avg_back_NoRM= NaN * ones(length(data_folder),length(down_rate));

% snr_ca_avg_neuropil_raw = NaN * ones(length(data_folder),1);
snr_ca_avg_raw = NaN * ones(length(data_folder),1);
snr_ca_avg_back_SNR = NaN * ones(length(data_folder),1);
snr_ca_avg_back_NoRM = NaN * ones(length(data_folder),length(down_rate));
corr_ca_avg_raw = NaN * ones(length(data_folder),1);
corr_ca_avg_back_SNR = NaN * ones(length(data_folder),1);
corr_ca_avg_back_NoRM= NaN * ones(length(data_folder),length(down_rate));


%%
for id_exp = 1:length(id_keep_def)
    disp(id_exp);
    try
        large_artefacts_save_path = [save_path char(data_day(id_keep_def(id_exp))) char(data_name(id_keep_def(id_exp)))];
         local_artefacts_diff_rate_load_data = [large_artefacts_save_path 'withback_local_artefacts_NoRM_diff_rate_v2.mat'];
        load(local_artefacts_diff_rate_load_data);

        
        %load background subtracted data
        background_load_data = [large_artefacts_save_path 'no_background.mat'];
        load(background_load_data);
        %load local processed data
        local_artefacts_SNR_load_data = [large_artefacts_save_path 'local_artefacts_SNR.mat'];
        load(local_artefacts_SNR_load_data);

        neuropil_subtracted_diff_rate_save_name = [large_artefacts_save_path 'withback_neuropil_subtracted_diff_rate.mat'];
        load(neuropil_subtracted_diff_rate_save_name);

        snr_f_avg_raw(id_exp) = nanmean(snr_raw-snr_raw);
        snr_f_avg_back_SNR(id_exp) = nanmean(snr_SNR-snr_raw);
        snr_ca_avg_raw(id_exp) = nanmean(snr_ca_raw-snr_raw);
        snr_ca_avg_back_SNR(id_exp) = nanmean(snr_ca_SNR-snr_raw);
        
        low_diag = tril(NaN*ones(size(rois_f_back_noneuropil,1)));
        corr_f_avg_raw(id_exp) = nanmean(corr_fluo_back(find(1-isnan(low_diag)))-corr_fluo_back(find(1-isnan(low_diag))));
        corr_f_avg_back_SNR(id_exp) = nanmean(corr_fluo_back_SNR(find(1-isnan(low_diag)))-corr_fluo_back(find(1-isnan(low_diag))));
        corr_ca_avg_raw(id_exp) = nanmean(corr_ca_back(find(1-isnan(low_diag)))-corr_fluo_back(find(1-isnan(low_diag))));
        corr_ca_avg_back_SNR(id_exp) = nanmean(corr_ca_back_SNR(find(1-isnan(low_diag)))-corr_fluo_back(find(1-isnan(low_diag))));
        
        if data_ref_box(id_keep_def(id_exp))==1
            snr_f_avg_back_NoRM(id_exp,:) = nanmean(snr_NoRM - repmat(snr_raw,1,length(down_rate)),1);
            snr_ca_avg_back_NoRM(id_exp,:) = nanmean(snr_ca_NoRM - repmat(snr_raw,1,length(down_rate)),1);
            for i_rate = 1:length(down_rate)
                corr_fluo_temp = corr_fluo_back_NoRM(:,:,i_rate);
                corr_f_avg_back_NoRM(id_exp,i_rate) = nanmean(corr_fluo_temp(find(1-isnan(low_diag)))-corr_fluo_back(find(1-isnan(low_diag))));
                corr_ca_temp = corr_ca_back_NoRM(:,:,i_rate);
                corr_ca_avg_back_NoRM(id_exp,i_rate) = nanmean(corr_ca_temp(find(1-isnan(low_diag)))-corr_fluo_back(find(1-isnan(low_diag))));
            end
        end
        
        local_artefacts_diff_rate_load_data = [large_artefacts_save_path 'local_artefacts_NoRM_diff_rate_v2.mat'];
        load(local_artefacts_diff_rate_load_data);
        neuropil_subtracted_diff_rate_save_name = [large_artefacts_save_path 'neuropil_subtracted_diff_rate.mat'];
        load(neuropil_subtracted_diff_rate_save_name);
        
        snr_f_avg_noback(id_exp) = nanmean(snr_noback);
        snr_f_avg_noback_SNR(id_exp) = nanmean(snr_SNR-snr_noback);
        snr_ca_avg_noback(id_exp) = nanmean(snr_ca_noback-snr_noback);
        snr_ca_avg_noback_SNR(id_exp) = nanmean(snr_ca_SNR-snr_noback);

        low_diag = tril(NaN*ones(size(rois_f_noback_noneuropil,1)));
        corr_f_avg_noback(id_exp) = nanmean(corr_fluo_noback(find(1-isnan(low_diag))));
        corr_f_avg_noback_SNR(id_exp) = nanmean(corr_fluo_noback_SNR(find(1-isnan(low_diag)))-corr_fluo_noback(find(1-isnan(low_diag))));
        corr_ca_avg_noback(id_exp) = nanmean(corr_ca_noback(find(1-isnan(low_diag)))-corr_fluo_noback(find(1-isnan(low_diag))));
        corr_ca_avg_noback_SNR(id_exp) = nanmean(corr_ca_noback_SNR(find(1-isnan(low_diag)))-corr_fluo_noback(find(1-isnan(low_diag))));
        
        if data_ref_box(id_keep_def(id_exp))==1
            snr_f_avg_noback_NoRM(id_exp,:) = nanmean(snr_NoRM - repmat(snr_noback,1,length(down_rate)),1);
            snr_ca_avg_noback_NoRM(id_exp,:) = nanmean(snr_ca_NoRM - repmat(snr_noback,1,length(down_rate)),1);
            for i_rate = 1:length(down_rate)
                corr_fluo_temp = corr_fluo_noback_NoRM(:,:,i_rate);
                corr_f_avg_noback_NoRM(id_exp,i_rate) = nanmean(corr_fluo_temp(find(1-isnan(low_diag)))-corr_fluo_noback(find(1-isnan(low_diag))));
                corr_ca_temp = corr_ca_noback_NoRM(:,:,i_rate);
                corr_ca_avg_noback_NoRM(id_exp,i_rate) = nanmean(corr_ca_temp(find(1-isnan(low_diag)))-corr_fluo_noback(find(1-isnan(low_diag)))); 
            end
        end
        
        clear data;
    catch
        err_data = [err_data; string([char(data_day(id_exp)) char(data_name(id_exp))])];
    end
    
end

%% ONLY LOCAL MOTION ARTEFACTS AFTER BACKGROUND SUBTRACTION

% data_surround_keep = data_surround(id_keep_def);
% % data_surround_original = data_surround;
% if anesthetized == 1
%     data_surround_keep(data_surround_keep>=2)=2;
% else
%     data_surround_keep(data_surround_keep>=1)=1;
% end
% 
% figure; 
% surr_array = unique(data_surround_keep);
% for i_s = 1:length(surr_array)
% 
%     snr_f_noback_temp = snr_f_avg_noback(find(data_surround_keep==surr_array(i_s)));
%     snr_f_noback_SNR_temp = snr_f_avg_noback_SNR(find(data_surround_keep==surr_array(i_s)));
%     snr_f_noback_NoRM_temp = snr_f_avg_noback_NoRM(find(data_surround_keep==surr_array(i_s)),:);
%     
%     corr_f_noback_temp = corr_f_avg_noback(find(data_surround_keep==surr_array(i_s)));
%     corr_f_noback_SNR_temp = corr_f_avg_noback_SNR(find(data_surround_keep==surr_array(i_s)));
%     corr_f_noback_NoRM_temp = corr_f_avg_noback_NoRM(find(data_surround_keep==surr_array(i_s)),:);
% %     snr_ca_noback_temp = snr_ca_avg_noback(find(data_surround==data_surround(i_s)));
% %     snr_ca_SNR_temp = snr_ca_avg_SNR(find(data_surround==data_surround(i_s)));
% %     snr_ca_NoRM_temp = snr_ca_avg_NoRM(find(data_surround==data_surround(i_s)));
%     subplot(4,2, 2*i_s-1);
%     if i_s == length(surr_array)
%     hold on; boxplot([snr_f_noback_temp(:) ...
%         snr_f_noback_SNR_temp(:)...
%         snr_f_noback_NoRM_temp],...
%         'Labels',{'no back','no back, SNR',...
%         'no back, NoRM 0.1','no back, NoRM 1','no back, NoRM'},...
%         'LabelOrientation','inline');
%     else
%         hold on; boxplot([snr_f_noback_temp(:) ...
%         snr_f_noback_SNR_temp(:)...
%         snr_f_noback_NoRM_temp]);
%     end
%     hold on; plot(1:1:5, zeros(1,5),'k')
%     ylabel('SNR fluo');
%     title(['surround=' num2str(surr_array(i_s))]);
%     
%     subplot(4,2, 2*i_s );
%     if i_s == length(surr_array)
%     hold on; boxplot([corr_f_noback_temp(:) ...
%         corr_f_noback_SNR_temp(:)...
%         corr_f_noback_NoRM_temp],...
%         'Labels',{'no back','no back, SNR',...
%         'no back, NoRM 0.1','no back, NoRM 1','no back, NoRM'},...
%         'LabelOrientation','inline');
%     else
%         hold on; boxplot([corr_f_noback_temp(:) ...
%         corr_f_noback_SNR_temp(:)...
%         corr_f_noback_NoRM_temp]);
%     end
%     hold on; plot(1:1:5, zeros(1,5),'k')
%     ylabel('corr fluo');
%     title(['surround=' num2str(surr_array(i_s))]);
% end

%% background subtracted

data_surround_keep = data_surround(id_keep_def);
% data_surround_original = data_surround;
if anesthetized == 1
    data_surround_keep(data_surround_keep>=2)=2;
else
    data_surround_keep(data_surround_keep>=1)=1;
end

figure; 
surr_array = unique(data_surround_keep);
for i_s = 1:length(surr_array)

    snr_f_noback_temp = snr_f_avg_noback(find(data_surround_keep==surr_array(i_s))) - snr_f_avg_noback(find(data_surround_keep==surr_array(i_s)));
    snr_f_noback_SNR_temp = snr_f_avg_noback_SNR(find(data_surround_keep==surr_array(i_s)));
    snr_f_noback_NoRM_temp = snr_f_avg_noback_NoRM(find(data_surround_keep==surr_array(i_s)),:);
    
    corr_f_noback_temp = corr_f_avg_noback(find(data_surround_keep==surr_array(i_s)))-corr_f_avg_noback(find(data_surround_keep==surr_array(i_s)));
    corr_f_noback_SNR_temp = corr_f_avg_noback_SNR(find(data_surround_keep==surr_array(i_s)));
    corr_f_noback_NoRM_temp = corr_f_avg_noback_NoRM(find(data_surround_keep==surr_array(i_s)),:);
    
    snr_matrix = [snr_f_noback_SNR_temp(:), snr_f_noback_NoRM_temp];
    corr_matrix = [corr_f_noback_SNR_temp(:), corr_f_noback_NoRM_temp];
    p_snr = zeros(1,size(snr_matrix,2));
    p_corr = zeros(1,size(corr_matrix,2));
    
%     [p,tbl,stats] = kruskalwallis([snr_f_noback_temp(:) snr_f_noback_SNR_temp(:), snr_f_noback_NoRM_temp],...
%         {'before', 'SNR','NoRM 0.1Hz','NoRM 1Hz','NoRM'});
%     figure;
%     c = multcompare(stats);
%     title(['no back. SNR. surround=' num2str(surr_array(i_s))]);
% 
%     [p,tbl,stats] = kruskalwallis([corr_f_noback_temp(:) corr_f_noback_SNR_temp(:), corr_f_noback_NoRM_temp],...
%         {'before','SNR','NoRM 0.1Hz','NoRM 1Hz','NoRM'});
%     figure;
%     c = multcompare(stats);
%     title(['no back. corr. surround=' num2str(surr_array(i_s))]);

    subplot(4,2, 2*i_s-1);
    if i_s == length(surr_array)
    hold on; boxplot([snr_f_noback_SNR_temp(:)...
        snr_f_noback_NoRM_temp],...
        'Labels',{'no back, SNR',...
        'no back, NoRM 0.1','no back, NoRM 1','no back, NoRM'},...
        'LabelOrientation','inline');
    else
        hold on; boxplot([snr_f_noback_SNR_temp(:)...
        snr_f_noback_NoRM_temp]);
    end
    for id_col = 1:size(snr_matrix,2)
        [p_snr(id_col),h] = signrank(snr_matrix(:,id_col));
        stars = convert_p_to_stars(p_snr(id_col));
        text(id_col,prctile(snr_matrix(:,id_col),95),stars);
    end
    hold on; plot(1:1:5, zeros(1,5),'k')
    ylabel('SNR fluo');
    title(['surround=' num2str(surr_array(i_s))]);
    
    subplot(4,2, 2*i_s );
    if i_s == length(surr_array)
    hold on; boxplot([corr_f_noback_SNR_temp(:)...
        corr_f_noback_NoRM_temp],...
        'Labels',{'no back, SNR',...
        'no back, NoRM 0.1','no back, NoRM 1','no back, NoRM'},...
        'LabelOrientation','inline');
    else
        hold on; boxplot([corr_f_noback_SNR_temp(:)...
        corr_f_noback_NoRM_temp]);
    end
    for id_col = 1:size(snr_matrix,2)
        [p_corr(id_col),h] = signrank(corr_matrix(:,id_col));
        stars = convert_p_to_stars(p_corr(id_col));
        text(id_col,prctile(corr_matrix(:,id_col),95),stars);
    end
    hold on; plot(1:1:5, zeros(1,5),'k')
    ylabel('corr fluo');
    title(['surround=' num2str(surr_array(i_s))]);
    
    data_table = array2table([snr_matrix; p_snr],...
        'VariableNames',{'SNR','NoRM_01','NoRM_1','NoRM'});
    if anesthetized == 1
        anesth_string = '_anest';
    else
        anesth_string = '_awake';
    end
    writetable(data_table,[save_path_0 'SNR_localArtefacts' anesth_string '_surr' num2str(surr_array(i_s)) '_raw.csv']);
    data_table = array2table([corr_matrix; p_corr],...
        'VariableNames',{'SNR','NoRM_01','NoRM_1','NoRM'});
    if anesthetized == 1
        anesth_string = '_anest';
    else
        anesth_string = '_awake';
    end
    writetable(data_table,[save_path_0 'CORR_localArtefacts' anesth_string '_surr' num2str(surr_array(i_s)) '_raw.csv']);
end


%% NOT background subtracted

data_surround_keep = data_surround(id_keep_def);
% data_surround_original = data_surround;
if anesthetized == 1
    data_surround_keep(data_surround_keep>=2)=2;
else
    data_surround_keep(data_surround_keep>=1)=1;
end

figure; 
surr_array = unique(data_surround_keep);
for i_s = 1:length(surr_array)

    snr_f_raw_temp = snr_f_avg_raw(find(data_surround_keep==surr_array(i_s)));
    snr_f_back_SNR_temp = snr_f_avg_back_SNR(find(data_surround_keep==surr_array(i_s)));
    snr_f_back_NoRM_temp = snr_f_avg_back_NoRM(find(data_surround_keep==surr_array(i_s)),:);
    
    corr_f_raw_temp = corr_f_avg_raw(find(data_surround_keep==surr_array(i_s)));
    corr_f_back_SNR_temp = corr_f_avg_back_SNR(find(data_surround_keep==surr_array(i_s)));
    corr_f_back_NoRM_temp = corr_f_avg_back_NoRM(find(data_surround_keep==surr_array(i_s)),:);
    
     snr_matrix = [snr_f_back_SNR_temp(:), snr_f_back_NoRM_temp];
    corr_matrix = [corr_f_back_SNR_temp(:), corr_f_back_NoRM_temp];
    p_snr = zeros(1,size(snr_matrix,2));
    p_corr = zeros(1,size(corr_matrix,2));
%     [p,tbl,stats] = kruskalwallis([snr_f_raw_temp(:) snr_f_back_SNR_temp(:), snr_f_back_NoRM_temp],...
%         {'before', 'SNR','NoRM 0.1Hz','NoRM 1Hz','NoRM'});
%     figure;
%     c = multcompare(stats);
%     title(['RAW. SNR. surround=' num2str(surr_array(i_s))]);
% 
%     [p,tbl,stats] = kruskalwallis([corr_f_raw_temp(:) corr_f_back_SNR_temp(:), corr_f_back_NoRM_temp],...
%         {'before','SNR','NoRM 0.1Hz','NoRM 1Hz','NoRM'});
%     figure;
%     c = multcompare(stats);
%     title(['RAW. corr. surround=' num2str(surr_array(i_s))]);
    
        subplot(4,2, 2*i_s-1);
    if i_s == length(surr_array)
    hold on; boxplot([snr_f_noback_SNR_temp(:)...
        snr_f_noback_NoRM_temp],...
        'Labels',{'only SNR',...
        'only NoRM 0.1','only NoRM 1','only NoRM'},...
        'LabelOrientation','inline');
    else
        hold on; boxplot([snr_f_noback_SNR_temp(:)...
        snr_f_noback_NoRM_temp]);
    end
    for id_col = 1:size(snr_matrix,2)
        [p_snr(id_col),h] = signrank(snr_matrix(:,id_col));
        stars = convert_p_to_stars(p_snr(id_col));
        text(id_col,prctile(snr_matrix(:,id_col),95),stars);
    end
    hold on; plot(1:1:5, zeros(1,5),'k')
    ylabel('SNR fluo');
    title(['surround=' num2str(surr_array(i_s))]);
    
    subplot(4,2, 2*i_s );
    if i_s == length(surr_array)
    hold on; boxplot([corr_f_noback_SNR_temp(:)...
        corr_f_noback_NoRM_temp],...
        'Labels',{'SNR',...
        'NoRM 0.1','NoRM 1','NoRM'},...
        'LabelOrientation','inline');
    else
        hold on; boxplot([corr_f_noback_SNR_temp(:)...
        corr_f_noback_NoRM_temp]);
    end
    for id_col = 1:size(snr_matrix,2)
        [p_corr(id_col),h] = signrank(corr_matrix(:,id_col));
        stars = convert_p_to_stars(p_corr(id_col));
        text(id_col,prctile(corr_matrix(:,id_col),95),stars);
    end
    hold on; plot(1:1:5, zeros(1,5),'k')
    ylabel('corr fluo');
    title(['surround=' num2str(surr_array(i_s))]);
    
    data_table = array2table([snr_matrix; p_snr],...
        'VariableNames',{'SNR','NoRM_01','NoRM_1','NoRM'});
    if anesthetized == 1
        anesth_string = '_anest';
    else
        anesth_string = '_awake';
    end
    writetable(data_table,[save_path_0 'SNR_localArtefacts' anesth_string '_surr' num2str(surr_array(i_s)) '_noback.csv']);
    data_table = array2table([corr_matrix; p_corr],...
        'VariableNames',{'SNR','NoRM_01','NoRM_1','NoRM'});
    if anesthetized == 1
        anesth_string = '_anest';
    else
        anesth_string = '_awake';
    end
    writetable(data_table,[save_path_0 'CORR_localArtefacts' anesth_string '_surr' num2str(surr_array(i_s)) '_noback.csv']);
end

%% all

data_surround_keep = data_surround(id_keep_def);
% data_surround_original = data_surround;
if anesthetized == 1
    data_surround_keep(data_surround_keep>=2)=2;
else
    data_surround_keep(data_surround_keep>=1)=1;
end

figure; 
surr_array = unique(data_surround_keep);
for i_s = 1:length(surr_array)
    
    snr_f_raw_temp = [snr_f_avg_raw(find(data_surround_keep==surr_array(i_s))); snr_f_avg_raw(find(data_surround_keep==surr_array(i_s)))];
    snr_f_back_SNR_temp = [snr_f_avg_back_SNR(find(data_surround_keep==surr_array(i_s))); snr_f_avg_noback_SNR(find(data_surround_keep==surr_array(i_s)))];
    snr_f_back_NoRM_temp = [snr_f_avg_back_NoRM(find(data_surround_keep==surr_array(i_s)),:); snr_f_avg_noback_NoRM(find(data_surround_keep==surr_array(i_s)),:)];
    
    corr_f_raw_temp = [corr_f_avg_raw(find(data_surround_keep==surr_array(i_s))); corr_f_avg_raw(find(data_surround_keep==surr_array(i_s)))];
    corr_f_back_SNR_temp = [corr_f_avg_back_SNR(find(data_surround_keep==surr_array(i_s))); corr_f_avg_noback_SNR(find(data_surround_keep==surr_array(i_s)))];
    corr_f_back_NoRM_temp = [corr_f_avg_back_NoRM(find(data_surround_keep==surr_array(i_s)),:); corr_f_avg_noback_NoRM(find(data_surround_keep==surr_array(i_s)),:);];
    
    snr_matrix = [snr_f_back_SNR_temp(:), snr_f_back_NoRM_temp];
    corr_matrix = [corr_f_back_SNR_temp(:), corr_f_back_NoRM_temp];
    p_snr = zeros(1,size(snr_matrix,2));
    p_corr = zeros(1,size(corr_matrix,2));
    
%     [p,tbl,stats] = kruskalwallis([snr_f_noback_temp(:) snr_f_noback_SNR_temp(:), snr_f_noback_NoRM_temp],...
%         {'before', 'SNR','NoRM 0.1Hz','NoRM 1Hz','NoRM'});
%     figure;
%     c = multcompare(stats);
%     title(['no back. SNR. surround=' num2str(surr_array(i_s))]);
% 
%     [p,tbl,stats] = kruskalwallis([corr_f_noback_temp(:) corr_f_noback_SNR_temp(:), corr_f_noback_NoRM_temp],...
%         {'before','SNR','NoRM 0.1Hz','NoRM 1Hz','NoRM'});
%     figure;
%     c = multcompare(stats);
%     title(['no back. corr. surround=' num2str(surr_array(i_s))]);

    subplot(4,2, 2*i_s-1);
    if i_s == length(surr_array)
    hold on; boxplot([snr_f_noback_SNR_temp(:)...
        snr_f_noback_NoRM_temp],...
        'Labels',{'SNR',...
        'NoRM 0.1','NoRM 1','NoRM'},...
        'LabelOrientation','inline');
    else
        hold on; boxplot([snr_f_noback_SNR_temp(:)...
        snr_f_noback_NoRM_temp]);
    end
    for id_col = 1:size(snr_matrix,2)
        [p_snr(id_col),h] = signrank(snr_matrix(:,id_col));
        stars = convert_p_to_stars(p_snr(id_col));
        text(id_col,prctile(snr_matrix(:,id_col),95),stars);
    end
    hold on; plot(1:1:5, zeros(1,5),'k')
    ylabel('SNR fluo');
    title(['surround=' num2str(surr_array(i_s))]);
    
    subplot(4,2, 2*i_s );
    if i_s == length(surr_array)
    hold on; boxplot([corr_f_noback_SNR_temp(:)...
        corr_f_noback_NoRM_temp],...
        'Labels',{'SNR',...
        'NoRM 0.1','NoRM 1','NoRM'},...
        'LabelOrientation','inline');
    else
        hold on; boxplot([corr_f_noback_SNR_temp(:)...
        corr_f_noback_NoRM_temp]);
    end
    for id_col = 1:size(snr_matrix,2)
        [p_corr(id_col),h] = signrank(corr_matrix(:,id_col));
        stars = convert_p_to_stars(p_corr(id_col));
        text(id_col,prctile(corr_matrix(:,id_col),95),stars);
    end
    hold on; plot(1:1:5, zeros(1,5),'k')
    ylabel('corr fluo');
    title(['surround=' num2str(surr_array(i_s))]);
    
    data_table = array2table([snr_matrix; p_snr],...
        'VariableNames',{'SNR','NoRM_01','NoRM_1','NoRM'});
    if anesthetized == 1
        anesth_string = '_anest';
    else
        anesth_string = '_awake';
    end
    writetable(data_table,[save_path_0 'SNR_localArtefacts' anesth_string '_surr' num2str(surr_array(i_s)) '_pooled.csv']);
    data_table = array2table([corr_matrix; p_corr],...
        'VariableNames',{'SNR','NoRM_01','NoRM_1','NoRM'});
    if anesthetized == 1
        anesth_string = '_anest';
    else
        anesth_string = '_awake';
    end
    writetable(data_table,[save_path_0 'CORR_localArtefacts' anesth_string '_surr' num2str(surr_array(i_s)) '_pooled.csv']);
end

%%
data_surround_keep = data_surround(id_keep_def);
% data_surround_original = data_surround;
if anesthetized == 1
    data_surround_keep(data_surround_keep>=2)=2;
else
    data_surround_keep(data_surround_keep>=1)=1;
end

figure; 
surr_array = unique(data_surround_keep);
for i_s = 1:length(surr_array)
    
    snr_f_raw_temp = [snr_f_avg_raw(find(data_surround_keep==surr_array(i_s))); snr_f_avg_raw(find(data_surround_keep==surr_array(i_s)))];
    snr_f_back_SNR_temp = [snr_f_avg_back_SNR(find(data_surround_keep==surr_array(i_s))); snr_f_avg_noback_SNR(find(data_surround_keep==surr_array(i_s)))];
    snr_f_back_NoRM_temp = [snr_f_avg_back_NoRM(find(data_surround_keep==surr_array(i_s)),:); snr_f_avg_noback_NoRM(find(data_surround_keep==surr_array(i_s)),:)];
    
    corr_f_raw_temp = [corr_f_avg_raw(find(data_surround_keep==surr_array(i_s))); corr_f_avg_raw(find(data_surround_keep==surr_array(i_s)))];
    corr_f_back_SNR_temp = [corr_f_avg_back_SNR(find(data_surround_keep==surr_array(i_s))); corr_f_avg_noback_SNR(find(data_surround_keep==surr_array(i_s)))];
    corr_f_back_NoRM_temp = [corr_f_avg_back_NoRM(find(data_surround_keep==surr_array(i_s)),:); corr_f_avg_noback_NoRM(find(data_surround_keep==surr_array(i_s)),:);];
    
    snr_matrix = [snr_f_back_SNR_temp(:), snr_f_back_NoRM_temp];
    corr_matrix = [corr_f_back_SNR_temp(:), corr_f_back_NoRM_temp];
    p_snr = zeros(1,size(snr_matrix,2));
    p_corr = zeros(1,size(corr_matrix,2));

    
    subplot(2,2, i_s );
    for id_method = 1:size(snr_matrix,2)
 
            hold on; scatter(snr_matrix(:,id_method),corr_matrix(:,id_method));

    end
    xlabel('SNR'); ylabel('corr fluo');
    title(['surround=' num2str(surr_array(i_s))]);
    
end
