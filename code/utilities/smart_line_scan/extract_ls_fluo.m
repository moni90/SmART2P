function [rois_f,neuropil,snr] = extract_ls_fluo(movie, rois_px, ring_px, surrounding_px,framePeriod)

%extract mean fluorescence of each ROI + ring + surround
rois_f = zeros(size(rois_px,2),size(movie,2));
neuropil= zeros(size(rois_px,2),size(movie,2));
snr = zeros(size(rois_px,2),1);
for ind_roi = 1:size(rois_f,1)
    %extract ROI trace from movie without background activity
    pixels_temp_roi = movie(find(rois_px(:,ind_roi)),:);
    pixels_temp_surround = movie(find(surrounding_px(:,ind_roi)),:);
    rois_f(ind_roi,:) = nanmean(pixels_temp_roi,1);
    if ~isempty(pixels_temp_surround)
        neuropil(ind_roi,:) = nanmean(pixels_temp_surround,1);
    end
    fluo = rois_f(ind_roi,:);
    lower_trace_thr = prctile(fluo,25);
    lower_trace_activity = fluo(fluo<=lower_trace_thr);
    lower_standard_deviation = std(lower_trace_activity);
    lower_standard_deviation(lower_standard_deviation==0)=Inf;
    snr(ind_roi) = (max(movmean(fluo,max(1,round(1/framePeriod))))-mean(lower_trace_activity))./lower_standard_deviation;
end
