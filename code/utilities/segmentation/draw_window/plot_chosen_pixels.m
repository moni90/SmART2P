function plot_chosen_pixels(current_point,ellipse_t)
%plot avtivity and SNR of the selected ROI

global data
video = data.movie_doc.movie_ruido;
size_image = size(data.imagesc.CData);

%select pixels to include in the roi
xs = max([1,current_point(1)-data.size_area_roi]):min([size_image(1),current_point(1)+data.size_area_roi]);
ys = max([1,current_point(2)-data.size_area_roi]):min([size_image(2),current_point(2)+data.size_area_roi]);
unos = ones(size_image(1),size_image(2));
coord = unos(xs,ys);
%actual middle points
data.reference_point = [max([1,current_point(1)-data.size_area_roi]),max([1,current_point(2)-data.size_area_roi])];
%get all pixels on the square
all_pixels_on_square = find(coord);
all_pixels_on_square = oneD_to_twoD(size(coord,1),all_pixels_on_square);
all_pixels_on_square = all_pixels_on_square+repmat([data.reference_point(1)-1,data.reference_point(2)-1],...
    size(all_pixels_on_square,1),1);
all_pixels_on_square(all_pixels_on_square(:,1)<1,:) = [];
all_pixels_on_square(all_pixels_on_square(:,2)<1,:) = [];
all_pixels_on_square(all_pixels_on_square(:,1)>size_image(1),:) = [];
all_pixels_on_square(all_pixels_on_square(:,2)>size_image(2),:) = [];
if nargin>1
    mat = [cos(ellipse_t.phi) -sin(ellipse_t.phi);sin(ellipse_t.phi) cos(ellipse_t.phi)];
    rot_all_pix = all_pixels_on_square*mat;
    data.pixels_outside_ellipse = find((rot_all_pix(:,1)-ellipse_t.Y0).^2/(ellipse_t.short_axis/2)^2 + (rot_all_pix(:,2)-ellipse_t.X0).^2/(ellipse_t.long_axis/2)^2>1);
else
    data.pixels_outside_ellipse = [];
end
activity_temp = video(:,sub2ind([size_image(1) size_image(2)],all_pixels_on_square(:,1),all_pixels_on_square(:,2)));
all_pixels_on_square(data.pixels_outside_ellipse,:) = [];
all_pixels_on_square = sub2ind([size_image(1) size_image(2)],all_pixels_on_square(:,1),all_pixels_on_square(:,2));

%plot the image for the period with highest activity
if isfield(data,'corr_proj') && data.corr_proj == 1
    data.frame_plot_aux = find_strongest_event(all_pixels_on_square);
else
    data.frame_plot_aux = find_strongest_event(all_pixels_on_square);
end
data.current_stack = max([data.frame_plot_aux-data.average_window_choose_roi_current,1]):...
    min([data.frame_plot_aux+data.average_window_choose_roi_current,data.duration]);
imagen = average_slash_max(video(data.current_stack,:));
imagen = reshape(imagen,size_image(1),[]);

lower_trace_th_aux = prctile(activity_temp,25,1);
lower_trace_activity = activity_temp(activity_temp<=repmat(lower_trace_th_aux,size(activity_temp,1),1));
lower_standard_deviation = std(lower_trace_activity,[],1);
lower_standard_deviation(lower_standard_deviation==0)=Inf;
snr_temp = (activity_temp(data.frame_plot_aux,:)-mean(lower_trace_activity,1))./lower_standard_deviation;
data.mat_choose_roi = reshape(squeeze(snr_temp),size(coord));
snr_all = snr_temp;
snr_all(data.pixels_outside_ellipse) = [];

axes(data.handles.drawing_figure_handle)
delete(data.imagesc)
hold on
data.imagesc = imagesc(imagen);
uistack(data.imagesc ,'bottom')
axis image;
colormap(gray)
if numel(data.current_stack)<data.duration
    title([num2str(data.frame_plot) '   ' data.average_slash_max ' frames:' num2str(data.current_stack(1)) '-' num2str(data.current_stack(end))])
else
    title([ data.average_slash_max ' all frames'])
end
% data.mat_choose_roi = imagen(xs,ys);

%Show SNR
% activity_all = video(:,all_pixels_on_square);
% lower_trace_th_aux = prctile(activity_all,25,1);
% lower_trace_activity = activity_all(activity_all<=repmat(lower_trace_th_aux,size(activity_all,1),1));
% lower_standard_deviation = std(lower_trace_activity,[],1);
% lower_standard_deviation(lower_standard_deviation==0)=Inf;
% snr_all = (activity_all(data.frame_plot_aux,:)-mean(lower_trace_activity,1))./lower_standard_deviation;
% data.mat_choose_roi = snr_all;

[~,index_fl] = sort(snr_all,'descend');
all_pixels_on_square_sorted = all_pixels_on_square(index_fl);
for ind_px=1:min(200,numel(all_pixels_on_square_sorted))
    trace = mean(video(:,all_pixels_on_square_sorted(1:ind_px)),2);
    lower_trace_th_aux = prctile(trace,25);
    lower_trace_activity = trace(trace<=lower_trace_th_aux);
    if std(lower_trace_activity)==0
        lower_standard_deviation = inf;
    else
        lower_standard_deviation = std(lower_trace_activity);
    end
    data.signal_to_noise_ratio_mat(data.numero_neuronas,ind_px) = (max(trace)-mean(lower_trace_activity))/lower_standard_deviation;
end
data.signal_to_noise_ratio_mat(data.numero_neuronas,ind_px+1:end) = 0;
b = fir1(floor(0.3*min(200,numel(all_pixels_on_square_sorted))),0.5); %low pass filter. cutoff frequency=0.5, order=floor(0.3*min(200,numel(all_pixels_on_square_sorted)))
data.signal_to_noise_ratio_smooth = filtfilt(b,1,data.signal_to_noise_ratio_mat(data.numero_neuronas,1:min(200,numel(all_pixels_on_square_sorted))));

[data.snr_current_max, data.snr_current_max_ind]= max(data.signal_to_noise_ratio_smooth);
plot(data.handles.SNR_axes,1:min(200,numel(all_pixels_on_square_sorted)),...
    data.signal_to_noise_ratio_mat(data.numero_neuronas,1:min(200,numel(all_pixels_on_square_sorted))),'b','linewidth',2);
if(data.flag_marker_pos)
    snr_thr = snr_all(index_fl(data.snr_current_max_ind));
    data.snr_thr = ceil(100*sum(data.mat_choose_roi(:)<snr_thr))/(length(data.mat_choose_roi(:)));
    threshold = prctile(data.mat_choose_roi(:),data.snr_thr);
    while isempty(find(data.mat_choose_roi>threshold))
        snr_thr = snr_thr-1;
        threshold = prctile(data.mat_choose_roi(:),snr_thr);
    end
end
% data.snr_thr = 65;%da commentare ed eliminare!
% threshold = prctile(data.mat_choose_roi(:),65); %da commentare ed eliminare!
data.flag_marker_pos = false;
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

data.handles.chosen_pixels = plot(data.chosen_pixels(:,2),data.chosen_pixels(:,1),'.r');

axes(data.handles.large_proj_axes)
hold(data.handles.large_proj_axes,'on');
data.handles.chosen_pixels_p = plot(data.chosen_pixels(:,2),data.chosen_pixels(:,1),'.r');
hold(data.handles.large_proj_axes,'off');


trace = mean(video(:,all_pixels_on_square_sorted),2);
lower_trace_th_aux = prctile(trace,25);
lower_trace_activity = trace(trace<=lower_trace_th_aux);
if std(lower_trace_activity)==0
    lower_standard_deviation = inf;
else
    lower_standard_deviation = std(lower_trace_activity);
end
data.total_snr = (max(trace)-mean(lower_trace_activity))/lower_standard_deviation;
data.total_num_points = numel(all_pixels_on_square_sorted);

%get max and min for traces axis
data.all_pixels_on_square_limits = [min(min(video(:,all_pixels_on_square),[],2)),max(max(video(:,all_pixels_on_square),[],2))];

plot_fluorescence_traces
data.numero_puntos_ellipse = 0;
data.ellipse = [];
