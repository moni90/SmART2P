function pass_frames(~,evnt)
%this functions allows the user to pass the different frames of the movie
%in order to best choose the ROIs.
global data
if ~isequal(data.mode,'Linescan') && ~isequal(data.mode,'freehand')
    data.corr_proj = 0;
    axes(data.handles.drawing_figure_handle)
    if ~isequal(data.mode,'Linescan') && ~isequal(data.mode,'freehand')
        delete(data.imagesc)
        hold on
        imagen = data.movie_doc.movie_ruido;
        %     imagen = data.movie_doc.movie_stack;
        if evnt.VerticalScrollCount > 0
            data.frame_plot = max(1,data.frame_plot-1);
        elseif evnt.VerticalScrollCount < 0
            data.frame_plot = min(size(imagen,1),data.frame_plot+1);
        end
        data.current_stack = max([data.frame_plot-data.average_window_choose_roi_current,1]):...
            min([data.frame_plot+data.average_window_choose_roi_current,data.duration]);
        
        imagen = imagen(data.frame_plot,:);
        imagen = reshape(imagen, data.linesPerFrame,[]);
        data.imagesc = imagesc(imagen);
        uistack(data.imagesc ,'bottom')
        if ~isequal(data.mode,'Linescan') && ~isequal(data.mode,'freehand'); axis image; else axis square; end
        colormap(gray)
        title(num2str(data.frame_plot))
        data.current_stack_p = min(ceil(data.frame_plot/data.average_window_choose_roi_current),size(data.avg_proj,3));
        %change correlation projection frame
        axes(data.handles.DR_proj_axes);
        delete(data.imDR)
        hold on
        data.imDR = imagesc(data.DR_proj(:,:,data.current_stack_p));
        colormap(gray)
        title(['DR proj ', ...
            num2str(1+(data.current_stack_p-1)*data.average_window_choose_roi_current) ,...
            ' - ', ...
            num2str(min(data.duration,(data.current_stack_p)*data.average_window_choose_roi_current))]);
        %change average projection frame
        axes(data.handles.avg_proj_axes);
        delete(data.imavg)
        hold on
        data.imavg = imagesc(data.avg_proj(:,:,data.current_stack_p));
        colormap(gray)
        title(['AVG proj ', ...
            num2str(1+(data.current_stack_p-1)*data.average_window_choose_roi_current) ,...
            ' - ', ...
            num2str(min(data.duration,(data.current_stack_p)*data.average_window_choose_roi_current))]);
        %change selected projection frame
        axes(data.handles.large_proj_axes);
        delete(data.imlarge)
        hold on
        data.imlarge = imagesc(data.large_proj(:,:,data.current_stack_p));
        colormap(gray)
        uistack(data.imlarge ,'bottom')
        title([data.selected_proj, ' proj ', ...
            num2str(1+(data.current_stack_p-1)*data.average_window_choose_roi_current) ,...
            ' - ', ...
            num2str(min(data.duration,(data.current_stack_p)*data.average_window_choose_roi_current))]);
    end
end