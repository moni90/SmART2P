function data = import_tiff_multitiff(data)

%open_tiff_movie the text file associated to the movie to obtain the info about the
%frame rate.
info = dir([data.path '*.xml']);
files = dir([data.path '*.tif']);
looking_for_word = ~cellfun(@isempty,strfind({files.name},'Source'));
files(looking_for_word) = [];
looking_for_word = ~cellfun(@isempty,strfind({files.name},'MIP'));
files(looking_for_word) = [];
data = extract_info_from_xml_raster(data,info,files);

if ispc %save file name
    ind_aux = strfind(data.path,'\');
else
    ind_aux = strfind(data.path,'/');
end
if ~isempty(ind_aux)
    data.file = data.path(ind_aux(end)+1:end);
end

%import movie and cut initialized structures

movie = import_raster_tiff(data,data.path,0);

if data.duration ~= size(movie,1)
    data.duration = size(movie,1);
    data.activities = data.activities(:,1:data.duration);
    data.activities_original = data.activities_original(:,1:data.duration);
    data.pixelsTimes = data.pixelsTimes(:,1:data.duration);
    data.bg_activity =  data.bg_activity(:,1:data.duration);
    data.activities_deconvolved = zeros(1,data.duration);
    data.frameTimes = data.frameTimes(1:data.duration);
end

data.movie_doc.movie_ruido = movie;
data.movie_doc.num_frames = data.duration;
data.CNimage = correlation_image(data.movie_doc.movie_ruido',...
    8, data.linesPerFrame, data.pixels_per_line);