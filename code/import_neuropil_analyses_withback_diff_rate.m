function [time_neuropil_back, time_neuropil_back_SNR, time_neuropil_back_NoRM_01,...
    time_neuropil_back_NoRM_1, time_neuropil_back_NoRM, snr_f_avg_raw,...
    snr_f_avg_neuropil_back, snr_f_avg_back_SNR, snr_f_avg_neuropil_back_SNR,...
    snr_f_avg_back_NoRM_01, snr_f_avg_back_NoRM_1, snr_f_avg_back_NoRM, ...
    snr_f_avg_neuropil_back_NoRM_01, snr_f_avg_neuropil_back_NoRM_1,...
    snr_f_avg_neuropil_back_NoRM, snr_ca_avg_raw, snr_ca_avg_neuropil_back,...
    snr_ca_avg_back_SNR, snr_ca_avg_neuropil_back_SNR, snr_ca_avg_back_NoRM_01,...
    snr_ca_avg_back_NoRM_1, snr_ca_avg_back_NoRM, snr_ca_avg_neuropil_back_NoRM_01,...
    snr_ca_avg_neuropil_back_NoRM_1, snr_ca_avg_neuropil_back_NoRM, ...
    corr_f_avg_raw, corr_f_avg_neuropil_back, corr_f_avg_back_SNR,...
    corr_f_avg_neuropil_back_SNR, corr_f_avg_back_NoRM_01, corr_f_avg_back_NoRM_1,...
    corr_f_avg_back_NoRM, corr_f_avg_neuropil_back_NoRM_01,...
    corr_f_avg_neuropil_back_NoRM_1, corr_f_avg_neuropil_back_NoRM,...
    corr_ca_avg_raw, corr_ca_avg_neuropil_back, corr_ca_avg_back_SNR,...
    corr_ca_avg_neuropil_back_SNR, corr_ca_avg_back_NoRM_01, corr_ca_avg_back_NoRM_1,...
    corr_ca_avg_back_NoRM, corr_ca_avg_neuropil_back_NoRM_01,...
    corr_ca_avg_neuropil_back_NoRM_1, corr_ca_avg_neuropil_back_NoRM] = ...
    import_neuropil_analyses_withback_diff_rate(filename, dataLines)
%IMPORTFILE Import data from a text file
%  [TIME_NEUROPIL_BACK, TIME_NEUROPIL_BACK_SNR,
%  TIME_NEUROPIL_BACK_NORM_01, TIME_NEUROPIL_BACK_NORM_1,
%  TIME_NEUROPIL_BACK_NORM, SNR_F_AVG_RAW, SNR_F_AVG_NEUROPIL_BACK,
%  SNR_F_AVG_BACK_SNR, SNR_F_AVG_NEUROPIL_BACK_SNR,
%  SNR_F_AVG_BACK_NORM_01, SNR_F_AVG_BACK_NORM_1, SNR_F_AVG_BACK_NORM,
%  SNR_F_AVG_NEUROPIL_BACK_NORM_01, SNR_F_AVG_NEUROPIL_BACK_NORM_1,
%  SNR_F_AVG_NEUROPIL_BACK_NORM, SNR_CA_AVG_RAW,
%  SNR_CA_AVG_NEUROPIL_BACK, SNR_CA_AVG_BACK_SNR,
%  SNR_CA_AVG_NEUROPIL_BACK_SNR, SNR_CA_AVG_BACK_NORM_01,
%  SNR_CA_AVG_BACK_NORM_1, SNR_CA_AVG_BACK_NORM,
%  SNR_CA_AVG_NEUROPIL_BACK_NORM_01, SNR_CA_AVG_NEUROPIL_BACK_NORM_1,
%  SNR_CA_AVG_NEUROPIL_BACK_NORM, CORR_F_AVG_RAW,
%  CORR_F_AVG_NEUROPIL_BACK, CORR_F_AVG_BACK_SNR,
%  CORR_F_AVG_NEUROPIL_BACK_SNR, CORR_F_AVG_BACK_NORM_01,
%  CORR_F_AVG_BACK_NORM_1, CORR_F_AVG_BACK_NORM,
%  CORR_F_AVG_NEUROPIL_BACK_NORM_01, CORR_F_AVG_NEUROPIL_BACK_NORM_1,
%  CORR_F_AVG_NEUROPIL_BACK_NORM, CORR_CA_AVG_RAW,
%  CORR_CA_AVG_NEUROPIL_BACK, CORR_CA_AVG_BACK_SNR,
%  CORR_CA_AVG_NEUROPIL_BACK_SNR, CORR_CA_AVG_BACK_NORM_01,
%  CORR_CA_AVG_BACK_NORM_1, CORR_CA_AVG_BACK_NORM,
%  CORR_CA_AVG_NEUROPIL_BACK_NORM_01, CORR_CA_AVG_NEUROPIL_BACK_NORM_1,
%  CORR_CA_AVG_NEUROPIL_BACK_NORM] = IMPORTFILE(FILENAME) reads data
%  from text file FILENAME for the default selection.  Returns the data
%  as column vectors.
%
%  [TIME_NEUROPIL_BACK, TIME_NEUROPIL_BACK_SNR,
%  TIME_NEUROPIL_BACK_NORM_01, TIME_NEUROPIL_BACK_NORM_1,
%  TIME_NEUROPIL_BACK_NORM, SNR_F_AVG_RAW, SNR_F_AVG_NEUROPIL_BACK,
%  SNR_F_AVG_BACK_SNR, SNR_F_AVG_NEUROPIL_BACK_SNR,
%  SNR_F_AVG_BACK_NORM_01, SNR_F_AVG_BACK_NORM_1, SNR_F_AVG_BACK_NORM,
%  SNR_F_AVG_NEUROPIL_BACK_NORM_01, SNR_F_AVG_NEUROPIL_BACK_NORM_1,
%  SNR_F_AVG_NEUROPIL_BACK_NORM, SNR_CA_AVG_RAW,
%  SNR_CA_AVG_NEUROPIL_BACK, SNR_CA_AVG_BACK_SNR,
%  SNR_CA_AVG_NEUROPIL_BACK_SNR, SNR_CA_AVG_BACK_NORM_01,
%  SNR_CA_AVG_BACK_NORM_1, SNR_CA_AVG_BACK_NORM,
%  SNR_CA_AVG_NEUROPIL_BACK_NORM_01, SNR_CA_AVG_NEUROPIL_BACK_NORM_1,
%  SNR_CA_AVG_NEUROPIL_BACK_NORM, CORR_F_AVG_RAW,
%  CORR_F_AVG_NEUROPIL_BACK, CORR_F_AVG_BACK_SNR,
%  CORR_F_AVG_NEUROPIL_BACK_SNR, CORR_F_AVG_BACK_NORM_01,
%  CORR_F_AVG_BACK_NORM_1, CORR_F_AVG_BACK_NORM,
%  CORR_F_AVG_NEUROPIL_BACK_NORM_01, CORR_F_AVG_NEUROPIL_BACK_NORM_1,
%  CORR_F_AVG_NEUROPIL_BACK_NORM, CORR_CA_AVG_RAW,
%  CORR_CA_AVG_NEUROPIL_BACK, CORR_CA_AVG_BACK_SNR,
%  CORR_CA_AVG_NEUROPIL_BACK_SNR, CORR_CA_AVG_BACK_NORM_01,
%  CORR_CA_AVG_BACK_NORM_1, CORR_CA_AVG_BACK_NORM,
%  CORR_CA_AVG_NEUROPIL_BACK_NORM_01, CORR_CA_AVG_NEUROPIL_BACK_NORM_1,
%  CORR_CA_AVG_NEUROPIL_BACK_NORM] = IMPORTFILE(FILE, DATALINES) reads
%  data for the specified row interval(s) of text file FILENAME. Specify
%  DATALINES as a positive scalar integer or a N-by-2 array of positive
%  scalar integers for dis-contiguous row intervals.
%
%  Example:
%  [time_neuropil_back, time_neuropil_back_SNR, time_neuropil_back_NoRM_01, time_neuropil_back_NoRM_1, time_neuropil_back_NoRM, snr_f_avg_raw, snr_f_avg_neuropil_back, snr_f_avg_back_SNR, snr_f_avg_neuropil_back_SNR, snr_f_avg_back_NoRM_01, snr_f_avg_back_NoRM_1, snr_f_avg_back_NoRM, snr_f_avg_neuropil_back_NoRM_01, snr_f_avg_neuropil_back_NoRM_1, snr_f_avg_neuropil_back_NoRM, snr_ca_avg_raw, snr_ca_avg_neuropil_back, snr_ca_avg_back_SNR, snr_ca_avg_neuropil_back_SNR, snr_ca_avg_back_NoRM_01, snr_ca_avg_back_NoRM_1, snr_ca_avg_back_NoRM, snr_ca_avg_neuropil_back_NoRM_01, snr_ca_avg_neuropil_back_NoRM_1, snr_ca_avg_neuropil_back_NoRM, corr_f_avg_raw, corr_f_avg_neuropil_back, corr_f_avg_back_SNR, corr_f_avg_neuropil_back_SNR, corr_f_avg_back_NoRM_01, corr_f_avg_back_NoRM_1, corr_f_avg_back_NoRM, corr_f_avg_neuropil_back_NoRM_01, corr_f_avg_neuropil_back_NoRM_1, corr_f_avg_neuropil_back_NoRM, corr_ca_avg_raw, corr_ca_avg_neuropil_back, corr_ca_avg_back_SNR, corr_ca_avg_neuropil_back_SNR, corr_ca_avg_back_NoRM_01, corr_ca_avg_back_NoRM_1, corr_ca_avg_back_NoRM, corr_ca_avg_neuropil_back_NoRM_01, corr_ca_avg_neuropil_back_NoRM_1, corr_ca_avg_neuropil_back_NoRM] = importfile("/media/DATA/mmoroni/software_sls_project/analyses/awake_neuropil_withback_summary_diff_rate.csv", [2, Inf]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 26-Jun-2020 13:59:07

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [2, Inf];
end

%% Setup the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 45);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["time_neuropil_back", "time_neuropil_back_SNR", "time_neuropil_back_NoRM_01", "time_neuropil_back_NoRM_1", "time_neuropil_back_NoRM", "snr_f_avg_raw", "snr_f_avg_neuropil_back", "snr_f_avg_back_SNR", "snr_f_avg_neuropil_back_SNR", "snr_f_avg_back_NoRM_01", "snr_f_avg_back_NoRM_1", "snr_f_avg_back_NoRM", "snr_f_avg_neuropil_back_NoRM_01", "snr_f_avg_neuropil_back_NoRM_1", "snr_f_avg_neuropil_back_NoRM", "snr_ca_avg_raw", "snr_ca_avg_neuropil_back", "snr_ca_avg_back_SNR", "snr_ca_avg_neuropil_back_SNR", "snr_ca_avg_back_NoRM_01", "snr_ca_avg_back_NoRM_1", "snr_ca_avg_back_NoRM", "snr_ca_avg_neuropil_back_NoRM_01", "snr_ca_avg_neuropil_back_NoRM_1", "snr_ca_avg_neuropil_back_NoRM", "corr_f_avg_raw", "corr_f_avg_neuropil_back", "corr_f_avg_back_SNR", "corr_f_avg_neuropil_back_SNR", "corr_f_avg_back_NoRM_01", "corr_f_avg_back_NoRM_1", "corr_f_avg_back_NoRM", "corr_f_avg_neuropil_back_NoRM_01", "corr_f_avg_neuropil_back_NoRM_1", "corr_f_avg_neuropil_back_NoRM", "corr_ca_avg_raw", "corr_ca_avg_neuropil_back", "corr_ca_avg_back_SNR", "corr_ca_avg_neuropil_back_SNR", "corr_ca_avg_back_NoRM_01", "corr_ca_avg_back_NoRM_1", "corr_ca_avg_back_NoRM", "corr_ca_avg_neuropil_back_NoRM_01", "corr_ca_avg_neuropil_back_NoRM_1", "corr_ca_avg_neuropil_back_NoRM"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Import the data
tbl = readtable(filename, opts);

%% Convert to output type
time_neuropil_back = tbl.time_neuropil_back;
time_neuropil_back_SNR = tbl.time_neuropil_back_SNR;
time_neuropil_back_NoRM_01 = tbl.time_neuropil_back_NoRM_01;
time_neuropil_back_NoRM_1 = tbl.time_neuropil_back_NoRM_1;
time_neuropil_back_NoRM = tbl.time_neuropil_back_NoRM;
snr_f_avg_raw = tbl.snr_f_avg_raw;
snr_f_avg_neuropil_back = tbl.snr_f_avg_neuropil_back;
snr_f_avg_back_SNR = tbl.snr_f_avg_back_SNR;
snr_f_avg_neuropil_back_SNR = tbl.snr_f_avg_neuropil_back_SNR;
snr_f_avg_back_NoRM_01 = tbl.snr_f_avg_back_NoRM_01;
snr_f_avg_back_NoRM_1 = tbl.snr_f_avg_back_NoRM_1;
snr_f_avg_back_NoRM = tbl.snr_f_avg_back_NoRM;
snr_f_avg_neuropil_back_NoRM_01 = tbl.snr_f_avg_neuropil_back_NoRM_01;
snr_f_avg_neuropil_back_NoRM_1 = tbl.snr_f_avg_neuropil_back_NoRM_1;
snr_f_avg_neuropil_back_NoRM = tbl.snr_f_avg_neuropil_back_NoRM;
snr_ca_avg_raw = tbl.snr_ca_avg_raw;
snr_ca_avg_neuropil_back = tbl.snr_ca_avg_neuropil_back;
snr_ca_avg_back_SNR = tbl.snr_ca_avg_back_SNR;
snr_ca_avg_neuropil_back_SNR = tbl.snr_ca_avg_neuropil_back_SNR;
snr_ca_avg_back_NoRM_01 = tbl.snr_ca_avg_back_NoRM_01;
snr_ca_avg_back_NoRM_1 = tbl.snr_ca_avg_back_NoRM_1;
snr_ca_avg_back_NoRM = tbl.snr_ca_avg_back_NoRM;
snr_ca_avg_neuropil_back_NoRM_01 = tbl.snr_ca_avg_neuropil_back_NoRM_01;
snr_ca_avg_neuropil_back_NoRM_1 = tbl.snr_ca_avg_neuropil_back_NoRM_1;
snr_ca_avg_neuropil_back_NoRM = tbl.snr_ca_avg_neuropil_back_NoRM;
corr_f_avg_raw = tbl.corr_f_avg_raw;
corr_f_avg_neuropil_back = tbl.corr_f_avg_neuropil_back;
corr_f_avg_back_SNR = tbl.corr_f_avg_back_SNR;
corr_f_avg_neuropil_back_SNR = tbl.corr_f_avg_neuropil_back_SNR;
corr_f_avg_back_NoRM_01 = tbl.corr_f_avg_back_NoRM_01;
corr_f_avg_back_NoRM_1 = tbl.corr_f_avg_back_NoRM_1;
corr_f_avg_back_NoRM = tbl.corr_f_avg_back_NoRM;
corr_f_avg_neuropil_back_NoRM_01 = tbl.corr_f_avg_neuropil_back_NoRM_01;
corr_f_avg_neuropil_back_NoRM_1 = tbl.corr_f_avg_neuropil_back_NoRM_1;
corr_f_avg_neuropil_back_NoRM = tbl.corr_f_avg_neuropil_back_NoRM;
corr_ca_avg_raw = tbl.corr_ca_avg_raw;
corr_ca_avg_neuropil_back = tbl.corr_ca_avg_neuropil_back;
corr_ca_avg_back_SNR = tbl.corr_ca_avg_back_SNR;
corr_ca_avg_neuropil_back_SNR = tbl.corr_ca_avg_neuropil_back_SNR;
corr_ca_avg_back_NoRM_01 = tbl.corr_ca_avg_back_NoRM_01;
corr_ca_avg_back_NoRM_1 = tbl.corr_ca_avg_back_NoRM_1;
corr_ca_avg_back_NoRM = tbl.corr_ca_avg_back_NoRM;
corr_ca_avg_neuropil_back_NoRM_01 = tbl.corr_ca_avg_neuropil_back_NoRM_01;
corr_ca_avg_neuropil_back_NoRM_1 = tbl.corr_ca_avg_neuropil_back_NoRM_1;
corr_ca_avg_neuropil_back_NoRM = tbl.corr_ca_avg_neuropil_back_NoRM;
end