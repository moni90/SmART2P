function data = extract_metadata_raster(data,file_name,files)

if nargin <3 || isempty(files)
    if ~isfield(data,'file') || isempty(data.file)
        files = dir([data.path '*.tif']);
        looking_for_word = ~cellfun(@isempty,strfind({files.name},'Source'));
        files(looking_for_word) = [];
        looking_for_word = ~cellfun(@isempty,strfind({files.name},'MIP'));
        files(looking_for_word) = [];
    else
        files = [];
    end
end
[fileID,~] = fopen(file_name);

d = textscan(fileID,'%s','Delimiter','"');
fclose(fileID);

looking_for_word = find(~cellfun(@isempty,strfind(d{1},'type')));
data.mode = d{1}{looking_for_word(1)+1};
if isequal(data.mode,'Linescan') || isequal(data.mode,'freehand')
    error('This is not a raster acquisition!');
end
looking_for_word = find(~cellfun(@isempty,strfind(d{1},'description')));
data.scanningType = d{1}{looking_for_word(1)+1};
looking_for_word = find(~cellfun(@isempty,strfind(d{1},'micronsPerPixel_XAxis')));
if ~isempty(looking_for_word)
    data.micronsPerPixel_XAxis = str2double(d{1}{looking_for_word(1)+4});
    looking_for_word = find(~cellfun(@isempty,strfind(d{1},'micronsPerPixel_YAxis')));
    data.micronsPerPixel_YAxis = str2double(d{1}{looking_for_word(1)+4});
else
    looking_for_word = find(~cellfun(@isempty,strfind(d{1},'micronsPerPixel')));
    if ~isempty(looking_for_word)
        data.micronsPerPixel_XAxis = str2double(d{1}{looking_for_word(1)+5});
        data.micronsPerPixel_YAxis = str2double(d{1}{looking_for_word(1)+10});
    end
end

%read the file again with a different delimiter
[fileID,~] = fopen(file_name);

d = textscan(fileID,'%s','Delimiter',' ');
fclose(fileID);
xml_info = d{1};

try
    data.scanlinePeriod = find_values(xml_info,'scanLinePeriod',0);
catch
    data.scanlinePeriod = find_values(xml_info,'scanlinePeriod',0);
end
data.dwellTime = find_values(xml_info,'dwellTime',0)/1000000;
data.pixels_per_line = find_values(xml_info,'pixelsPerLine',0);
data.linesPerFrame = find_values(xml_info,'linesPerFrame',0);
data.framePeriod = find_values(xml_info,'framePeriod',0);

if isempty(files)
    looking_for_word = find(~cellfun(@isempty,strfind(d{1},'relativeTime')));
    data.duration = numel(looking_for_word);
    data.frameTimes = zeros(1,data.duration);
    for ind=1:numel(looking_for_word)
        data.frameTimes(ind) = str2double(d{1}{looking_for_word(ind)}(15:end-1));
    end
    info = imfinfo([data.path data.file]);
    if numel(info)~=data.duration
        data.duration = numel(info);
        data.frameTimes = 1:data.duration;%data.frameTimes(1:data.duration);
        data.frameTimes = data.frameTimes*data.framePeriod - data.framePeriod;
    end
else
    data.frameTimes = 1:numel(files);%*data.linesPerFrame;
    data.frameTimes = data.frameTimes*data.framePeriod-data.framePeriod;
    data.duration = numel(files);%*data.linesPerFrame;
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