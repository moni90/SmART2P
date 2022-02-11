function wbdcb(src,~)
%this function will be called when the user starts a new ROI.This and the
%nexts functions is adapted from the code provided by matlab to help
%understanding the use of WindowButtonMotionFcn.
global data
data.flag_marker_pos= true;
size_image = size(data.imagesc.CData);
if strcmp(get(src,'SelectionType'),'alt') %right click: if on a ROI, select ROI you wish to remove, otherwise selct box to draw ROI
    delete(findall(data.handles.drawing_figure_handle,'lineStyle','--'))
    data.some_drawing_done = 1;
    cp = get(gca,'CurrentPoint');
    pixel = round([cp(1,2),cp(1,1)]);
    dist = sqrt((pixel(1)-data.rois_centres(:,1)).^2 + (pixel(2)-data.rois_centres(:,2)).^2);
    [~,indice] = min(dist);
    roi_dots = squeeze(data.roi(indice,:,:));
    roi_dots(:,roi_dots(1,:)==0) = nan;
    if pixel(1)>=min(roi_dots(1,:)) && pixel(1)<=max(roi_dots(1,:)) &&...
            pixel(2)>min(roi_dots(2,:)) && pixel(2)<max(roi_dots(2,:)) && ~data.rois_hidden
        set(src,'WindowButtonDownFcn',@confirm_remove)
        data.remove_rois = indice;
        %highlight selected ROI on single frame TSeries
        hold(data.handles.drawing_figure_handle ,'on')
        plot(data.handles.drawing_figure_handle ,roi_dots(2,:),roi_dots(1,:),'*','color',[1 0 0]);
        hold(data.handles.drawing_figure_handle ,'off')
        %highlight selected ROI on projection
        hold(data.handles.large_proj_axes ,'on')
        plot(data.handles.large_proj_axes ,roi_dots(2,:),roi_dots(1,:),'*','color',[1 0 0]);
        hold(data.handles.large_proj_axes ,'off')
        %plot total fluo trace of selected ROI
        if data.CNMF == 1
%             total_trace = data.C_df(data.remove_rois,:);
            total_trace = squeeze(data.activities(data.remove_rois,:));
        else
            total_trace = squeeze(data.activities(data.remove_rois,:));
        end
        plot(data.handles.whole_trace_axes,total_trace,'b','linewidth',2)
        xlabel(data.handles.whole_trace_axes,'Time (frames)'); ylabel(data.handles.whole_trace_axes,'Fluo (a.u.)');
        title(data.handles.whole_trace_axes,'Raw fluorescence');
    else
        data.numero_neuronas = data.numero_neuronas + 1;
        set(src,'WindowScrollWheelFcn',@choose_area_roi)
        set(src,'WindowButtonDownFcn',@left_click_choose_area_roi)
        data.current_point_choose_area_roi = round([cp(1,2),cp(1,1)]);
        
        axes(data.handles.drawing_figure_handle)
        delete(data.imagesc)
        hold on
        imagen = data.movie_doc.movie_ruido;
        if ~isequal(data.mode,'Linescan') && ~isequal(data.mode,'freehand')
            imagen = average_slash_max(imagen(data.current_stack,:));
            imagen = reshape(imagen, data.linesPerFrame,[]);
        end
        aux = data.current_point_choose_area_roi;
        aux = [aux;[max([1,aux(1)-data.size_area_roi]) max([1,aux(2)-data.size_area_roi])];...
            [max([1,aux(1)-data.size_area_roi]) min([size(imagen,2),aux(2)+data.size_area_roi])];...
            [min([size(imagen,1),aux(1)+data.size_area_roi]) max([1,aux(2)-data.size_area_roi])];...
            [min([size(imagen,1),aux(1)+data.size_area_roi]) min([size(imagen,2),aux(2)+data.size_area_roi])]];
        data.handles.area_roi = plot(aux(:,2),aux(:,1),'+y','markerSize',6);
        data.imagesc = imagesc(imagen);
        uistack(data.imagesc ,'bottom')
        axis image;
        colormap(gray)
        title([num2str(data.frame_plot) '   ' data.average_slash_max ' frames:' num2str(data.current_stack(1)) '-' num2str(data.current_stack(end))])
        axes(data.handles.large_proj_axes)
        hold(data.handles.large_proj_axes ,'on');
        data.handles.area_roi_p = plot(aux(:,2),aux(:,1),'+y','markerSize',6);
        hold(data.handles.large_proj_axes,'off');
    end
elseif strcmp(get(src,'SelectionType'),'normal')
    if data.handles.SNR_axes == gca && isequal(data.mode,'freehand')
        cp = get(gca,'CurrentPoint');
        pixel = round([cp(1,2),cp(1,1)]);
        [~,closer_pixel]= min(sqrt((data.freehand_scan(1,:)-pixel(2)).^2 + (data.freehand_scan(2,:)-pixel(1)).^2));
        data.handles.reference_pixel = plot(data.handles.drawing_figure_handle,closer_pixel*ones(1,2),[1 size_image(1)],'--r','lineWidth',0.5);
    else
        delete(findall(data.handles.drawing_figure_handle,'lineStyle','--'))
        data.numero_neuronas = data.numero_neuronas + 1;
        data.some_drawing_done = 1;
        set(src,'WindowButtonMotionFcn',@wbmcb)%activate the WindowButtonMotionFcn (wbmcb)
        set(src,'WindowButtonUpFcn',@wbucb)
        %increment the number of neurons
    end
end
