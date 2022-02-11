function [time_neuropil_noback, time_neuropil_noback_SNR, time_neuropil_noback_NoRM_01, time_neuropil_noback_NoRM_1, time_neuropil_noback_NoRM, snr_f_avg_noback, snr_f_avg_neuropil_noback, snr_f_avg_noback_SNR, snr_f_avg_neuropil_noback_SNR, snr_f_avg_noback_NoRM_01, snr_f_avg_noback_NoRM_1, snr_f_avg_noback_NoRM, snr_f_avg_neuropil_noback_NoRM_01, snr_f_avg_neuropil_noback_NoRM_1, snr_f_avg_neuropil_noback_NoRM, snr_ca_avg_noback, snr_ca_avg_neuropil_noback, snr_ca_avg_noback_SNR, snr_ca_avg_neuropil_noback_SNR, snr_ca_avg_noback_NoRM_01, snr_ca_avg_noback_NoRM_1, snr_ca_avg_noback_NoRM, snr_ca_avg_neuropil_noback_NoRM_01, snr_ca_avg_neuropil_noback_NoRM_1, snr_ca_avg_neuropil_noback_NoRM, corr_f_avg_raw, corr_f_avg_noback, corr_f_avg_neuropil_noback, corr_f_avg_noback_SNR, corr_f_avg_neuropil_noback_SNR, corr_f_avg_noback_NoRM_01, corr_f_avg_noback_NoRM_1, corr_f_avg_noback_NoRM, corr_f_avg_neuropil_noback_NoRM_01, corr_f_avg_neuropil_noback_NoRM_1, corr_f_avg_neuropil_noback_NoRM, corr_ca_avg_raw, corr_ca_avg_noback, corr_ca_avg_neuropil_noback, corr_ca_avg_noback_SNR, corr_ca_avg_neuropil_noback_SNR, corr_ca_avg_noback_NoRM_01, corr_ca_avg_noback_NoRM_1, corr_ca_avg_noback_NoRM, corr_ca_avg_neuropil_noback_NoRM_01, corr_ca_avg_neuropil_noback_NoRM_1, corr_ca_avg_neuropil_noback_NoRM] = import_neuropil_analyses_diff_rate(filename, dataLines)
%IMPORTFILE Import data from a text file
%  [TIME_NEUROPIL_NOBACK, TIME_NEUROPIL_NOBACK_SNR,
%  TIME_NEUROPIL_NOBACK_NORM_01, TIME_NEUROPIL_NOBACK_NORM_1,
%  TIME_NEUROPIL_NOBACK_NORM, SNR_F_AVG_NOBACK,
%  SNR_F_AVG_NEUROPIL_NOBACK, SNR_F_AVG_NOBACK_SNR,
%  SNR_F_AVG_NEUROPIL_NOBACK_SNR, SNR_F_AVG_NOBACK_NORM_01,
%  SNR_F_AVG_NOBACK_NORM_1, SNR_F_AVG_NOBACK_NORM,
%  SNR_F_AVG_NEUROPIL_NOBACK_NORM_01, SNR_F_AVG_NEUROPIL_NOBACK_NORM_1,
%  SNR_F_AVG_NEUROPIL_NOBACK_NORM, SNR_CA_AVG_NOBACK,
%  SNR_CA_AVG_NEUROPIL_NOBACK, SNR_CA_AVG_NOBACK_SNR,
%  SNR_CA_AVG_NEUROPIL_NOBACK_SNR, SNR_CA_AVG_NOBACK_NORM_01,
%  SNR_CA_AVG_NOBACK_NORM_1, SNR_CA_AVG_NOBACK_NORM,
%  SNR_CA_AVG_NEUROPIL_NOBACK_NORM_01,
%  SNR_CA_AVG_NEUROPIL_NOBACK_NORM_1, SNR_CA_AVG_NEUROPIL_NOBACK_NORM,
%  CORR_F_AVG_RAW, CORR_F_AVG_NOBACK, CORR_F_AVG_NEUROPIL_NOBACK,
%  CORR_F_AVG_NOBACK_SNR, CORR_F_AVG_NEUROPIL_NOBACK_SNR,
%  CORR_F_AVG_NOBACK_NORM_01, CORR_F_AVG_NOBACK_NORM_1,
%  CORR_F_AVG_NOBACK_NORM, CORR_F_AVG_NEUROPIL_NOBACK_NORM_01,
%  CORR_F_AVG_NEUROPIL_NOBACK_NORM_1, CORR_F_AVG_NEUROPIL_NOBACK_NORM,
%  CORR_CA_AVG_RAW, CORR_CA_AVG_NOBACK, CORR_CA_AVG_NEUROPIL_NOBACK,
%  CORR_CA_AVG_NOBACK_SNR, CORR_CA_AVG_NEUROPIL_NOBACK_SNR,
%  CORR_CA_AVG_NOBACK_NORM_01, CORR_CA_AVG_NOBACK_NORM_1,
%  CORR_CA_AVG_NOBACK_NORM, CORR_CA_AVG_NEUROPIL_NOBACK_NORM_01,
%  CORR_CA_AVG_NEUROPIL_NOBACK_NORM_1, CORR_CA_AVG_NEUROPIL_NOBACK_NORM]
%  = IMPORTFILE(FILENAME) reads data from text file FILENAME for the
%  default selection.  Returns the data as column vectors.
%
%  [TIME_NEUROPIL_NOBACK, TIME_NEUROPIL_NOBACK_SNR,
%  TIME_NEUROPIL_NOBACK_NORM_01, TIME_NEUROPIL_NOBACK_NORM_1,
%  TIME_NEUROPIL_NOBACK_NORM, SNR_F_AVG_NOBACK,
%  SNR_F_AVG_NEUROPIL_NOBACK, SNR_F_AVG_NOBACK_SNR,
%  SNR_F_AVG_NEUROPIL_NOBACK_SNR, SNR_F_AVG_NOBACK_NORM_01,
%  SNR_F_AVG_NOBACK_NORM_1, SNR_F_AVG_NOBACK_NORM,
%  SNR_F_AVG_NEUROPIL_NOBACK_NORM_01, SNR_F_AVG_NEUROPIL_NOBACK_NORM_1,
%  SNR_F_AVG_NEUROPIL_NOBACK_NORM, SNR_CA_AVG_NOBACK,
%  SNR_CA_AVG_NEUROPIL_NOBACK, SNR_CA_AVG_NOBACK_SNR,
%  SNR_CA_AVG_NEUROPIL_NOBACK_SNR, SNR_CA_AVG_NOBACK_NORM_01,
%  SNR_CA_AVG_NOBACK_NORM_1, SNR_CA_AVG_NOBACK_NORM,
%  SNR_CA_AVG_NEUROPIL_NOBACK_NORM_01,
%  SNR_CA_AVG_NEUROPIL_NOBACK_NORM_1, SNR_CA_AVG_NEUROPIL_NOBACK_NORM,
%  CORR_F_AVG_RAW, CORR_F_AVG_NOBACK, CORR_F_AVG_NEUROPIL_NOBACK,
%  CORR_F_AVG_NOBACK_SNR, CORR_F_AVG_NEUROPIL_NOBACK_SNR,
%  CORR_F_AVG_NOBACK_NORM_01, CORR_F_AVG_NOBACK_NORM_1,
%  CORR_F_AVG_NOBACK_NORM, CORR_F_AVG_NEUROPIL_NOBACK_NORM_01,
%  CORR_F_AVG_NEUROPIL_NOBACK_NORM_1, CORR_F_AVG_NEUROPIL_NOBACK_NORM,
%  CORR_CA_AVG_RAW, CORR_CA_AVG_NOBACK, CORR_CA_AVG_NEUROPIL_NOBACK,
%  CORR_CA_AVG_NOBACK_SNR, CORR_CA_AVG_NEUROPIL_NOBACK_SNR,
%  CORR_CA_AVG_NOBACK_NORM_01, CORR_CA_AVG_NOBACK_NORM_1,
%  CORR_CA_AVG_NOBACK_NORM, CORR_CA_AVG_NEUROPIL_NOBACK_NORM_01,
%  CORR_CA_AVG_NEUROPIL_NOBACK_NORM_1, CORR_CA_AVG_NEUROPIL_NOBACK_NORM]
%  = IMPORTFILE(FILE, DATALINES) reads data for the specified row
%  interval(s) of text file FILENAME. Specify DATALINES as a positive
%  scalar integer or a N-by-2 array of positive scalar integers for
%  dis-contiguous row intervals.
%
%  Example:
%  [time_neuropil_noback, time_neuropil_noback_SNR, time_neuropil_noback_NoRM_01, time_neuropil_noback_NoRM_1, time_neuropil_noback_NoRM, snr_f_avg_noback, snr_f_avg_neuropil_noback, snr_f_avg_noback_SNR, snr_f_avg_neuropil_noback_SNR, snr_f_avg_noback_NoRM_01, snr_f_avg_noback_NoRM_1, snr_f_avg_noback_NoRM, snr_f_avg_neuropil_noback_NoRM_01, snr_f_avg_neuropil_noback_NoRM_1, snr_f_avg_neuropil_noback_NoRM, snr_ca_avg_noback, snr_ca_avg_neuropil_noback, snr_ca_avg_noback_SNR, snr_ca_avg_neuropil_noback_SNR, snr_ca_avg_noback_NoRM_01, snr_ca_avg_noback_NoRM_1, snr_ca_avg_noback_NoRM, snr_ca_avg_neuropil_noback_NoRM_01, snr_ca_avg_neuropil_noback_NoRM_1, snr_ca_avg_neuropil_noback_NoRM, corr_f_avg_raw, corr_f_avg_noback, corr_f_avg_neuropil_noback, corr_f_avg_noback_SNR, corr_f_avg_neuropil_noback_SNR, corr_f_avg_noback_NoRM_01, corr_f_avg_noback_NoRM_1, corr_f_avg_noback_NoRM, corr_f_avg_neuropil_noback_NoRM_01, corr_f_avg_neuropil_noback_NoRM_1, corr_f_avg_neuropil_noback_NoRM, corr_ca_avg_raw, corr_ca_avg_noback, corr_ca_avg_neuropil_noback, corr_ca_avg_noback_SNR, corr_ca_avg_neuropil_noback_SNR, corr_ca_avg_noback_NoRM_01, corr_ca_avg_noback_NoRM_1, corr_ca_avg_noback_NoRM, corr_ca_avg_neuropil_noback_NoRM_01, corr_ca_avg_neuropil_noback_NoRM_1, corr_ca_avg_neuropil_noback_NoRM] = importfile("/media/DATA/mmoroni/software_sls_project/analyses/anesthetized_neuropil_summary_diff_rate.csv", [2, Inf]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 23-Jun-2020 10:09:08

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [2, Inf];
end

%% Setup the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 47);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["time_neuropil_noback", "time_neuropil_noback_SNR", "time_neuropil_noback_NoRM_01", "time_neuropil_noback_NoRM_1", "time_neuropil_noback_NoRM", "snr_f_avg_noback", "snr_f_avg_neuropil_noback", "snr_f_avg_noback_SNR", "snr_f_avg_neuropil_noback_SNR", "snr_f_avg_noback_NoRM_01", "snr_f_avg_noback_NoRM_1", "snr_f_avg_noback_NoRM", "snr_f_avg_neuropil_noback_NoRM_01", "snr_f_avg_neuropil_noback_NoRM_1", "snr_f_avg_neuropil_noback_NoRM", "snr_ca_avg_noback", "snr_ca_avg_neuropil_noback", "snr_ca_avg_noback_SNR", "snr_ca_avg_neuropil_noback_SNR", "snr_ca_avg_noback_NoRM_01", "snr_ca_avg_noback_NoRM_1", "snr_ca_avg_noback_NoRM", "snr_ca_avg_neuropil_noback_NoRM_01", "snr_ca_avg_neuropil_noback_NoRM_1", "snr_ca_avg_neuropil_noback_NoRM", "corr_f_avg_raw", "corr_f_avg_noback", "corr_f_avg_neuropil_noback", "corr_f_avg_noback_SNR", "corr_f_avg_neuropil_noback_SNR", "corr_f_avg_noback_NoRM_01", "corr_f_avg_noback_NoRM_1", "corr_f_avg_noback_NoRM", "corr_f_avg_neuropil_noback_NoRM_01", "corr_f_avg_neuropil_noback_NoRM_1", "corr_f_avg_neuropil_noback_NoRM", "corr_ca_avg_raw", "corr_ca_avg_noback", "corr_ca_avg_neuropil_noback", "corr_ca_avg_noback_SNR", "corr_ca_avg_neuropil_noback_SNR", "corr_ca_avg_noback_NoRM_01", "corr_ca_avg_noback_NoRM_1", "corr_ca_avg_noback_NoRM", "corr_ca_avg_neuropil_noback_NoRM_01", "corr_ca_avg_neuropil_noback_NoRM_1", "corr_ca_avg_neuropil_noback_NoRM"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Import the data
tbl = readtable(filename, opts);

%% Convert to output type
time_neuropil_noback = tbl.time_neuropil_noback;
time_neuropil_noback_SNR = tbl.time_neuropil_noback_SNR;
time_neuropil_noback_NoRM_01 = tbl.time_neuropil_noback_NoRM_01;
time_neuropil_noback_NoRM_1 = tbl.time_neuropil_noback_NoRM_1;
time_neuropil_noback_NoRM = tbl.time_neuropil_noback_NoRM;
snr_f_avg_noback = tbl.snr_f_avg_noback;
snr_f_avg_neuropil_noback = tbl.snr_f_avg_neuropil_noback;
snr_f_avg_noback_SNR = tbl.snr_f_avg_noback_SNR;
snr_f_avg_neuropil_noback_SNR = tbl.snr_f_avg_neuropil_noback_SNR;
snr_f_avg_noback_NoRM_01 = tbl.snr_f_avg_noback_NoRM_01;
snr_f_avg_noback_NoRM_1 = tbl.snr_f_avg_noback_NoRM_1;
snr_f_avg_noback_NoRM = tbl.snr_f_avg_noback_NoRM;
snr_f_avg_neuropil_noback_NoRM_01 = tbl.snr_f_avg_neuropil_noback_NoRM_01;
snr_f_avg_neuropil_noback_NoRM_1 = tbl.snr_f_avg_neuropil_noback_NoRM_1;
snr_f_avg_neuropil_noback_NoRM = tbl.snr_f_avg_neuropil_noback_NoRM;
snr_ca_avg_noback = tbl.snr_ca_avg_noback;
snr_ca_avg_neuropil_noback = tbl.snr_ca_avg_neuropil_noback;
snr_ca_avg_noback_SNR = tbl.snr_ca_avg_noback_SNR;
snr_ca_avg_neuropil_noback_SNR = tbl.snr_ca_avg_neuropil_noback_SNR;
snr_ca_avg_noback_NoRM_01 = tbl.snr_ca_avg_noback_NoRM_01;
snr_ca_avg_noback_NoRM_1 = tbl.snr_ca_avg_noback_NoRM_1;
snr_ca_avg_noback_NoRM = tbl.snr_ca_avg_noback_NoRM;
snr_ca_avg_neuropil_noback_NoRM_01 = tbl.snr_ca_avg_neuropil_noback_NoRM_01;
snr_ca_avg_neuropil_noback_NoRM_1 = tbl.snr_ca_avg_neuropil_noback_NoRM_1;
snr_ca_avg_neuropil_noback_NoRM = tbl.snr_ca_avg_neuropil_noback_NoRM;
corr_f_avg_raw = tbl.corr_f_avg_raw;
corr_f_avg_noback = tbl.corr_f_avg_noback;
corr_f_avg_neuropil_noback = tbl.corr_f_avg_neuropil_noback;
corr_f_avg_noback_SNR = tbl.corr_f_avg_noback_SNR;
corr_f_avg_neuropil_noback_SNR = tbl.corr_f_avg_neuropil_noback_SNR;
corr_f_avg_noback_NoRM_01 = tbl.corr_f_avg_noback_NoRM_01;
corr_f_avg_noback_NoRM_1 = tbl.corr_f_avg_noback_NoRM_1;
corr_f_avg_noback_NoRM = tbl.corr_f_avg_noback_NoRM;
corr_f_avg_neuropil_noback_NoRM_01 = tbl.corr_f_avg_neuropil_noback_NoRM_01;
corr_f_avg_neuropil_noback_NoRM_1 = tbl.corr_f_avg_neuropil_noback_NoRM_1;
corr_f_avg_neuropil_noback_NoRM = tbl.corr_f_avg_neuropil_noback_NoRM;
corr_ca_avg_raw = tbl.corr_ca_avg_raw;
corr_ca_avg_noback = tbl.corr_ca_avg_noback;
corr_ca_avg_neuropil_noback = tbl.corr_ca_avg_neuropil_noback;
corr_ca_avg_noback_SNR = tbl.corr_ca_avg_noback_SNR;
corr_ca_avg_neuropil_noback_SNR = tbl.corr_ca_avg_neuropil_noback_SNR;
corr_ca_avg_noback_NoRM_01 = tbl.corr_ca_avg_noback_NoRM_01;
corr_ca_avg_noback_NoRM_1 = tbl.corr_ca_avg_noback_NoRM_1;
corr_ca_avg_noback_NoRM = tbl.corr_ca_avg_noback_NoRM;
corr_ca_avg_neuropil_noback_NoRM_01 = tbl.corr_ca_avg_neuropil_noback_NoRM_01;
corr_ca_avg_neuropil_noback_NoRM_1 = tbl.corr_ca_avg_neuropil_noback_NoRM_1;
corr_ca_avg_neuropil_noback_NoRM = tbl.corr_ca_avg_neuropil_noback_NoRM;
end