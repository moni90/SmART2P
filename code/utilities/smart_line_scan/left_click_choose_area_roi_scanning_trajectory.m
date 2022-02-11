function left_click_choose_area_roi_scanning_trajectory(src,~)
global data
if strcmp(get(src,'SelectionType'),'alt')
    set(src,'WindowButtonDownFcn',@wbdcb_scanning_trajectory)
    delete(data.handles.scan_area_roi)
elseif strcmp(get(src,'SelectionType'),'normal')
    delete(data.handles.scan_area_roi)
    set(src,'WindowButtonUpFcn','')
    set(src,'WindowButtonDownFcn','')
    set(src,'WindowScrollWheelFcn','')
    aux = data.current_point_choose_area_roi;
    [aux1, aux2] = meshgrid(max([1,aux(1)-data.size_area_roi]):min([data.linesPerFrame,aux(1)+data.size_area_roi]),...
        max([1,aux(2)-data.size_area_roi]):min([data.pixels_per_line,aux(2)+data.size_area_roi]));
    plot(aux2(:)',aux1(:)','-','color',[.2 .2 .2])
    data.scan_traj = [data.scan_traj [aux1(:) aux2(:)]'];
    data.scan_traj = unique(data.scan_traj','rows','stable')';
    s = findobj('color','y');
    if ~isempty(s)
        delete(s)
    end
    plot(data.scan_traj(2,:),data.scan_traj(1,:),'-','color','y');
    for ind_n=1:data.numero_neuronas
        %find farthest points
        roi_dots = squeeze(data.rois_inside(ind_n,:,:));
        roi_dots(:,roi_dots(1,:)==0) = [];
        plot(roi_dots(2,:),roi_dots(1,:),'.','color',data.colores(ind_n,:))
    end
    distancia =  sum(sqrt(diff(data.scan_traj(1,:)).^2 + diff(data.scan_traj(2,:)).^2));
    title(['Trajectory length = ' num2str(distancia) ' (a.u.)'])
end