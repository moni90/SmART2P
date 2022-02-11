function [rois_neuro_ring,snr_ring,rois_neuro_pca,neuropil_pca, snr_pca] = subtract_neuropil_local(rois_f, neuropil_f, framePeriod)
%subtract neuropil using activity in a ring or PCA and return processed
%activity and signal quality after processing

rois_neuro_ring = rois_f - 0.7*neuropil_f;
rois_neuro_ring = rois_neuro_ring.*(rois_neuro_ring>=0);
snr_ring = compute_snr(rois_neuro_ring,framePeriod);
[rois_neuro_pca, neuropil_pca, snr_pca] = subtract_neuropil_ROIs_pca(rois_f,framePeriod);