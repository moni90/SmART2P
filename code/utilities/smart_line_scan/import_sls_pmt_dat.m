function data = import_sls_pmt_dat(data,fluo_fileName, frame_num, n_channels)

fid = fopen(fluo_fileName);
pmtData = fread(fid,inf,'int16');
fclose(fid);
N = data.duration*n_channels*data.pixels_per_line;
pmtData(end+1:N,:) = nan;
pmtData = permute(reshape(pmtData,n_channels,data.pixels_per_line,[]),[3 2 1]);
movie = squeeze(pmtData);

if size(movie,1)~=data.duration
    data.duration = size(movie,1);
    data.activities = zeros(1,data.duration);
    data.activities_original = zeros(1,data.duration);
    data.pixelsTimes = zeros(1,data.duration);
    data.bg_activity =  zeros(1,data.duration);
    data.activities_deconvolved = zeros(1,data.duration);
    data.frameTimes = data.frameTimes(1:data.duration);
end

%save the movie
data.movie_doc.movie_ruido = movie;
data.movie_doc.num_frames = data.duration;
