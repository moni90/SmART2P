function data = import_sls_tiff(data,frame_num)

files = dir([data.path '*.tif']);
looking_for_word = ~cellfun(@isempty,strfind({files.name},'Source'));
files(looking_for_word) = [];
looking_for_word = ~cellfun(@isempty,strfind({files.name},'MIP'));
files(looking_for_word) = [];

if ispc %save file name
    ind_aux = strfind(data.path,'\');
else
    ind_aux = strfind(data.path,'/');
end
if ~isempty(ind_aux)
    data.file = data.path(ind_aux(end)+1:end);
end

%get lineScan movie
d_bar = waitbar(0,'Loading data');
movie = zeros(data.duration,data.pixels_per_line*data.linesPerFrame);
contador = 0;
for ind_frame=1:nanmin(numel(files),frame_num)
    waitbar(ind_frame/nanmin(numel(files),frame_num),d_bar);
    aux = double(imread([data.path files(ind_frame).name]));
    if size(aux,3)>1
        aux = squeeze(aux(:,:,1));
    end
    if size(movie,2)~=size(aux,2)
        aux = aux';
    end
    movie(contador+1:contador+size(aux,1),:) = aux;
    contador = contador + size(aux,1);
end
%remove rows with no activity (probably because the there are less frames
%than initialy expected)
movie(sum(movie,2)==0,:) = [];
%if we remove some frames, we need to update the duration and some fields
%in the data struct
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

close(d_bar);