function [data, n_channels] = extract_info_from_txt_linescan(data,metaData_fileName)

data.mode = 'Linescan';

%find number of channels recorded
expr = '[^\n]*SI.hChannels.channelSave[^\n]*';
n_channels = extract_field_metadata(metaData_fileName, expr);

%find linescan acquisition period
expr = '[^\n]*SI.hRoiManager.linePeriod[^\n]*';
line_period = extract_field_metadata(metaData_fileName, expr);
data.scanlinePeriod = line_period;
data.framePeriod = data.scanlinePeriod;

%find number of lines
expr = '[^\n]*SI.hStackManager.framesPerSlice[^\n]*';
num_lines = extract_field_metadata(metaData_fileName, expr);
data.linesPerFrame = num_lines;
data.duration = num_lines;%*data.linesPerFrame;
data.frameTimes = 1:num_lines;%*data.linesPerFrame;
data.frameTimes = data.frameTimes*data.framePeriod-data.framePeriod;


%
data.micronsPerPixel_XAxis = 1;
data.micronsPerPixel_YAxis = 1;
expr = '[^\n]*SI.hScan2D.scanPixelTimeMean[^\n]*';
dwellTime = extract_field_metadata(metaData_fileName, expr);
data.dwellTime = dwellTime;



% %find FOV size
% expr = '[^\n]*SI.hRoiManager.linesPerFrame[^\n]*';
% lines_per_frame = extract_field_metadata(metaData_fileName, expr);
% data.linesPerFrame = lines_per_frame;
% expr = '[^\n]*SI.hRoiManager.pixelsPerLine[^\n]*';
% px_per_lines = extract_field_metadata(metaData_fileName, expr);
% data.pixels_per_line = px_per_lines;

data.linesPerFrame = 1;
expr = '[^\n]*SI.hScan2D.lineScanSamplesPerFrame[^\n]*';
length_trajectory = extract_field_metadata(metaData_fileName, expr);
data.pixels_per_line = length_trajectory;

data = reset_data(data);
data.linesPerFrame = 1;
% % data.scanlinePeriod = find_values(xml_info,'scanLinePeriod',smart_line_scan_info_start);
% data.dwellTime = find_values(xml_info,'dwellTime',0)/1000000;
% % data.pixels_per_line = find_values(xml_info,'pixelsPerLine',smart_line_scan_info_start);
% % data.linesPerFrame = find_values(xml_info,'linesPerFrame',smart_line_scan_info_start);
% % data.framePeriod = data.scanlinePeriod;
% % data.frameTimes = 1:numel(files)*data.linesPerFrame;
% % data.frameTimes = data.frameTimes*data.framePeriod-data.framePeriod;
% % data.duration = numel(files)*data.linesPerFrame;
% data = reset_data(data);

