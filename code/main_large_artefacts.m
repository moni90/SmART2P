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

%% run analyses
err_data = string([]);
n_lines = NaN * ones(length(data_folder),1);
sls_duration = NaN * ones(length(data_folder),1);
pixels_per_line = NaN * ones(length(data_folder),1);
time_large_artefacts = NaN * ones(length(data_folder),1);
fraction_cut = NaN * ones(length(data_folder),1);
var_explained = NaN * ones(length(data_folder),1);
avg_shift_x = NaN * ones(length(data_folder),1);
avg_shift_y = NaN * ones(length(data_folder),1);
num_ROIs = NaN * ones(length(data_folder),1);
for id_exp = 1:length(data_folder)
    disp(id_exp);
    try
        import_TS_path = char(strcat(data_folder(id_exp), animal_state(id_exp), data_day(id_exp), data_name(id_exp)));
        cd(import_TS_path);
        xml_temp = dir('*.xml');
        import_TS_xml = [xml_temp.folder '/' xml_temp.name];
        cd(working_dir);
        
        %initialize data structure
        options.mode = 'freehand';
        data = inizialize_data(import_TS_path,options);
        
        % extract info from .xml
        data = extract_metadata_sls(data,import_TS_xml);
        
        num_frames = NaN; %NaN for all
        data = import_sls_tiff(data,num_frames);
        n_lines(id_exp) = size(data.movie_doc.movie_ruido,1);
        sls_duration(id_exp) = n_lines(id_exp)*data.scanlinePeriod;
        pixels_per_line(id_exp) = size(data.movie_doc.movie_ruido,2);
        
        %compute large artefacts
%         tic;
        large_artefacts_save_path = [save_path char(data_day(id_exp)) char(data_name(id_exp))];
        large_artefacts_save_name = [large_artefacts_save_path 'large_artefacts_PCA.mat'];
        if exist(large_artefacts_save_name)
            load(large_artefacts_save_name);
        else
            mkdir(large_artefacts_save_path)
            tic;
            [coeff_all,score_all,~,~,explained]  = pca(data.movie_doc.movie_ruido, 'NumComponents',1);
            t_temp = toc;
            save(large_artefacts_save_name,'coeff_all','score_all','explained','t_temp','-v7.3');
            if data_ref_box(id_exp) == 1
                process_opt.ref_box = 'Yes';
                process_opt.down_rate = 1;
                ref_box_movie = find_ref_box(data.movie_doc.movie_ruido, data.freehand_scan);
                close;
                [time_down,down_rate,ref_box_movie_correct,shifts_x,shifts_y,shifts_all] = estimate_rigid_motion(ref_box_movie, data.framePeriod, process_opt.down_rate);
                close;
                save(large_artefacts_save_name,'time_down','down_rate','shifts_x','shifts_y','-append');
            end
        end
        
        if data_ref_box(id_exp) == 1
            avg_shift_x(id_exp) = nanmean(abs(shifts_x));
            avg_shift_y(id_exp) = nanmean(abs(shifts_y));
        end
        time_large_artefacts(id_exp) = t_temp; %save time spent for artefacts detection
        var_explained(id_exp) = explained(1); %variance expalined by 1st component
        
        score_all = score_all + abs(min(score_all));
        options.p = 2;
        [fit_all,~,~,~,~,~] = ...
            constrained_foopsi(score_all,[],[],[],[],options); %fit 1st PC of ROIs and
        n_corr = round(10/data.framePeriod); %sliding window of 10 s
        correl = zeros(length(score_all),1);
        for ii = 1:length(score_all)-n_corr
            correl(ii) = corr(score_all(ii:min(ii+n_corr,length(score_all))),fit_all(ii:min(ii+n_corr,length(score_all))));
        end
        correl(ii:end) = correl(ii-1);
        % figure; plot(correl);
        
%         ind_cut = find(correl<=0.3,1,'first');
        correl_below = correl<=0.3;
        below_cross = find(diff(correl_below)==1);
        below_cross(below_cross<5/data.framePeriod) = [];
        if ~isempty(below_cross)
            ind_cut = below_cross(1)+1;
        else
            ind_cut = [];
        end
        figure;
        subplot(4,1,[1 2]);
        imagesc(data.frameTimes,[],data.movie_doc.movie_ruido'); colorbar;
        xlabel('time (s)'); ylabel('pixels');
        subplot(4,1,3);
        plot(data.frameTimes,score_all,'k','LineWidth',1);
        hold on; plot(data.frameTimes,fit_all,'r','LineWidth',2);
        xlabel('time (s)');
        title(['var explained = ' num2str(explained(1))]);
        legend('First PC', 'AR(2) fit')
        subplot(4,1,4);
        plot(data.frameTimes,correl,'r','LineWidth',2);
        hold on; plot(data.frameTimes, 0.3*ones(length(data.frameTimes),1),'k--');
        xlabel('time (s)');
        if ~isempty(ind_cut)
            hold on; plot(data.frameTimes(ind_cut),correl(ind_cut),'r*');
            fraction_cut(id_exp) = 1-ind_cut/n_lines(id_exp);

            data.frameTimes = data.frameTimes(1:ind_cut);
            data.duration = ind_cut;
            data.activities = data.activities(1:ind_cut);
            data.activities_original = data.activities_original(1:ind_cut);
            data.pixelsTimes = data.pixelsTimes(1:ind_cut);
            data.bg_activity = data.bg_activity(1:ind_cut);
            data.activities_deconvolved = data.activities_deconvolved(1:ind_cut);
            data.movie_doc.movie_ruido = data.movie_doc.movie_ruido(1:ind_cut,:);
            data.movie_doc.num_frames = ind_cut;
        else
            fraction_cut(id_exp) = 0;
        end
        close;
        
        large_artefacts_save_data = [large_artefacts_save_path 'data_cut_PCA.mat'];
        save(large_artefacts_save_data,'data','-v7.3');
        
    catch
        err_data = [err_data; string(import_TS_path)];
    end
    
end

%% save results
large_artefacts_table = array2table([n_lines(:) sls_duration(:) pixels_per_line(:) ...
    time_large_artefacts(:) fraction_cut(:) var_explained(:) avg_shift_x(:) avg_shift_y(:)],...
    'VariableNames',{'n_lines','sls_duration','pixels_per_line',...
    'time_large_artefacts','fraction_cut','var_explained','avg_shift_x',...
    'avg_shift_y'});
if anesthetized == 1
    writetable(large_artefacts_table,[save_path_0 'anesthetized_large_artefacts_summary.csv']);
else
    writetable(large_artefacts_table,[save_path_0 'awake_large_artefacts_summary.csv']);
end


%% plot some stats
figure; histogram(n_lines);
xlabel('num acquired smartlines'); ylabel('num acquisitions');
disp(['num smartLines=' num2str(nanmean(n_lines)) '+/-' num2str(nanstd(n_lines)/sqrt(sum(1-isnan(n_lines)))) '(mean+/-sem)']);

figure; histogram(sls_duration);
xlabel('SLS duration (s)'); ylabel('num acquisitions');
disp(['SLS acquisition duration=' num2str(nanmean(sls_duration)) '+/-' num2str(nanstd(sls_duration)/sqrt(sum(1-isnan(sls_duration)))) '(mean+/-sem)']);

figure; histogram(time_large_artefacts);
xlabel('processing time large artefacts (s)'); ylabel('num acquisitions');
disp(['PC1 comput time=' num2str(nanmean(time_large_artefacts)) '+/-' num2str(nanstd(time_large_artefacts)/sqrt(sum(1-isnan(time_large_artefacts)))) '(mean+/-sem)']);
figure; scatter(time_large_artefacts,n_lines);
xlabel('processing time large artefacts (s)'); ylabel('num SL lines');
figure; scatter(n_lines,time_large_artefacts);
xlabel('num SL lines'); ylabel('processing time large artefacts (s)');
figure; scatter(n_lines.*pixels_per_line,time_large_artefacts);
n_trials = 30;
[x_m,y_m,y_sem] = group_data(n_lines.*pixels_per_line,time_large_artefacts, n_trials);
hold on; errorbar(x_m,y_m,y_sem,'k','LineWidth',2);
ylabel('processing time large artefacts (s)'); xlabel('num SL lines * num px per SL');
figure; scatter(sls_duration,time_large_artefacts);
xlabel('SLS duration (s)'); ylabel('processing time large artefacts (s)');

figure; histogram(fraction_cut);
xlabel('fraction SLS removed (%)'); ylabel('num acquisitions');
disp(['SLS removed=' num2str(nanmean(fraction_cut)) '+/-' num2str(nanstd(fraction_cut)/sqrt(sum(1-isnan(fraction_cut)))) '(mean+/-sem)']);

figure; histogram(var_explained);
xlabel('variance explained by 1st PC'); ylabel('num acquisitions');
disp(['variance expl PC1=' num2str(nanmean(var_explained)) '+/-' num2str(nanstd(var_explained)/sqrt(sum(1-isnan(var_explained)))) '(mean+/-sem)']);

data_surround_def = data_surround;
% data_surround_def(data_surround_def<=1)=0;
data_surround_def(data_surround_def>3)=3;
[mean_cut,std_cut,numel_cut] = grpstats(fraction_cut>0,data_surround_def,{'mean','std','numel'});
[p,tbl,stats]=anova1(1*(fraction_cut),data_surround_def);
[results]=multcompare(stats);
fitlm(data_surround,fraction_cut)
figure;
errorbar(unique(data_surround_def),mean_cut,std_cut./sqrt(numel_cut));
% test difference between 2 classes
xx1 = 1*(fraction_cut(data_surround_def==0));
xx2 = 1*(fraction_cut(data_surround_def==1));
norm1 = kstest(xx1);
norm2 = kstest(xx2);
if norm1==0 && norm2==0
    [h,p] = ttest2(xx1,xx2);
else
    [p,h] = ranksum(xx1,xx2);
end

rate_sls = 1./(sls_duration./n_lines);
[mean_rate,std_rate,numel_rate] = grpstats(rate_sls,data_surround_def,{'mean','std','numel'});
figure;
errorbar(unique(data_surround_def),mean_rate,std_rate./sqrt(numel_rate));


[mean_shift_x,std_shift_x,numel_shift_x] = grpstats(avg_shift_x,data_surround_def,{'mean','std','numel'});
figure;
errorbar(unique(data_surround_def),mean_shift_x,std_shift_x./sqrt(numel_shift_x));
[mean_shift_y,std_shift_y,numel_shift_y] = grpstats(avg_shift_y,data_surround_def,{'mean','std','numel'});
figure;
errorbar(unique(data_surround_def),mean_shift_y,std_shift_y./sqrt(numel_shift_y));
[p,tbl,stats]=anova1(avg_shift_x+avg_shift_y,data_surround_def);
[results]=multcompare(stats);
fitlm([data_surround round(avg_shift_x+avg_shift_y)],1*(fraction_cut),'interactions')

mdl1 = fitlm([round(avg_shift_x+avg_shift_y)],1*(fraction_cut))
resid = mdl1.Residuals{:,1};
mdl2 = fitlm([data_surround],resid)

tbl_mle = array2table([data_surround round(avg_shift_x+avg_shift_y) 1*(fraction_cut)],'VariableNames',{'surr','shift','cut'});
full_lme = fitlme(tbl_mle,'cut~surr+(1|shift)+(surr-1|shift)','Exclude',find(isnan(tbl_mle{:,2})));
% full_lme = fitlme(tbl_mle,'cut~surr+(1+surr|shift)','Exclude',find(isnan(tbl_mle{:,2})));
intercept_lme = fitlme(tbl_mle,'cut~surr+(1|shift)','Exclude',find(isnan(tbl_mle{:,2}))); 
slope_lme = fitlme(tbl_mle,'cut~surr+(surr-1|shift)','Exclude',find(isnan(tbl_mle{:,2})));
fixed_lme = fitlme(tbl_mle,'cut~surr','Exclude',find(isnan(tbl_mle{:,2})));
full2_lme = fitlme(tbl_mle,'cut~surr+(surr|shift)','Exclude',find(isnan(tbl_mle{:,2})));%THIS IS THE BEST MODEL
[results] = compare(intercept_lme,full2_lme,'CheckNesting',true)
[table,siminfo] = compare(intercept_lme,full_lme,'nsim',100)
[table,siminfo] = compare(fixed_lme,intercept_lme,'nsim',100)
[table,siminfo] = compare(full2_lme,full_lme,'nsim',500)

beta = fixedEffects(full2_lme);
[~,~,STATS] = randomEffects(full2_lme); % Compute the random-effects statistics (STATS)


figure; 
surr_array = unique(data_surround_def);
for i_s = 1:length(surr_array)
    id_temp = find(data_surround_def==surr_array(i_s));
    fraction_cut_temp = fraction_cut(id_temp);
    dx_temp = avg_shift_x(id_temp);
    dy_temp = avg_shift_y(id_temp);
    
    dx_keep = avg_shift_x(fraction_cut_temp==0);
    dy_keep = avg_shift_y(fraction_cut_temp==0);
    dx_cut = avg_shift_x(fraction_cut_temp>0);
    dy_cut = avg_shift_y(fraction_cut_temp>0);
    
    fill_data = NaN*ones(max(length(dy_cut),length(dy_keep)),4);
    fill_data(1:length(dx_keep),1) = dx_keep;
    fill_data(1:length(dx_cut),2) = dx_cut;
    fill_data(1:length(dy_keep),3) = dy_keep;
    fill_data(1:length(dy_cut),4) = dy_cut;

    subplot(1,2,i_s);
    hold on; boxplot(fill_data,...
        'Labels',{'dx_avg no_artef','dx_avg artef','dy_avg no_artef','dy_avg artef'});
    ylabel('SNR fluo');
    title(['surround=' num2str(surr_array(i_s))]);
end

%% visual inspection of cut acquisitions

id_large = find(fraction_cut >0);

for ii = 1:length(id_large)
    id_exp = id_large(ii);
    import_TS_path = char(strcat(data_folder(id_exp), animal_state(id_exp), data_day(id_exp), data_name(id_exp)));
    cd(import_TS_path);
    xml_temp = dir('*.xml');
    import_TS_xml = [xml_temp.folder '/' xml_temp.name];
    cd(working_dir);
    
    %initialize data structure
    options.mode = 'freehand';
    data = inizialize_data(import_TS_path,options);
    
    % extract info from .xml
    data = extract_metadata_sls(data,import_TS_xml);
    
    num_frames = NaN; %NaN for all
    data = import_sls_tiff(data,num_frames);
    
    process_flag = 'Yes';
    process_opt.large_artefacts = 'Yes';
    if data_ref_box(id_exp) == 1
        process_opt.ref_box = 'Yes';
        process_opt.down_rate = 1;
    else
        process_opt.ref_box = 'No';
    end
    tic;
    [data, ind_cut] = sls_large_artefacts_PCA(data, process_opt);
    toc;
end