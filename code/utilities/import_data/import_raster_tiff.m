function movie = import_raster_tiff(data,import_TS_path,single_tiff)

if single_tiff
    %look for single tif file
    info = imfinfo(import_TS_path);
    duration = length(info);
    n_rows = info(1).Height;
    n_col = info(1).Width;
    movie = zeros(duration,n_rows*n_col);
    contador = 0;
    
    d_bar = waitbar(0,'Loading data');
    for ind_frame=1:duration
        waitbar(ind_frame/duration,d_bar);
        aux = double(imread(import_TS_path,ind_frame));
        if size(aux,3)>1
            aux = squeeze(aux(:,:,1));
        end
        if isequal(data.mode,'Linescan') || isequal(data.mode,'freehand')
            if size(movie,2)~=size(aux,2)
                aux = aux';
            end
            movie(contador+1:contador+size(aux,1),:) = aux;
            contador = contador + size(aux,1);
        else
            movie(ind_frame,:) = aux(:);
        end
    end
    movie(sum(movie,2)==0,:) = [];
    duration = size(movie,1);
    %check if the duration of the movie has changed and if so redefine some variables
%     if data.duration~=size(movie,1)
%         data.duration = size(movie,1);
%         data.activities = data.activities(:,1:data.duration);
%         data.activities_original = data.activities_original(:,1:data.duration);
%         data.pixelsTimes = data.pixelsTimes(:,1:data.duration);
%         data.bg_activity =  data.bg_activity(:,1:data.duration);
%         data.frameTimes = 1:data.duration;%data.frameTimes(1:data.duration);
%         data.frameTimes = data.frameTimes*data.framePeriod - data.framePeriod;
%     end
%     
%     data.movie_doc.movie_ruido = movie;
%     data.movie_doc.num_frames = data.duration;
%     data.CNimage = correlation_image(data.movie_doc.movie_ruido',...
%         8, data.linesPerFrame, data.pixels_per_line);
    
    close(d_bar);
else
    files = dir([data.path '*.tif']);
    looking_for_word = ~cellfun(@isempty,strfind({files.name},'Source'));
    files(looking_for_word) = [];
    looking_for_word = ~cellfun(@isempty,strfind({files.name},'MIP'));
    files(looking_for_word) = [];
    
%     if ispc %save file name
%         ind_aux = strfind(data.path,'\');
%     else
%         ind_aux = strfind(data.path,'/');
%     end
%     if ~isempty(ind_aux)
%         data.file = data.path(ind_aux(end)+1:end);
%     end
    
    %put all frames in the movie
    d_bar = waitbar(0,'Loading data');
    movie = zeros(data.duration,data.pixels_per_line*data.linesPerFrame);
    contador = 0;
    for ind_frame=1:numel(files)
        waitbar(ind_frame/numel(files),d_bar);
        aux = double(imread([data.path files(ind_frame).name]));
        if size(aux,3)>1
            aux = squeeze(aux(:,:,1));
        end
        if isequal(data.mode,'Linescan') || isequal(data.mode,'freehand')
            if size(movie,2)~=size(aux,2)
                aux = aux';
            end
            movie(contador+1:contador+size(aux,1),:) = aux;
            contador = contador + size(aux,1);
        else
            movie(ind_frame,:) = aux(:);
        end
    end
    movie(sum(movie,2)==0,:) = [];
    duration = size(movie,1);
    %check if the duration of the movie has changed and if so redefine some variables
%     if data.duration ~= size(movie,1)
%         data.duration = size(movie,1);
%         data.activities = data.activities(:,1:data.duration);
%         data.activities_original = data.activities_original(:,1:data.duration);
%         data.pixelsTimes = data.pixelsTimes(:,1:data.duration);
%         data.bg_activity =  data.bg_activity(:,1:data.duration);
%         data.activities_deconvolved = zeros(1,data.duration);
%         data.frameTimes = data.frameTimes(1:data.duration);
%     end
%     
%     data.movie_doc.movie_ruido = movie;
%     data.movie_doc.num_frames = data.duration;
%     data.CNimage = correlation_image(data.movie_doc.movie_ruido',...
%         8, data.linesPerFrame, data.pixels_per_line);
    
    close(d_bar);
end
