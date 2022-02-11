function data = import_tiff_sequence(data)

%open_tiff_movie the text file associated to the movie to obtain the info about the
%frame rate.
info = dir([data.path '*.xml']);
data = extract_info_from_xml_raster(data, info);

%define other parameters that depend on the frame period
data.transient_prev = ceil(data.transient_prev_seconds/data.framePeriod);
data.transient_post = ceil(data.transient_post_seconds/data.framePeriod);
data.average_window_choose_roi_current = ceil(data.average_window_choose_roi/data.framePeriod);

%import movie and cut initialized structures
movie = import_raster_tiff(data,[data.path data.file],1);

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