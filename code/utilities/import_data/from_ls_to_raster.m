function raster_movie = from_ls_to_raster(movie,scan_path,n_rows,n_col)

% global data;
% 

movie_noise = movie(movie<=prctile(movie(:),25)); %select values lower than 50th prctile to simulate noise
% scan = data.freehand_scan;
raster_movie = zeros(size(movie,1),n_rows*n_col);
for ind=1:size(movie,1)
    imagen_aux = movie(ind,:);
    aux = mean(movie_noise(:)) + randn(n_rows,n_col)*std(movie_noise(:));%zeros(n_rows,n_col);%
    aux = aux.*(aux>=0);
    oneD_scan_path = twoD_to_oneD(n_rows,round(scan_path)');
    aux(oneD_scan_path) = imagen_aux;
    imagen_aux = aux;
    raster_movie(ind,:) = imagen_aux(:)';
end