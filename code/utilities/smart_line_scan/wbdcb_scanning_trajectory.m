function wbdcb_scanning_trajectory(src,~)
%this function will be called when the user starts a new ROI.This and the
%nexts functions is adapted from the code provided by matlab to help
%understanding the use of WindowButtonMotionFcn.
global data
cp = get(gca,'CurrentPoint');
set(src,'WindowScrollWheelFcn',@choose_area_roi_scanning_trajectory)
set(src,'WindowButtonDownFcn',@left_click_choose_area_roi_scanning_trajectory)
data.current_point_choose_area_roi = round([cp(1,2),cp(1,1)]);
aux = data.current_point_choose_area_roi;
aux = [aux;[max([1,aux(1)-data.size_area_roi]) max([1,aux(2)-data.size_area_roi])];...
    [max([1,aux(1)-data.size_area_roi]) min([data.pixels_per_line,aux(2)+data.size_area_roi])];...
    [min([data.linesPerFrame,aux(1)+data.size_area_roi]) max([1,aux(2)-data.size_area_roi])];...
    [min([data.linesPerFrame,aux(1)+data.size_area_roi]) min([data.pixels_per_line,aux(2)+data.size_area_roi])]];
data.handles.scan_area_roi = plot(aux(:,2),aux(:,1),'+y','markerSize',6);
