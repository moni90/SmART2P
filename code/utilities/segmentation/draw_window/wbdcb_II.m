function wbdcb_II(src,~)
%this function gets called at then of the ROI (left click) or when the user
%wants to delete the ROI and start again (right click).In the first case,
%it will called a second ButtonUp function that will start the process again.
%(XXX The else might not be necessary..)
global data
if strcmp(get(src,'SelectionType'),'alt')
    delete(data.handles.ellipse_handles(data.handles.ellipse_handles~=0))
    set(src,'WindowScrollWheelFcn',@pass_frames)
    set(src,'WindowButtonDownFcn',@wbdcb)
    set(src,'WindowButtonMotionFcn','')
    set(src,'WindowButtonUpFcn','')
    data.numero_puntos_ellipse = 0;
    data.numero_neuronas = data.numero_neuronas - 1;
elseif strcmp(get(src,'SelectionType'),'normal')
    delete(data.handles.ellipse_handles(data.handles.ellipse_handles~=0))
    set(src,'WindowButtonUpFcn','')
    set(src,'WindowButtonMotionFcn','')
    set(src,'WindowScrollWheelFcn',@choose_threshold)
    set(src,'WindowButtonDownFcn',@left_click_choose_threshold)
    
    ellipse_t = fit_ellipse(data.ellipse(2,:),data.ellipse(1,:));
    current_point = round([ellipse_t.Y0_in ellipse_t.X0_in]);
    data.size_area_roi = ceil(max([abs(data.ellipse(1,:)-ellipse_t.Y0_in),abs(data.ellipse(2,:)-ellipse_t.X0_in)]));
    plot_chosen_pixels(current_point,ellipse_t);

    
end