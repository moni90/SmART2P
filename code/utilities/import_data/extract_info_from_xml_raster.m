function data = extract_info_from_xml_raster(data, info, files)

if nargin == 2
    files = [];
end

%import metadata or select manually?
choice = questdlg('How would you like to set acquisition parameters?', ...
    'Imaging parameters', ...
    'Import from .xml','Read from TIFF','Manual','Manual');
switch choice
    case 'Manual'
        data = manual_acquisition_info(data,files);
    case 'Import from .xml'
        try %if automatic import returns error, insert manually
            if isempty(info) %look for xml file with metadata
                xml_folder = uigetdir(data.path,'Select folder with .xml file');
                if ispc
                    info = dir([xml_folder '\*.xml']);
                else
                    info = dir([xml_folder '/*.xml']);
                end
            end
            info_names = {info.name};
            looking_for_word = ~cellfun(@isempty,strfind(info_names,'surround'));
            info(looking_for_word) = [];
            
            if ispc
                file_name = [info(1).folder '\' info(1).name];
            else
                file_name = [info(1).folder '/' info(1).name];
            end
            data = extract_metadata_raster(data,file_name,files);
    
        catch ME
            if strcmp(ME.message,'This is not a raster acquisition!')==1
                error('Acquisition stopped. Not a raster');
            else
                manual_acquisition_info(files);
            end
        end
    case 'Read from TIFF'

        data.scanningType = 'TSeries Timed Element';
        data.mode = 'TSeries Timed Element';
        info = imfinfo(fullfile(data.path,data.file));
        data.pixels_per_line = info(1).Width;
        data.linesPerFrame = info(1).Height;
        data.duration = length(info);
        data.frameTimes = 1:data.duration;%*data.linesPerFrame;
        switch info(1).ResolutionUnit
            case 'Inch'
                data.micronsPerPixel_XAxis = 2.54*1e+4/info(1).XResolution; %um per pixel
                data.micronsPerPixel_YAxis = 2.54*1e+4/info(1).YResolution;
            case 'Centimeter'
                data.micronsPerPixel_XAxis = 1e+4/info(1).XResolution; %um per pixel
                data.micronsPerPixel_YAxis = 1e+4/info(1).YResolution;
        end
        metadata_string = info(1).Software;
        string_id = 'SI.hRoiManager.linePeriod = ';
        string_length = length(string_id);
        start_scanLinePeriod = strfind(metadata_string,string_id);
        metadata_splitted = splitlines(metadata_string(start_scanLinePeriod:end));
        data.scanlinePeriod = str2double(metadata_splitted{1}(string_length:end));
        string_id = 'SI.hScan2D.scanPixelTimeMean = ';
        string_length = length(string_id);
        start_dwellTime = strfind(metadata_string,string_id);
        metadata_splitted = splitlines(metadata_string(start_dwellTime:end));
        data.dwellTime = str2double(metadata_splitted{1}(string_length:end));
        string_id = 'SI.hRoiManager.scanFramePeriod = ';
        string_length = length(string_id);
        start_framePeriod = strfind(metadata_string,string_id);
        metadata_splitted = splitlines(metadata_string(start_framePeriod:end));
        data.framePeriod = str2double(metadata_splitted{1}(string_length:end));
        data.frameTimes = data.frameTimes*data.framePeriod-data.framePeriod;
        data = reset_data(data);
end
