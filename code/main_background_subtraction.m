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


%% run analyses
err_data = string([]);
corr_f_avg_before = NaN * ones(length(data_folder),1);
corr_f_avg_after = NaN * ones(length(data_folder),1);
corr_ca_avg_before = NaN * ones(length(data_folder),1);
corr_ca_avg_after = NaN * ones(length(data_folder),1);
time_background = NaN * ones(length(data_folder),1);
num_ROIs = NaN * ones(length(data_folder),1);
corr_f_pooled_before = [];
corr_f_pooled_after = [];
corr_ca_pooled_before = [];
corr_ca_pooled_after = [];

snr_f_avg_raw = NaN * ones(length(data_folder),1);
snr_f_avg_noback = NaN * ones(length(data_folder),1);
snr_ca_avg_raw = NaN * ones(length(data_folder),1);
snr_ca_avg_noback = NaN * ones(length(data_folder),1);
%%
for id_exp = 1:length(data_folder)
    disp(id_exp);
    try
        large_artefacts_save_path = [save_path char(data_day(id_exp)) char(data_name(id_exp))];
        background_save_name = [large_artefacts_save_path 'no_background.mat'];
        
        if exist(background_save_name)
            load(background_save_name);
        else
            %load data
            large_artefacts_load_data = [large_artefacts_save_path 'data_cut_PCA.mat'];
            load(large_artefacts_load_data);
            
            %register ROIs
            data = register_ROIs_ls(data,ref_ROIs(id_exp));
            close
            
            %subtract background
            tic;
            process_opt.background = 'Yes';
            [rois_f_raw,neuropil_raw,snr_raw] = extract_ls_fluo(data.movie_doc.movie_ruido', ...
                data.A, data.ring, data.surrounding, data.framePeriod);
            [movie_no_backgr,backgr_m] = sls_subtract_background(data,process_opt);
            [rois_f_noback,neuropil_noback,snr_noback] = extract_ls_fluo(movie_no_backgr,...
                data.A, data.ring, data.surrounding, data.framePeriod);
            time_temp = toc;
            
            %deconvolve activity
            data_raw = sls_deconvolution(data.movie_doc.movie_ruido',data,rois_f_raw,rois_f_raw,data.framePeriod);
            rois_ca_raw = data_raw.C_df;
            clear data_raw;
            data_noback = sls_deconvolution(movie_no_backgr,data,rois_f_noback,rois_f_noback,data.framePeriod);
            rois_ca_noback = data_noback.C_df;
            clear data_noback;
            
            snr_ca_raw = zeros(size(rois_ca_raw,1),1);
            snr_ca_noback = zeros(size(rois_ca_noback,1),1);
            for id_roi = 1:size(rois_ca_noback,1)
                snr_ca_raw(id_roi) = 10^(snr(rois_ca_raw(id_roi,:),rois_f_raw(id_roi,:)-rois_ca_raw(id_roi,:))/10);
                snr_ca_noback(id_roi) = 10^(snr(rois_ca_noback(id_roi,:),rois_f_noback(id_roi,:)-rois_ca_noback(id_roi,:))/10);
            end
            
            %compute pairwise correlations
            corr_fluo_before = corr(rois_f_raw');
            corr_fluo_after = corr(rois_f_noback');
            corr_ca_before = corr(rois_ca_raw');
            corr_ca_after = corr(rois_ca_noback');
            
            %save results
            save(background_save_name,'movie_no_backgr','rois_f_noback','rois_ca_noback',...
                'neuropil_noback','snr_noback','snr_ca_noback','corr_fluo_before','corr_fluo_after',...
                'corr_ca_before','corr_ca_after','time_temp','snr_raw','snr_ca_raw','-v7.3');
            
            %         figure;
            %         subplot(2,4,[1 2 3]);
            %         imagesc(data.frameTimes,[],rois_f_raw); colorbar;
            %         xlabel('time (s)'); ylabel('ROI ID');
            %         subplot(2,4,4);
            %         imagesc(corr_fluo_before); colorbar; caxis([-1,1]);
            %         xlabel('ROI ID'); ylabel('ROI ID');
            %         subplot(2,4,[5 6 7]);
            %         imagesc(data.frameTimes,[],rois_f_noback); colorbar;
            %         xlabel('time (s)'); ylabel('ROI ID');
            %         subplot(2,4,8);
            %         imagesc(corr_fluo_after); colorbar; caxis([-1,1]);
            %         xlabel('ROI ID'); ylabel('ROI ID');
            %         close;
        end
        time_background(id_exp) = time_temp;
        num_ROIs(id_exp) = size(rois_f_noback,1);
        
        snr_f_avg_raw(id_exp) = nanmean(snr_raw-snr_raw);
        snr_f_avg_noback(id_exp) = nanmean(snr_noback-snr_raw);
        snr_ca_avg_raw(id_exp) = nanmean(snr_ca_raw-snr_ca_raw);
        snr_ca_avg_noback(id_exp) = nanmean(snr_ca_noback-snr_ca_raw);

        low_diag = tril(NaN*ones(size(rois_f_noback,1)));
        corr_f_avg_before(id_exp) = nanmean(corr_fluo_before(find(1-isnan(low_diag)))-corr_fluo_before(find(1-isnan(low_diag))));
        corr_f_avg_after(id_exp) = nanmean(corr_fluo_after(find(1-isnan(low_diag)))-corr_fluo_before(find(1-isnan(low_diag))));
        
        corr_f_pooled_before = [corr_f_pooled_before; corr_fluo_before(find(1-isnan(low_diag)))-corr_fluo_before(find(1-isnan(low_diag)))];
        corr_f_pooled_after = [corr_f_pooled_after; corr_fluo_after(find(1-isnan(low_diag)))-corr_fluo_before(find(1-isnan(low_diag)))];
        
        corr_ca_avg_before(id_exp) = nanmean(corr_ca_before(find(1-isnan(low_diag)))-corr_ca_before(find(1-isnan(low_diag))));
        corr_ca_avg_after(id_exp) = nanmean(corr_ca_after(find(1-isnan(low_diag)))-corr_ca_before(find(1-isnan(low_diag))));
        
        corr_ca_pooled_before = [corr_ca_pooled_before; corr_ca_before(find(1-isnan(low_diag)))-corr_ca_before(find(1-isnan(low_diag)))];
        corr_ca_pooled_after = [corr_ca_pooled_after; corr_ca_after(find(1-isnan(low_diag)))-corr_ca_before(find(1-isnan(low_diag)))];
        
        clear data;
    catch
        err_data = [err_data; string([char(data_day(id_exp)) char(data_name(id_exp))])];
    end
    
end

%% save results
background_table = array2table([time_background(:) corr_f_avg_before(:) corr_f_avg_after(:) ...
    corr_ca_avg_before(:) corr_ca_avg_after(:),num_ROIs(:)],...
    'VariableNames',{'time_background','corr_f_avg_before','corr_f_avg_after',...
    'corr_ca_avg_before','corr_ca_avg_after','num_ROIs'});
background_pooled_table = array2table([corr_f_pooled_before(:) corr_f_pooled_after(:)...
    corr_ca_pooled_before(:) corr_ca_pooled_after(:)],...
    'VariableNames',{'corr_f_pooled_before','corr_f_pooled_after',...
    'corr_ca_pooled_before','corr_ca_pooled_after'});
if anesthetized == 1
    writetable(background_table,[save_path_0 'anesthetized_background_summary.csv']);
    writetable(background_pooled_table,[save_path_0 'anesthetized_background_pooled.csv']);
else
    writetable(background_table,[save_path_0 'awake_background_summary.csv']);
    writetable(background_pooled_table,[save_path_0 'awake_background_pooled.csv']);
end


%% plot some stats

figure; histogram(time_background);
xlabel('processing time background (s)'); ylabel('num acquisitions');
disp(['background comput time=' num2str(nanmean(time_background)) '+/-' num2str(nanstd(time_background)/sqrt(sum(1-isnan(time_background)))) '(mean+/-sem)']);

figure; scatter(n_lines(id_keep2).*pixels_per_line(id_keep2),time_background);
ylabel('processing time background (s)'); xlabel('num SL lines * num px per SL');

figure; scatter(sls_duration(id_keep2),time_background);
ylabel('processing time background (s)'); xlabel('num SL lines * num px per SL');

figure; scatter(n_lines(id_keep2),time_background);
ylabel('processing time background (s)'); xlabel('num SL lines');

figure; scatter(pixels_per_line(id_keep2),time_background);
ylabel('processing time background (s)'); xlabel('num px per SL');

figure; histogram(corr_f_pooled_before);
hold on; histogram(corr_f_pooled_after);
legend('NO backgr subtraction','AFTER backgr subtraction');
xlabel('average pairwise correlations fluo'); ylabel('num acquisitions');
disp(['average pairwise correlations BEFORE=' num2str(nanmean(corr_f_pooled_before)) '+/-' num2str(nanstd(corr_f_pooled_before)/sqrt(sum(1-isnan(corr_f_pooled_before)))) '(mean+/-sem)']);
disp(['average pairwise correlations AFTER=' num2str(nanmean(corr_f_pooled_after)) '+/-' num2str(nanstd(corr_f_pooled_after)/sqrt(sum(1-isnan(corr_f_pooled_after)))) '(mean+/-sem)']);

figure; histogram(corr_ca_pooled_before);
hold on; histogram(corr_ca_pooled_after);
legend('NO backgr subtraction','AFTER backgr subtraction');
xlabel('average pairwise correlations deconvolved'); ylabel('num acquisitions');
disp(['average pairwise correlations BEFORE=' num2str(nanmean(corr_ca_pooled_before)) '+/-' num2str(nanstd(corr_ca_pooled_before)/sqrt(sum(1-isnan(corr_ca_pooled_before)))) '(mean+/-sem)']);
disp(['average pairwise correlations AFTER=' num2str(nanmean(corr_ca_pooled_after)) '+/-' num2str(nanstd(corr_ca_pooled_after)/sqrt(sum(1-isnan(corr_ca_pooled_after)))) '(mean+/-sem)']);


figure; scatter(corr_f_avg_before, corr_f_avg_after);
hold on; plot(-1:1:1,-1:1:1,'--k');
xlabel('pair corr fluo BEFORE'); ylabel('pair corr fluo AFTER');
figure; boxplot([corr_f_avg_before, corr_f_avg_after],...
        'Labels',{'with back','no back'});
ylabel('pair corr fluo');
disp(['average pairwise correlations BEFORE=' num2str(nanmean(corr_f_avg_before)) '+/-' num2str(nanstd(corr_f_avg_before)/sqrt(sum(1-isnan(corr_f_avg_before)))) '(mean+/-sem)']);
disp(['average pairwise correlations AFTER=' num2str(nanmean(corr_f_avg_after)) '+/-' num2str(nanstd(corr_f_avg_after)/sqrt(sum(1-isnan(corr_f_avg_after)))) '(mean+/-sem)']);
xx1 = corr_f_avg_before;
xx2 = corr_f_avg_after;
norm1 = kstest(xx1);
norm2 = kstest(xx2);
if norm1==0 && norm2==0
    [h,p] = ttest(xx1,xx2);
else
    [p,h] = signrank(xx1,xx2);
end

figure; scatter(corr_ca_avg_before, corr_ca_avg_after);
hold on; plot(-1:1:1,-1:1:1,'--k');
xlabel('pair corr deconvolved BEFORE'); ylabel('pair corr deconvolved AFTER');
disp(['average pairwise correlations BEFORE=' num2str(nanmean(corr_ca_avg_before)) '+/-' num2str(nanstd(corr_ca_avg_before)/sqrt(sum(1-isnan(corr_ca_avg_before)))) '(mean+/-sem)']);
disp(['average pairwise correlations AFTER=' num2str(nanmean(corr_ca_avg_after)) '+/-' num2str(nanstd(corr_ca_avg_after)/sqrt(sum(1-isnan(corr_ca_avg_after)))) '(mean+/-sem)']);

%%
%% BACKGROUND subtraction STATS

data_surround_keep = data_surround;
% data_surround_original = data_surround;
if anesthetized == 1
    data_surround_keep(data_surround_keep>=2)=2;
else
    data_surround_keep(data_surround_keep>=1)=1;
end
 
surr_array = unique(data_surround_keep);
snr_matrix = NaN*ones(length(data_surround_keep),length(surr_array));
corr_matrix = NaN*ones(length(data_surround_keep),length(surr_array));
p_snr = zeros(1,length(surr_array));
p_corr = zeros(1,length(surr_array));
for i_s = 1:length(surr_array)
    
    snr_f_back_temp = snr_f_avg_noback(find(data_surround_keep==surr_array(i_s)));
    
    corr_f_back_temp = corr_f_avg_after(find(data_surround_keep==surr_array(i_s)));
    
    snr_matrix(1:length( snr_f_back_temp),i_s) = snr_f_back_temp(:);
    corr_matrix(1:length( snr_f_back_temp),i_s) = corr_f_back_temp(:);
    [p_snr(i_s),h] = signrank(snr_matrix(:,i_s));
    [p_corr(i_s),h] = signrank(corr_matrix(:,i_s));

end

id_rows_remove = find(sum(isnan(snr_matrix),2) == size(snr_matrix,2));
snr_matrix(id_rows_remove,:) = [];
corr_matrix(id_rows_remove,:) = [];

data_table = array2table([snr_matrix; p_snr]);
if anesthetized == 1
    anesth_string = '_anest';
else
    anesth_string = '_awake';
end
writetable(data_table,[save_path_0 'SNR_background' anesth_string '.csv']);
data_table = array2table([corr_matrix; p_corr]);
if anesthetized == 1
    anesth_string = '_anest';
else
    anesth_string = '_awake';
end
writetable(data_table,[save_path_0 'CORR_background' anesth_string '.csv']);