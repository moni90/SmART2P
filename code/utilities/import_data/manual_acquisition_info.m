function data = manual_acquisition_info(data, files)
%insert manually info necessary for data processing

if nargin == 1
    files = [];
end

str = {'TSeries Timed Element'; 'Linescan'};
[s,~] = listdlg('PromptString','Select acquisition type:',...
                'SelectionMode','single',...
                'ListString',str);
data.mode = str{s};
data.scanningType = data.mode;

prompt = {'Enter micron per px (X axis):','Enter micron per px (Y axis):'};
dlg_title = 'Input';
num_lines = 1;
defaultans = {'1','1'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
data.micronsPerPixel_XAxis = str2double(answer{1});
data.micronsPerPixel_YAxis = str2double(answer{2});

if isequal(data.mode,'Linescan')
    error('Cannot open linescan without an xml')
else
    prompt = {'Scanline period (s):','Dwell time (us):','Frame period (s):'};
    dlg_title = 'Input';
    num_lines = 1;
    defaultans = {'1','1','1'};
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
    data.scanlinePeriod = str2double(answer{1});
    data.dwellTime = str2double(answer{2})/1000000;
    data.framePeriod = str2double(answer{3});
    
    
    if isempty(files)
        info = imfinfo([data.path data.file]);
        data.duration = numel(info);     
    else
        info = imfinfo([data.path files(1).name]);
        data.duration = numel(files);
    end
    data.pixels_per_line = info(1).Width;
    data.linesPerFrame = info(1).Height;
    data.frameTimes = 1:data.duration;%*data.linesPerFrame;
    data.frameTimes = data.frameTimes*data.framePeriod-data.framePeriod;
end

if ispc
    reference_image = dir([data.path 'References\*Reference*.tif']);
else
    reference_image = dir([data.path 'References/*Reference*.tif']);    
end
if ~isempty(reference_image)
    if ispc
        data.reference_image = double(imread([data.path '\References\' reference_image(1).name]));
    else
        data.reference_image = double(imread([data.path '/References/' reference_image(1).name]));
    end
    if size(data.reference_image,3)>1
        data.reference_image = squeeze(data.reference_image(:,:,1));
    end
end

data = reset_data(data);