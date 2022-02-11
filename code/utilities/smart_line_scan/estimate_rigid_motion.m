function [tt,down_rate,ref_box_movie_correct,shifts_x,shifts_y,shifts1, motion_fig] = estimate_rigid_motion(ref_box_movie, framePeriod, down_rate, downsample_flag)

if nargin<4
    downsample_flag = 0;
end

% prompt = {'Enter downsampled rate'};
% dlg_title = ['Frame rate = ' num2str(1/framePeriod)];
% num_lines = 1;
% defaultans = {'0','0'};
% answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
% down_rate = str2double(answer{1});
% if down_rate==0 || down_rate>1/framePeriod
%     down_rate = 1/framePeriod;
% end

SLS_rate = 1/framePeriod;
down_fact = round(SLS_rate/down_rate);
down_period_true = framePeriod*down_fact;
ref_box_movie_avg = movmean(ref_box_movie,down_fact,3);
if downsample_flag
    ref_box_movie_down = ref_box_movie_avg(:,:,1:down_fact:end);
else
    down_rate = SLS_rate;
    down_fact = round(SLS_rate/down_rate);
    down_period_true = framePeriod*down_fact;
    ref_box_movie_down = ref_box_movie_avg;
end
% figure;
% for ii=1:size(ref_box_movie_down,3)
%     imagesc(ref_box_movie_down(:,:,ii)); caxis([nanmin(ref_box_movie_down(:)) nanmax(ref_box_movie_down(:))]);
%     title([num2str(ii) '/' num2str(size(ref_box_movie_down,3))])
%     pause(0.2);
% end
% for j = 1:size(ref_box_movie_down,3)
%     ref_box_movie_down(:,:,j) = ref_box_movie_down(:,:,j)./(max(max(ref_box_movie_down(:,:,j))));
% end
% ref_box_movie_down = ref_box_movie_down*(2^16-1);

%if the numer of frames is odd, add a last frame (to avoid errors later)
if mod(size(ref_box_movie_down,3),2) ~= 0
    odd = 1;
    ref_box_movie_down(:,:,end+1) = ref_box_movie_down(:,:,end);
else
    odd = 0;
end

% template = [];
FOV = [size(ref_box_movie_down,2) size(ref_box_movie_down,1)];
template = mean(ref_box_movie_down(:,:,1:min(size(ref_box_movie_down,3),ceil(10*down_rate))),3); %initialize the template for the alignment to the avg of the frames. Average of first 10 s
options_rigid = NoRMCorreSetParms('d1',FOV(2),'d2',FOV(1),...
    'bin_width',50,'max_shift',15,'us_fac',50); %set parameter for motion correction
[ref_box_movie_correct,shifts1,template1] = normcorre(ref_box_movie_down,options_rigid,template);
shifts = squeeze(cat(3,shifts1(:).shifts));
shifts_x = shifts(:,1);
shifts_y = shifts(:,2);

if odd %remove added frame
    ref_box_movie_correct = ref_box_movie_correct(:,:,1:end-1);
    shifts_x = shifts_x(1:end-1);
    shifts_y = shifts_y(1:end-1);
    shifts1(end)=[];
end

motion_fig = figure;
subplot(2,2,1);
imagesc(nanmean(ref_box_movie,3)); colormap('gray'); colorbar;
title('temporal average BEFORE correction');
subplot(2,2,2);
imagesc(nanmean(ref_box_movie_correct,3)); colormap('gray'); colorbar;
title('temporal average AFTER correction');
subplot(2,2,[3,4]);
tt = (0:1:size(ref_box_movie_correct,3)-1) * down_period_true;
plot(tt,shifts_x,'k');
hold on; plot(tt,shifts_y,'r');
title('Estimated shift'); xlabel('time (s)'); ylabel('shift (px)');
legend('shift x', 'shift y');
