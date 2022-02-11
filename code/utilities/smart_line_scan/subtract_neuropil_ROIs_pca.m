function [rois_f_no_neuropil, score_neuropil, snr_no_neuropil] = subtract_neuropil_ROIs_pca(rois_f,framePeriod)

%compute neuropil activity using PCA on neuropil pixels
[coeff_neuropil,score_neuropil,~,~,explained]  = pca(rois_f', 'NumComponents',1);
rois_f_no_neuropil = rois_f - coeff_neuropil*score_neuropil';
rois_f_no_neuropil = rois_f_no_neuropil.*(rois_f_no_neuropil>=0);

snr_no_neuropil = compute_snr(rois_f_no_neuropil,framePeriod);

% figure;
% subplot(2,1,1); imagesc(rois_f); colorbar;
% subplot(2,1,2); imagesc(rois_f_no_neuropil); colorbar;

