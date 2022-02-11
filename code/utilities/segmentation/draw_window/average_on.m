function average_on(~,evnt)
global data
if ~isequal(data.mode,'Linescan') && ~isequal(data.mode,'freehand')
    video = data.movie_doc.movie_ruido;
    yes = true;
    if isequal(evnt.Key,'space') && ~isfield(data,'mat_choose_roi')
        axes(data.handles.drawing_figure_handle)
        data.current_stack = 1:data.duration;
    elseif isequal(evnt.Key,'x')
        axes(data.handles.drawing_figure_handle)
        data.average_slash_max = 'DR';
    elseif isequal(evnt.Key,'a')
        axes(data.handles.drawing_figure_handle)
        data.average_slash_max = 'mean';
    elseif isequal(evnt.Key,'leftarrow')
        aux_caxis = caxis;
        caxis([aux_caxis(1)-(diff(data.caxis)/10) aux_caxis(2)])
    elseif isequal(evnt.Key,'rightarrow')
        aux_caxis = caxis;
        caxis([aux_caxis(1)+(diff(data.caxis)/10) aux_caxis(2)])
    elseif isequal(evnt.Key,'uparrow')
        aux_caxis = caxis;
        caxis([aux_caxis(1) aux_caxis(2)+(diff(data.caxis)/10)])
    elseif isequal(evnt.Key,'downarrow')
        aux_caxis = caxis;
        caxis([aux_caxis(1) aux_caxis(2)-(diff(data.caxis)/10)])  
    else
        yes = false;
    end
    if yes
        delete(data.imagesc)
        hold on
        imagen = average_slash_max(video(data.current_stack,:));
        imagen = reshape(imagen,data.linesPerFrame,[]);
        data.imagesc = imagesc(imagen);
        uistack(data.imagesc ,'bottom')
        if ~isequal(data.mode,'Linescan') && ~isequal(data.mode,'freehand'); axis image; else axis square; end
        colormap(gray)
        title([num2str(data.frame_plot) '   ' data.average_slash_max ' frames:' num2str(data.current_stack(1)) '-' num2str(data.current_stack(end))])
        
    elseif isequal(evnt.Key,'h')
        if data.rois_hidden
            axes(data.handles.drawing_figure_handle)
            hold on
            for ind_n=1:data.numero_neuronas
                roi_dots = squeeze(data.roi(ind_n,:,:));
                roi_dots(:,roi_dots(1,:)==0) = [];
                data.line_handles(ind_n,:) = plot(roi_dots(2,:),roi_dots(1,:),'.','markersize',6,'color',data.colores(ind_n,:));
                centro = data.rois_centres(ind_n,:);
                plot(centro(2),centro(1),'+','color',data.colores(ind_n,:));
            end
            axes(data.handles.large_proj_axes);
            for ind_n=1:data.numero_neuronas
                roi_dots = squeeze(data.roi(ind_n,:,:));
                roi_dots(:,roi_dots(1,:)==0) = [];
                data.line_handles(ind_n,:) = plot(roi_dots(2,:),roi_dots(1,:),'.','markersize',6,'color',data.colores(ind_n,:));
                centro = data.rois_centres(ind_n,:);
                plot(centro(2),centro(1),'+','color',data.colores(ind_n,:));
            end
            data.rois_hidden = 0;
        else
            axes(data.handles.drawing_figure_handle)
            s = findobj(data.handles.drawing_figure_handle,'type','line');
            if ~isempty(s)
                delete(s)
            end
            axes(data.handles.large_proj_axes);
            s = findobj(data.handles.large_proj_axes,'type','line');
            if ~isempty(s)
                delete(s)
            end
            data.rois_hidden = 1;
        end
    elseif isequal(evnt.Key,'c')
        axes(data.handles.large_proj_axes);
        delete(data.imlarge)
        hold on
        aux_caxis = caxis;
        if isfield(data,'CNimage')
            imagen = aux_caxis(2)*data.CNimage;
        else
            imagen = aux_caxis(2)*correlation_image(data.movie_doc.movie_ruido',8,...
                data.linesPerFrame, data.pixels_per_line);
        end
        data.imlarge = imagesc(imagen);
        uistack(data.imlarge ,'bottom')
        data.corr_proj = 1;
        title('Correlation proj ');
    elseif isequal(evnt.Key,'1')
        data.selected_proj = 'DR';
        data.corr_proj = 0;
        axes(data.handles.large_proj_axes);
        data.large_proj = data.DR_proj;
        delete(data.imlarge)
        hold on
        data.imlarge = imagesc(data.large_proj(:,:,data.current_stack_p));
        colormap(gray)
        uistack(data.imlarge ,'bottom')
        title(['DR proj ', ...
            num2str(1+(data.current_stack_p-1)*data.average_window_choose_roi_current) ,...
            ' - ', ...
            num2str(min(data.duration,(data.current_stack_p)*data.average_window_choose_roi_current))]);
    elseif isequal(evnt.Key,'2')
        data.selected_proj = 'AVG';
        data.corr_proj = 0;
        axes( data.handles.large_proj_axes);
        data.large_proj = data.avg_proj;
        delete(data.imlarge)
        hold on
        data.imlarge = imagesc(data.large_proj(:,:,data.current_stack_p));
        colormap(gray)
        uistack(data.imlarge ,'bottom')
        title(['AVG proj ', ...
            num2str(1+(data.current_stack_p-1)*data.average_window_choose_roi_current) ,...
            ' - ', ...
            num2str(min(data.duration,(data.current_stack_p)*data.average_window_choose_roi_current))]);
        
    end
end
