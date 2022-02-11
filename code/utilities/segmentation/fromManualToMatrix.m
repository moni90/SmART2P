function A = fromManualToMatrix(rois_inside,rois_border,pixelsPerRow,...
    linePerFrame, numROIs, movie, framePeriod)
%this function takes the pixels of each ROI and put them in a matrix
%format. The matrix A has N_pixels row and N_ROIs colums, where N_pixels is
%the number of pixels of the FOV and N_ROIs is the number of the detected
%ROIs. For each column, pixels belonging to the corresponding ROI have
%value SNR(px), all other have value 0.
A = zeros(pixelsPerRow*linePerFrame,numROIs);
for i = 1:numROIs
    pixels_in = squeeze(rois_inside(i,:,:));
    pixels_temp = pixels_in;
    pixels_bor = squeeze(rois_border(i,:,:));
%     pixels_temp = [pixels_in, pixels_bor];
    pixels_temp(:,sum(pixels_temp,1)==0)=[];
%     pixels_pos = (pixels_temp(1,:)-1)*pixelsPerRow + pixels_temp(2,:);
    pixels_pos = (pixels_temp(2,:)-1)*linePerFrame + pixels_temp(1,:);
    activity_temp = movie(pixels_pos,:);
    snr_temp = compute_snr(activity_temp,framePeriod);
    A(pixels_pos,i) = snr_temp;
end
A(sum(A,1)==0,:)=[];
end