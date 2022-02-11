function [movie_no_backgr,backgr_m] = sls_subtract_background(data,options)
%subtract activity of pixels in segment of the trajectory between two ROIs

if strcmp(options.background,'Yes')
    [movie_temp, backgr_temp] = subtract_neuropil_global(data.movie_doc.movie_ruido', data.neuropil);
    movie_no_backgr = movie_temp;
    backgr_m = backgr_temp;

else
    movie_no_backgr = data.movie_doc.movie_ruido';
    backgr_m = zeros(size(data.movie_doc.movie_ruido',2),1);    

end

