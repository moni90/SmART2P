function [rois_f, rois_f_correct, neuropil0, neuropil_correct, snr0, snr_correct,shift_x_roi,shift_y_roi] = reassign_px_snr(movie, rois_px, ring_px, surrounding_px, trajectory, framePeriod)

%extract mean fluorescence of each ROI + ring + surround
[rois_f,neuropil0,snr0] = extract_ls_fluo(movie, rois_px, ring_px, surrounding_px,framePeriod);
rois_f_correct = zeros(size(rois_px,2),size(movie,2));
snr_correct = zeros(size(rois_px,2),1);
neuropil_correct = zeros(size(rois_px,2),size(movie,2));
shift_x_roi = zeros(size(rois_px,2),size(movie,2));
shift_y_roi = zeros(size(rois_px,2),size(movie,2));
parfor ind_roi = 1:size(rois_f,1)
    %extract ROI trace from movie without background activity
    pixels_temp_no_neuropil = movie(find(rois_px(:,ind_roi)+surrounding_px(:,ind_roi)+ring_px(:,ind_roi)),:);
    x_0 = nanmean(trajectory(2,find(rois_px(:,ind_roi))));
    y_0 = nanmean(trajectory(1,find(rois_px(:,ind_roi))));
    x_all = trajectory(2,find(rois_px(:,ind_roi)+surrounding_px(:,ind_roi)+ring_px(:,ind_roi)));
    y_all = trajectory(1,find(rois_px(:,ind_roi)+surrounding_px(:,ind_roi)+ring_px(:,ind_roi)));
    %select pixels
    numPixels = length(find(rois_px(:,ind_roi)));
    [chosen_px, fluo_temp, neuropil_temp, snr_temp] = select_px_SNR(pixels_temp_no_neuropil, numPixels, framePeriod);
    x_t = nanmean(chosen_px.*repmat(x_all(:),1,size(chosen_px,2)),1);
    y_t = nanmean(chosen_px.*repmat(y_all(:),1,size(chosen_px,2)),1);
    
    snr_correct(ind_roi) = snr_temp;
    rois_f_correct(ind_roi,:) = fluo_temp; 
    neuropil_correct(ind_roi,:) = neuropil_temp;
    shift_x_roi(ind_roi,:) = x_t-x_0;
    shift_y_roi(ind_roi,:) = y_t-y_0;
end


