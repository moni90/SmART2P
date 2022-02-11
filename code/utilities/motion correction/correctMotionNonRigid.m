function [movie_correct,motion]=correctMotionNonRigid(movie,n_rows,n_col,framePeriod,save_path,params)
%Non rigid motion correction from NoRM

if nargin < 6
    grid_size = [64,64];
    mot_uf = 4;
    bin_width = 50;
    max_shift = 8;
    max_dev = 4;
    us_fac = 20;
    template_width = 10;
else
    grid_size = params.grid_size;
    mot_uf = params.mot_uf;
    bin_width = params.bin_width;
    max_shift = params.max_shift;
    max_dev = params.max_dev;
    us_fac = params.us_fac;
    template_width = params.avg_width;
end

tic
n_frames = size(movie,1);
%reshape TSeries
movieInit = reshape(movie',n_rows,n_col,n_frames);
%if the numer of frames is odd, add a last frame (to avoid errors later)
if mod(n_frames,2) ~= 0
    odd = 1;
    movieInit(:,:,end+1) = movieInit(:,:,end);
else
    odd = 0;
end

FOV = [size(movieInit,2) size(movieInit,1)];
template = mean(movieInit(:,:,1:min(size(movieInit,3),ceil(template_width/framePeriod))),3); %initialize the template for the alignment to the avg of the frames. Average of first 10 s
%correct non rigid
options_nonrigid = NoRMCorreSetParms('d1',FOV(2),'d2',FOV(1),...
    'grid_size',grid_size,...
    'mot_uf',mot_uf,'bin_width',bin_width,'max_shift',max_shift,'max_dev',max_dev,'us_fac',us_fac);

[M1,shifts1,template1] = normcorre_batch(movieInit,options_nonrigid,template);
if any(isnan(M1(:)))
    Y_interp = interp_missing_data(M1);      % interpolate missing data
    mis_data = find(Y_interp);
    M1(mis_data) = Y_interp(mis_data);
end
M1(isnan(M1))=0;
shifts_nr = cat(ndims(shifts1(1).shifts)+1,shifts1(:).shifts);
shifts_nr = reshape(shifts_nr,[],ndims(movieInit)-1,size(movieInit,3));
shifts_x = squeeze(shifts_nr(:,1,:))';
shifts_y = squeeze(shifts_nr(:,2,:))';
if odd
    M1 = M1(:,:,1:end-1);
    shifts_x = shifts_x(1:end-1);
    shifts_y = shifts_y(1:end-1);
end%save txt with computed alignment in x and y direction
motion.maxShift = [nanmax(abs(shifts_x(:))), nanmax(abs(shifts_y(:)))];
motion.shiftX = shifts_x;
motion.shiftY = shifts_y;
 %save txt with computed alignment in x and y direction
TshiftsX = table(shifts_x);
TshiftsY = table(shifts_y);
if ispc
    shiftsNameX = [save_path, '\MotionCorrection\NonRigidShiftsX.txt'];
    shiftsNameY = [save_path, '\MotionCorrection\NonRigidShiftsY.txt'];
    savePath2=[save_path '\MotionCorrection\movieCorrectedNonRigid.tif']; 
    if ~exist([save_path, '\MotionCorrection'])
        mkdir([save_path, '\MotionCorrection'])
    end
else
    shiftsNameX = [save_path, '/MotionCorrection/NonRigidShiftsX.txt'];
    shiftsNameY = [save_path, '/MotionCorrection/NonRigidShiftsY.txt'];
    savePath2=[save_path '/MotionCorrection/movieCorrectedNonRigid.tif'];
    if ~exist([save_path, '/MotionCorrection'])
        mkdir([save_path, '/MotionCorrection'])
    end
end
writetable(TshiftsX,shiftsNameX,'Delimiter',' ');
writetable(TshiftsY,shiftsNameY,'Delimiter',' ');


%save as multitiff the correcte TSeries
if exist(savePath2,'file')
    delete(savePath2)
    disp('Movie corrected already exists. It will be overwritten.')
end
saveastiff(uint16(M1),savePath2);
M1 = permute(M1,[3,1,2]);
movie_correct = reshape(M1,n_frames,[]); %replace original TSeries with corrected one

elapsedTime = toc;
disp(['Maximum displacement along x = ', num2str(nanmax(abs(shifts_x(:)))), ' pixels']);
disp(['Maximum displacement along y = ', num2str(nanmax(abs(shifts_y(:)))), ' pixels']);
disp(['Motion correction done! Elapsed time: ', num2str(elapsedTime)]);


