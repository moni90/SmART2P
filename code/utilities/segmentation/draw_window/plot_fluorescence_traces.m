function plot_fluorescence_traces
global data
%show fluorescence traces
local_time = 2;
size_image = size(data.imagesc.CData);
video = data.movie_doc.movie_ruido;
chosen_pixels_1D = sub2ind([size_image(1) size_image(2)],data.chosen_pixels(:,1),data.chosen_pixels(:,2));


%whole
total_trace = mean(video(:,chosen_pixels_1D),2);
plot(data.handles.whole_trace_axes,total_trace,'b','linewidth',2)
lower_trace_th_aux = prctile(total_trace,25);
lower_trace_activity = total_trace(total_trace<=lower_trace_th_aux);
if std(lower_trace_activity)==0
    lower_standard_deviation = inf;
else
    lower_standard_deviation = std(lower_trace_activity);
end
data.current_snr =  (max(total_trace)-mean(lower_trace_activity))/lower_standard_deviation;

hold(data.handles.whole_trace_axes,'on')
plot(data.handles.whole_trace_axes,ones(1,2)*max([data.frame_plot_aux-ceil(local_time/data.framePeriod),1]),...
    [data.all_pixels_on_square_limits(1) data.all_pixels_on_square_limits(2)],'--','color',[.5 .5 .5])
plot(data.handles.whole_trace_axes,ones(1,2)*min([data.frame_plot_aux+ceil(local_time/data.framePeriod),data.duration]),...
    [data.all_pixels_on_square_limits(1) data.all_pixels_on_square_limits(2)],'--','color',[.5 .5 .5])
xlabel(data.handles.whole_trace_axes, 'Time (frames)');
ylabel(data.handles.whole_trace_axes, 'Fluo (a.u.)');
title(data.handles.whole_trace_axes, 'Raw fluorescence')

set(data.handles.whole_trace_axes,'ylim',[data.all_pixels_on_square_limits(1) data.all_pixels_on_square_limits(2)]);
set(data.handles.whole_trace_axes,'xlim',[1 numel(total_trace)]);
hold(data.handles.whole_trace_axes,'off')

title(data.handles.SNR_axes,['Neuron ' num2str(data.numero_neuronas) ' / Pixels: ' num2str(numel(chosen_pixels_1D)) [' / SNR:' num2str(data.current_snr)]])
xlabel(data.handles.SNR_axes, 'Num of pixels');
ylabel(data.handles.SNR_axes, 'SNR (a.u.)');
hold(data.handles.SNR_axes,'on')
s = findobj('marker','*');
if ~isempty(s)
    delete(s)
end
data.handles.current_snr = plot(data.handles.SNR_axes,min(200,numel(chosen_pixels_1D)),data.current_snr,'*r','markersize',10);
%data.handles.current_snr = plot(data.handles.SNR_axes,data.snr_current_max_ind,data.signal_to_noise_ratio_mat(data.numero_neuronas,data.snr_current_max_ind),'*g','markersize',10);
hold(data.handles.SNR_axes,'off')

