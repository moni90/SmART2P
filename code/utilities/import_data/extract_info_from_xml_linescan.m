function extract_info_from_xml_linescan(info,files)

global data;

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

%extract info from the xml file
if ispc
    file_name = [info(1).folder '\' info(1).name];
else
    file_name = [info(1).folder '/' info(1).name];
end
data = extract_metadata_sls(data,file_name,files);
% register_ROIs_ls()


% %extract info from the xml file
% if ispc
%     [fileID,~] = fopen([info(1).folder '\' info(1).name]);
% else
%     [fileID,~] = fopen([info(1).folder '/' info(1).name]);
% end
% d = textscan(fileID,'%s','Delimiter','"');
% fclose(fileID);
% looking_for_word = find(~cellfun(@isempty,strfind(d{1},'type')));
% data.mode = d{1}{looking_for_word(1)+1};
% looking_for_word = find(~cellfun(@isempty,strfind(d{1},'description')));
% if ~isequal(data.mode,'freehand') && ~isequal(data.mode,'Linescan')
%     error('This is not a line scan acquisition!')
% end
% data.scanningType = d{1}{looking_for_word(1)+1};
% looking_for_word = find(~cellfun(@isempty,strfind(d{1},'micronsPerPixel_XAxis')));
% if ~isempty(looking_for_word)
%     data.micronsPerPixel_XAxis = str2double(d{1}{looking_for_word(1)+4});
%     looking_for_word = find(~cellfun(@isempty,strfind(d{1},'micronsPerPixel_YAxis')));
%     data.micronsPerPixel_YAxis = str2double(d{1}{looking_for_word(1)+4});
% else
%     looking_for_word = find(~cellfun(@isempty,strfind(d{1},'micronsPerPixel')));
%     if ~isempty(looking_for_word)
%         data.micronsPerPixel_XAxis = str2double(d{1}{looking_for_word(1)+5});
%         data.micronsPerPixel_YAxis = str2double(d{1}{looking_for_word(1)+10});
%     end
% end
% %read the file again with a different delimiter
% if ispc
%     [fileID,~] = fopen([info(1).folder '\' info(1).name]);
% else
%     [fileID,~] = fopen([info(1).folder '/' info(1).name]);
% end
% d = textscan(fileID,'%s','Delimiter',' ');
% fclose(fileID);
% xml_info = d{1};
% 
% %look for reference image
% if ispc
%     reference_image = dir([data.path 'References\*Reference*.tif']);
% else
%     reference_image = dir([data.path 'References/*Reference*.tif']);
% end
% if ~isempty(reference_image)
%     if ispc
%         data.reference_image = double(imread([data.path '\References\' reference_image(1).name]));
%     else
%         data.reference_image = double(imread([data.path '/References/' reference_image(1).name]));
%     end
%     if size(data.reference_image,3)>1
%         data.reference_image = squeeze(data.reference_image(:,:,1));
%     end
% end
% %get the index of when the information about the lineScan starts
% smart_line_scan_info_start = find(~cellfun(@isempty,strfind(xml_info,'PVLinescanDefinition')),1,'last');
% %get some data
% data.scanlinePeriod = find_values(xml_info,'scanLinePeriod',smart_line_scan_info_start);
% data.dwellTime = find_values(xml_info,'dwellTime',0)/1000000;
% data.pixels_per_line = find_values(xml_info,'pixelsPerLine',smart_line_scan_info_start);
% data.linesPerFrame = find_values(xml_info,'linesPerFrame',smart_line_scan_info_start);
% data.framePeriod = data.scanlinePeriod;
% data.frameTimes = 1:numel(files)*data.linesPerFrame;
% data.frameTimes = data.frameTimes*data.framePeriod-data.framePeriod;
% data.duration = numel(files)*data.linesPerFrame;
% data = reset_data(data);
% data.linesPerFrame = 1;
% %is it a freehand lineScan?
% looking_for_word = find(~cellfun(@isempty,strfind(xml_info,'freeHand')), 1);
% if ~isempty(looking_for_word)
%     data.mode = 'freehand';
%     if ispc
%         [fileID,~] = fopen([info(1).folder, '\', info(1).name]);
%     else
%         [fileID,~] = fopen([info(1).folder, '/', info(1).name]);
%     end
%     d = textscan(fileID,'%s','Delimiter','\n');
%     d = d{1};
%     fclose(fileID);
%     scan_path = zeros(2,numel(d));
%     counter = 0;
%     %get laser coordinates and measure path length
%     for ind=1:numel(d)
%         line = d(ind);
%         line = line{1};
%         index =  strfind(line,'<Freehand x=');
%         if ~isempty(index)
%             counter = counter + 1;
%             index2 =  strfind(line,'y=');
%             scan_path(1,counter) = str2double(line(index+13:index2-3));
%             scan_path(2,counter) = str2double(line(index2+3:end-4));
%             if counter>1
%                 if abs(scan_path(2,counter)-scan_path(2,counter-1))>10 || abs(scan_path(1,counter)-scan_path(1,counter-1))>10
%                     keyboard
%                 end
%             end
%         end
%     end
%     scan_path = scan_path(:,1:counter);
%     distancias = (sqrt(diff(scan_path(1,:)).^2 + diff(scan_path(2,:)).^2));
%     distancia = sum(distancias);
%     data.freehand_scan = scan_path(2:-1:1,:);
%     
%     register_ROIs_ls()
%     
% end
