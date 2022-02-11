function snr = compute_snr(fluo,framePeriod)
%fluo = n_rois * time

lower_trace_thr = prctile(fluo,25,2);
lower_trace_activity = fluo;
lower_trace_activity(lower_trace_activity>lower_trace_thr)=NaN;
lower_standard_deviation = nanstd(lower_trace_activity,[],2);
lower_standard_deviation(lower_standard_deviation==0)=Inf;
snr = (max(movmean(fluo,max(1,round(1/framePeriod)),2),[],2)-nanmean(lower_trace_activity,2))./lower_standard_deviation;
end
