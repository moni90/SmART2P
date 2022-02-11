function [movie_no_neuropil, neuropil_m] = subtract_neuropil_global(movie, neuropil_px)

%compute neuropil activity using PCA on neuropil pixels
[coeff_neuropil,score_neuropil,~,~,explained]  = pca(movie(find( sum(neuropil_px,2)>0 ),:)', 'NumComponents',1);
neuropil_m = nanmean(score_neuropil * coeff_neuropil',2); %mean of first component representation
movie_no_neuropil =  movie-0.7*neuropil_m';
movie_no_neuropil = movie_no_neuropil.*(movie_no_neuropil>=0);

% figure;
% subplot(2,1,1); imagesc(movie); colorbar;
% title('Raw linescan')
% subplot(2,1,2); imagesc(movie_no_neuropil); colorbar;
% title('Background subtracted linescan')
