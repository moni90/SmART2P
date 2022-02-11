function [] = import_linescan_data(frame_num)

global data;

%get file
if isfield(data,'path')
    PathName = uigetdir(data.path,'Select Movie folder');
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

%get all files
files = dir([data.path '*.tif']);
looking_for_word = ~cellfun(@isempty,strfind({files.name},'Source'));
files(looking_for_word) = [];
looking_for_word = ~cellfun(@isempty,strfind({files.name},'MIP'));
files(looking_for_word) = [];

%this is so the code works in ubuntu and windows
if ispc
    ind_aux = strfind(PathName,'\');
else
    ind_aux = strfind(PathName,'/');
end
data.file = PathName(ind_aux(end)+1:end);


%open_tiff_movie the text file associated to the movie to obtain the info about the frame rate.
info = dir([data.path '*.xml']);
extract_info_from_xml_linescan(info,files)

%define other parameters that depend on the frame period
data.transient_prev = ceil(data.transient_prev_seconds/data.framePeriod);
data.transient_post = ceil(data.transient_post_seconds/data.framePeriod);
data.average_window_choose_roi_current = ceil(data.average_window_choose_roi/data.framePeriod);

data = import_sls_tiff(data,frame_num);