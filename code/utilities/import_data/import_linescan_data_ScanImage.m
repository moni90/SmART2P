function [data, success_import] = import_linescan_data_ScanImage(data, frame_num)

% global data;

%get file
if isfield(data,'path')
    PathName = uigetdir(data.path,'Select LineScan folder');
else
    PathName = uigetdir('Select Movie');
end
if PathName==0
    return;
end
if ispc
    data.path = [PathName '\'];
else
    data.path = [PathName '/'];
end

%get name of metadata and fluo files
% metadata_filename = dir([data.path '*.txt']);
fluo_filename = dir([data.path '*.pmt.dat']);
fluo_filename = fluo_filename.name(1:end-8);

%this is so the code works in ubuntu and windows
if ispc
    ind_aux = strfind(PathName,'\');
else
    ind_aux = strfind(PathName,'/');
end
data.file = PathName(ind_aux(end)+1:end);

[header, data, success_import] = readLineScanDataFiles(data, fluo_filename, frame_num);

% %import metadata from txt.
% [data, n_channels] = extract_info_from_txt_linescan(data,fullfile(metadata_filename.folder,metadata_filename.name));

%define other parameters that depend on the frame period
data.transient_prev = ceil(data.transient_prev_seconds/data.framePeriod);
data.transient_post = ceil(data.transient_post_seconds/data.framePeriod);
data.average_window_choose_roi_current = ceil(data.average_window_choose_roi/data.framePeriod);

% data = import_sls_pmt_dat(data,fullfile(fluo_filename.folder,fluo_filename.name),frame_num, n_channels);