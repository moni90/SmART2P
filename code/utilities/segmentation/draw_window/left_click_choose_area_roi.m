function left_click_choose_area_roi(src,~)
%right click to remove selection, left click to confirm area selected ROI
global data
if strcmp(get(src,'SelectionType'),'alt')
    data.numero_neuronas = data.numero_neuronas - 1;
    set(src,'WindowScrollWheelFcn',@pass_frames)
    set(src,'WindowButtonDownFcn',@wbdcb)
    delete(data.handles.area_roi)
    delete(data.handles.area_roi_p)
elseif strcmp(get(src,'SelectionType'),'normal')
    delete(data.handles.area_roi)
    delete(data.handles.area_roi_p)
    set(src,'WindowScrollWheelFcn',@choose_threshold)
    set(src,'WindowButtonDownFcn',@left_click_choose_threshold)
    current_point = data.current_point_choose_area_roi;
    data.flag_marker_pos = true;
    plot_chosen_pixels(current_point);
end