function left_click_choose_threshold(src,~)
%right click remove selection, left click confirm selected pixels
global data
size_image = size(data.imagesc.CData);
if strcmp(get(src,'SelectionType'),'alt')
    data.numero_neuronas = data.numero_neuronas - 1;
    set(src,'WindowScrollWheelFcn',@pass_frames)
    set(src,'WindowButtonDownFcn',@wbdcb)
    delete(data.handles.chosen_pixels)
    delete(data.handles.chosen_pixels_p)
    data = rmfield(data,'mat_choose_roi');
    data = rmfield(data,'chosen_pixels');
elseif strcmp(get(src,'SelectionType'),'normal')
    set(src,'WindowScrollWheelFcn',@pass_frames)
    set(src,'WindowButtonDownFcn',@wbdcb)
    if ~isequal(data.mode,'Linescan') && ~isequal(data.mode,'freehand')
        data.rois_inside(data.numero_neuronas,:,1:max(size(data.chosen_pixels))) = data.chosen_pixels';
        data.rois_centres(data.numero_neuronas,:) = mean(data.chosen_pixels,1);
        silueta = zeros(size_image);
        aux_1D = twoD_to_oneD(size_image(1),data.chosen_pixels);
        silueta(aux_1D) = 1;
        [a,b] = gradient(silueta);
        [ai aj] = find(a); %#ok<NCOMMA>
        [bi bj] = find(b); %#ok<NCOMMA>
        result = union([ai aj],[bi bj],'rows');
    else
        data.rois_inside(data.numero_neuronas,:,1:max(size(data.chosen_pixels))) = [ones(numel(data.chosen_pixels),1) data.chosen_pixels']';
        data.rois_centres(data.numero_neuronas,:) = [1 mean(data.chosen_pixels)];
        silueta = zeros(1,size_image(2));
        aux_1D = data.chosen_pixels;
        silueta(aux_1D) = 1;
        a = diff(silueta);
        [ai aj] = find(a);  %#ok<NCOMMA>
        result = [ai; aj];
        result = result';
    end
    data.roi(data.numero_neuronas,:,1:size(result,1)) = result';
    data.numero_puntos(data.numero_neuronas) = max(size(data.chosen_pixels));
    data.snr_per_neuron(data.numero_neuronas,:) = [data.current_snr data.total_snr data.numero_puntos(data.numero_neuronas) data.total_num_points];
    delete(data.handles.chosen_pixels)
    delete(data.handles.chosen_pixels_p)
    %
    axes(data.handles.large_proj_axes)
    hold on; data.line_handles_p(data.numero_neuronas,:) =...
        plot(result(:,2),result(:,1),'.','color',data.colores(data.numero_neuronas,:),'markerSize',10);
    axes(data.handles.drawing_figure_handle)
    %
    data.line_handles(data.numero_neuronas,:) =...
        plot(result(:,2),result(:,1),'.','color',data.colores(data.numero_neuronas,:),'markerSize',10);
    if data.CNMF == 1
        data.paninski.added = 1;
    end
    data = rmfield(data,'mat_choose_roi');
    data = rmfield(data,'chosen_pixels');
    if isequal(data.mode,'Linescan') || isequal(data.mode,'freehand')
        data.handles = rmfield(data.handles,'pixels_in_traj');
        
        margin_x = 0;%(max(data.freehand_scan(1,:)) - min(data.freehand_scan(1,:)))/20;
        margin_y = 0;%(max(data.freehand_scan(2,:)) - min(data.freehand_scan(2,:)))/20;
        
        set(data.handles.SNR_axes,'xlim',[min(data.freehand_scan(1,:))-margin_x max(data.freehand_scan(1,:))+margin_x],...
            'ylim',[min(data.freehand_scan(2,:))-margin_y max(data.freehand_scan(2,:))+margin_y])
    end
end