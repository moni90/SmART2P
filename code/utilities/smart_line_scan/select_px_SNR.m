function [chosen_px, fluo, neuropil, snr_def] = select_px_SNR(all_pixels, n_pixels, framePeriod)
%select n_px with highest SNR
n_sliding_win = min(round(10/framePeriod),size(all_pixels,2)-1);
chosen_px = NaN*ones(size(all_pixels));
for i_t = 1:max(1,size(all_pixels,2)-n_sliding_win)
    all_px_temp = all_pixels(:,i_t:i_t+n_sliding_win)';
    [~,event] = max(movmean(nanmean(all_px_temp,2),max(1,round(1/framePeriod))));

    lower_trace_th_aux = prctile(all_px_temp,25,1);
    lower_trace_activity = all_px_temp(all_px_temp<=repmat(lower_trace_th_aux,size(all_px_temp,1),1));
    lower_standard_deviation = std(lower_trace_activity,[],1);
    lower_standard_deviation(lower_standard_deviation==0)=Inf;
    snr_all = (all_px_temp(event,:)-mean(lower_trace_activity,1))./lower_standard_deviation;

    [~,index_fl] = sort(snr_all,'descend');

    chosen_px(index_fl(1:n_pixels), i_t) = 1;
end
chosen_px(:,i_t+1:end) = repmat(chosen_px(:,i_t),1,n_sliding_win);
fluo = nanmean(all_pixels.*chosen_px,1);
neuropil = nanmean(all_pixels.*(isnan(chosen_px)),1);
lower_trace_thr = prctile(fluo,25);
lower_trace_activity = fluo(fluo<=lower_trace_thr);
lower_standard_deviation = std(lower_trace_activity);
lower_standard_deviation(lower_standard_deviation==0)=Inf;
snr_def = (max(movmean(fluo,max(1,round(1/framePeriod))))-mean(lower_trace_activity))./lower_standard_deviation;

neuropil(isnan(neuropil)) = 0;
end