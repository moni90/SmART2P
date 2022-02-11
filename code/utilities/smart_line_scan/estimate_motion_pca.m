function [score_all, fit_all, ind_cut, pca_motion_fig] = estimate_motion_pca(movie, frameTime, framePeriod)

%movie time*px
[coeff_all,score_all,~,~,explained]  = pca(movie, 'NumComponents',1);
score_all = score_all + abs(min(score_all));
options.p = 2;
[fit_all,~,~,~,~,~] = ...
    constrained_foopsi(score_all,[],[],[],[],options); %fit 1st PC of ROIs and
n_corr = round(10/framePeriod); %sliding window of 10 s
correl = zeros(length(score_all),1);
for ii = 1:length(score_all)-n_corr
    correl(ii) = corr(score_all(ii:min(ii+n_corr,length(score_all))),fit_all(ii:min(ii+n_corr,length(score_all))));
end
correl(ii:end) = correl(ii-1);
% figure; plot(correl);

% ind_cut = find(correl<=0.3,1,'first');
correl_below = correl<=0.3;
below_cross = find(diff(correl_below)==1);
below_cross(below_cross<5/framePeriod) = [];
if ~isempty(below_cross)
    ind_cut = below_cross(1)+1;
else
    ind_cut = [];
end
pca_motion_fig = figure;
subplot(4,1,[1 2]);
imagesc(frameTime,[],movie'); colorbar;
xlabel('time (s)'); ylabel('pixels');
subplot(4,1,3);
plot(frameTime,score_all,'k','LineWidth',1);
hold on; plot(frameTime,fit_all,'r','LineWidth',2);
xlabel('time (s)'); 
title(['var explained = ' num2str(explained(1))]);
legend('First PC', 'AR(2) fit')
subplot(4,1,4);
plot(frameTime,correl,'r','LineWidth',2);
if ~isempty(ind_cut)
    hold on; plot(frameTime(ind_cut),correl(ind_cut),'r*');
end
hold on; plot(frameTime, 0.3*ones(length(frameTime),1),'k--');
xlabel('time (s)'); 
