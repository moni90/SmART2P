function choose_threshold(~,evnt)
%scroll mouse wheel to select pixels
global data
hold on
size_image = size(data.imagesc.CData);

if evnt.VerticalScrollCount > 0
    data.snr_thr = min([99,data.snr_thr + 1]);
elseif evnt.VerticalScrollCount < 0
    data.snr_thr = max([1,data.snr_thr - 1]);
end
threshold = prctile(data.mat_choose_roi(:),data.snr_thr);
while length(find(data.mat_choose_roi>threshold))<min(data.min_px_roi,length(data.mat_choose_roi(:)))%isempty(find(data.mat_choose_roi>threshold))
    data.snr_thr = data.snr_thr-1;
    threshold = prctile(data.mat_choose_roi(:),data.snr_thr);
end
 data.chosen_pixels = find(data.mat_choose_roi>threshold);
 [~,~,index_aux] = intersect(data.pixels_outside_ellipse,data.chosen_pixels);
 data.chosen_pixels(index_aux) = [];
 data.chosen_pixels = oneD_to_twoD(size(data.mat_choose_roi,1),data.chosen_pixels);
 data.chosen_pixels = data.chosen_pixels+repmat([data.reference_point(1)-1,data.reference_point(2)-1],...
     size(data.chosen_pixels,1),1);
 data.chosen_pixels(data.chosen_pixels(:,1)<1,:) = [];
 data.chosen_pixels(data.chosen_pixels(:,2)<1,:) = [];
 data.chosen_pixels(data.chosen_pixels(:,1)>size_image(1),:) = [];
 data.chosen_pixels(data.chosen_pixels(:,2)>size_image(2),:) = [];
 axes(data.handles.drawing_figure_handle)
 delete(data.handles.chosen_pixels)
 data.handles.chosen_pixels = plot(data.chosen_pixels(:,2),data.chosen_pixels(:,1),'.r');
 axes(data.handles.large_proj_axes)
 delete(data.handles.chosen_pixels_p)
 data.handles.chosen_pixels_p = plot(data.chosen_pixels(:,2),data.chosen_pixels(:,1),'.r');

plot_fluorescence_traces

