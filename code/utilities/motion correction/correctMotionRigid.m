function [movie_correct,motion]= correctMotionRigid(movie,n_rows,n_col,framePeriod,save_path,params)
%rigid motion correction from NoRM

if nargin < 6
    bin_width = 50;
    max_shift = 15;
    us_fact = 50;
    template_width = 10;
else
    bin_width = params.bin_width;
    max_shift = params.max_shift;
    us_fact = params.us_fact;
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
options_rigid = NoRMCorreSetParms('d1',FOV(2),'d2',FOV(1),...
    'bin_width',bin_width,'max_shift',max_shift,'us_fac',us_fact); %set parameter for motion correction
[M1,shifts1,template1] = normcorre(movieInit,options_rigid,template);
shifts = squeeze(cat(3,shifts1(:).shifts));
shifts_x = shifts(:,1);
shifts_y = shifts(:,2);
M1(isnan(M1))=0; %replace empty values with 0

if odd %remove added frame
    M1 = M1(:,:,1:end-1);
    shifts_x = shifts_x(1:end-1);
    shifts_y = shifts_y(1:end-1);
end
motion.maxShift = [nanmax(abs(shifts_x)), nanmax(abs(shifts_y))];
motion.shiftX = shifts_x;
motion.shiftY = shifts_y;

%save txt with computed alignment in x and y direction
Tshifts = table(shifts_x, shifts_y);
if ispc
    shiftsName = [save_path,'\MotionCorrection\RigidShifts.txt'];
    savePath2=[save_path '\MotionCorrection\movieCorrectedRigid.tif'];
    if ~exist([save_path, '\MotionCorrection'])
        mkdir([save_path, '\MotionCorrection'])
    end
else
    shiftsName = [save_path,'/MotionCorrection/RigidShifts.txt'];
    savePath2=[save_path '/MotionCorrection/movieCorrectedRigid.tif'];
    if ~exist([save_path, '/MotionCorrection'])
        mkdir([save_path, '/MotionCorrection'])
    end
end
writetable(Tshifts,shiftsName,'Delimiter',' ')

%save as multitiff the corrected TSeries
if exist(savePath2,'file')
    delete(savePath2)
    disp('Movie corrected already exists. It will be overwritten.')
end
saveastiff(uint16(M1),savePath2);
M1 = permute(M1,[3,1,2]);
movie_correct = reshape(M1,n_frames,[]); %reshape corrected TSeries

elapsedTime = toc;
disp(['Maximum displacement along x = ', num2str(nanmax(abs(shifts(1,:)))), ' pixels']);
disp(['Maximum displacement along y = ', num2str(nanmax(abs(shifts(2,:)))), ' pixels']);
disp(['Motion correction done! Elapsed time: ', num2str(elapsedTime)]);


