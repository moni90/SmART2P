function [time_down, movie_down, rois_f0, rois_f_correct, neuropil0, neuropil_correct, snr0, snr_correct,shifts_x,shifts_y, ref_box_fig, motion_fig] = reassign_px_NoRM_keep_rate(movie_no_backgr, rois_px, ring_px, surrounding_px, down_rate, n_rows, n_col, scan_path, framePeriod)

[ref_box_movie, ref_box_fig] = find_ref_box(movie_no_backgr, scan_path);
SLS_rate = 1/framePeriod;
down_fact = round(SLS_rate/down_rate);
% down_period_true = framePeriod*down_fact;
ref_box_movie = movmean(ref_box_movie,down_fact,3);
[time_down,down_rate,ref_box_movie_correct,shifts_x,shifts_y,shifts_all, motion_fig] = estimate_rigid_motion(ref_box_movie, framePeriod, SLS_rate);

rois_f0 = []; rois_f_correct = []; neuropil0 = [];
neuropil_correct = []; snr0 = []; snr_correct = [];

%downsample the movie
SLS_rate = 1/framePeriod;
down_fact = round(SLS_rate/down_rate);
down_period_true = framePeriod*down_fact;
movie_avg = movmean(movie_no_backgr,down_fact,1);
movie_down = movie_avg;

max_size = 10000*10000; %max size array
if size(movie_down,1)*size(movie_down,2) <= max_size
    raster_movie = from_ls_to_raster(movie_down,scan_path,n_rows,n_col);
    raster_movie = reshape(raster_movie', n_rows, n_col,[]);
    
    options_rigid = NoRMCorreSetParms('d1',n_rows,'d2',n_col,...
        'bin_width',50,'max_shift',15,'us_fac',50); %set parameter for motion correction
    raster_correct = apply_shifts(raster_movie,shifts_all,options_rigid);
    raster_correct = reshape(raster_correct,[],size(raster_correct,3));
    sls_correct = raster_correct(twoD_to_oneD(n_rows,round(scan_path)'),:);
    [rois_f_correct,neuropil_correct,snr_correct] = extract_ls_fluo(sls_correct, rois_px, ring_px, surrounding_px,down_period_true);
    [rois_f0,neuropil0,snr0] = extract_ls_fluo(movie_down', rois_px, ring_px, surrounding_px,down_period_true);
else
    n_lines = floor(max_size/size(movie_down,2));
    n_split = ceil(size(movie_down,1)/n_lines);
    sls_correct = [];
    for j = 1:n_split
        raster_movie = from_ls_to_raster(movie_down((j-1)*n_lines +1 : min(j*n_lines,size(movie_down,1)) ,:),scan_path,n_rows,n_col);
        raster_movie = reshape(raster_movie', n_rows, n_col,[]);
        options_rigid = NoRMCorreSetParms('d1',n_rows,'d2',n_col,...
            'bin_width',50,'max_shift',15,'us_fac',50); %set parameter for motion correction
        raster_correct = apply_shifts(raster_movie,shifts_all((j-1)*n_lines +1 : min(j*n_lines,size(movie_down,1))),options_rigid);
        raster_correct = reshape(raster_correct,[],size(raster_correct,3));
        sls_correct_temp = raster_correct(twoD_to_oneD(n_rows,round(scan_path)'),:);
        sls_correct = [sls_correct sls_correct_temp];

        
    end
    [rois_f_correct,neuropil_correct,snr_correct] = extract_ls_fluo(sls_correct, rois_px, ring_px, surrounding_px,down_period_true);
        [rois_f0,neuropil0,snr0] = extract_ls_fluo(movie_down', rois_px, ring_px, surrounding_px,down_period_true);
    
end

