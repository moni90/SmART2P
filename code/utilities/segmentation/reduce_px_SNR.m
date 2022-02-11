function A_SNR = reduce_px_SNR(A,movie,framePeriod)

A_SNR = zeros(size(A));
for id_ROI = 1:size(A,2)
    id_px_temp = find(A(:,id_ROI));
    activity_temp = movie(id_px_temp,:);
    snr_temp = compute_snr(activity_temp,framePeriod);
    [snr_sort, id_px_sort] = sort(snr_temp,'descend');
    snr_px = zeros(1,length(id_px_temp));
    for n_px = 1:length(id_px_temp)
        activity_temp = nanmean(movie(id_px_sort(1:n_px),:),1);
        snr_px(n_px) = compute_snr(activity_temp,framePeriod);
    end
    [snr_max,id_max] = max(movmean(snr_px,min(5,length(snr_sort))));
    A_SNR(id_px_temp(id_px_sort(1:id_max)),id_ROI) = A(id_px_temp(id_px_sort(1:id_max)),id_ROI);
end
