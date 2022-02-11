function data = sls_deconvolution(movie,data,rois_def,rois_f_raw,linePeriod)

%apply paninski to activity without neuropil and compare local and global
%neuropil subtraction
data.frameTimes_new = [0:1:size(rois_def,2)-1]*linePeriod;
%set to 0 negative values
options.p = 2;
%
C_raw = zeros(size(rois_f_raw));
S_raw = zeros(size(rois_f_raw));
C_glob = zeros(size(rois_def));
S_glob = zeros(size(rois_def));
% figure;
parfor i = 1:size(rois_def,1)
    [C_raw(i,:),~,~,~,~,S_raw(i,:)] = ...
        constrained_foopsi(rois_f_raw(i,:),[],[],[],[],options);
    [C_glob(i,:),~,~,~,~,S_glob(i,:)] = ...
        constrained_foopsi(rois_def(i,:),[],[],[],[],options);
%     hold off; plot(zscore(rois_def(i,:)),'k');
%     hold on; plot(zscore(C_glob(i,:)),'r');
%     title(['ROI ', num2str(i), ' of ', num2str(size(rois_def,1))]);
%     drawnow;
end
% close
[C_df,Df] = extract_DF_F(movie,data.A,C_glob,[],[]);

data.C = C_glob;
data.C_df = C_df;
% data.S = S_glob;
data.Fraw = rois_f_raw;
peaks = zeros(size(data.C_df)); %find C_df peaks
for i = 1:size(peaks,1)
    [pks,locs] = findpeaks(data.C_df(i,:));
    peaks(i,locs) = pks;
end
% peaks(peaks<0.1)=0;
data.peaks = peaks;
