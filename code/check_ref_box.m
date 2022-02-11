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
% id_keep_def = 1:1:length(id_keep2); %anesthetized
id_keep_def = [1 4 5 11 17 26 27 32 33 34 35 37 40 42 45 46 47 48 49 148 149 ...
    150 151 152 153 154 155 156 157 158 159 160 164 167 171 172 175 176 177 ...
    178 180 181 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 ...
    204 205 206 207 208 209 210 211 212 213 214 215 216 223 226 228 229 235 ...
    245 246 247 250 251 252 253 254 255 256];
% id_keep_def = [6 12 13 22 23 24 25 26 27 28]; %awake
down_rate = [0.1 0.5 1 5 10 Inf];
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



%%
for id_exp = 1:length(id_keep_def)
    disp(id_exp);
    try
        large_artefacts_save_path = [save_path char(data_day(id_keep_def(id_exp))) char(data_name(id_keep_def(id_exp)))];
        
        local_artefacts_diff_rate_save_name = [large_artefacts_save_path 'local_artefacts_NoRM_diff_rate.mat'];
        
        if 0%exist(local_artefacts_diff_rate_save_name)
            load(local_artefacts_diff_rate_save_name);
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

            
            
            
            if data_ref_box(id_keep_def(id_exp))==1
                
                scan_path = data.freehand_scan;
                down_rate = 2;

                ref_box_movie = find_ref_box(movie_no_backgr', scan_path);
                SLS_rate = 1/data.framePeriod;
                down_fact = round(SLS_rate/down_rate);
                % down_period_true = framePeriod*down_fact;
                ref_box_movie = movmean(ref_box_movie,down_fact,3);
                
                figure;
                for i = 1:min(floor(size(movie_avg,1)/down_fact),60)
                    subplot(6,10,i);
                    imagesc(ref_box_movie(:,:,(i-1)*down_fact+1)); colormap('gray');
                    if i == 5
                        title(num2str(id_keep_def(id_exp)))
                    end
                end
            end
        end
        
    catch
        err_data = [err_data; string([char(data_day(id_exp)) char(data_name(id_exp))])];
    end
    
end
%%
