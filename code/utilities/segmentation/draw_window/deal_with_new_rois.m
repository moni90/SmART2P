function data = deal_with_new_rois(data)
%extract fluorescence activity from ROIs selected (no processing)

data = all_points_cells(data);

set(data.handles.scanning_trajectory,'visible','on')
set(data.handles.update_ROIs,'visible','on')

%once we have the ROIs and their insides we plot them.
update_listbox(data.numero_neuronas)
hold(data.handles.axes_handles_imagen,'on')
for ind_n=1:data.numero_neuronas
    roi_dots = squeeze(data.roi(ind_n,:,:));
    roi_dots(:,roi_dots(1,:)==0) = [];
    data.handles.outline_rois(ind_n,:) =...
        plot(data.handles.axes_handles_imagen,roi_dots(2,:),roi_dots(1,:),'.','markersize',2,'color',data.colores(ind_n,:));
end
hold(data.handles.axes_handles_imagen,'off')
%set the text in the gui 'num_neuronas_text' according to the number of
%neurons
set(data.handles.num_neuronas_text,'string',num2str(data.numero_neuronas))

% data = fluorescence(data); %save fluorescence traces in data structure
%plot ROIs traces in main window
hold(data.handles.axes_handles_activity,'off')
for ind_n=1:data.numero_neuronas
    if data.CNMF==0
        activity = squeeze(data.activities(ind_n,:));
        paso = (max(data.activities(:))-min(data.activities(:)))/2;
        t = min(data.activities(:))-paso:paso:max(data.activities(:))+paso;
        data.handle_frame_indicator = plot(data.handles.axes_handles_activity,ones(1,numel(t))*data.frameTimes(min(numel(data.frameTimes),data.frame_plot)),t,'color',[.7 .7 .7]);
    else
        activity = squeeze(data.activities_deconvolved(ind_n,:));
        paso = (max(data.activities_deconvolved(:))-min(data.activities_deconvolved(:)))/2;
        t = min(data.activities_deconvolved(:))-paso:paso:max(data.activities_deconvolved(:))+paso;
        data.handle_frame_indicator = plot(data.handles.axes_handles_activity,ones(1,numel(t))*data.frameTimes(min(numel(data.frameTimes),data.frame_plot)),t,'color',[.7 .7 .7]);
    end
    timing = squeeze(data.pixelsTimes(ind_n,:));
    data.handles.activities(ind_n,:) = plot(data.handles.axes_handles_activity,timing,activity,'color',data.colores(ind_n,:));
    hold(data.handles.axes_handles_activity,'on')
end
set(data.handles.axes_handles_activity,'xlim',[data.frameTimes(1),data.frameTimes(end)])

hold(data.handles.axes_handles_activity,'off')
data.prediction_made = 1;


