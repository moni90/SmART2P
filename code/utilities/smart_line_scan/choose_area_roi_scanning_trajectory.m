function choose_area_roi_scanning_trajectory(~,evnt)
%this functions allows the user to pass the different frames of the movie
%in order to best choose the ROIs.
global data
hold on
if evnt.VerticalScrollCount > 0
    data.size_area_roi = data.size_area_roi + 1;
elseif evnt.VerticalScrollCount < 0
    data.size_area_roi = max([1,data.size_area_roi - 1]);
end
aux = data.current_point_choose_area_roi;
aux = [aux;[max([1,aux(1)-data.size_area_roi]) max([1,aux(2)-data.size_area_roi])];...
    [max([1,aux(1)-data.size_area_roi]) min([data.pixels_per_line,aux(2)+data.size_area_roi])];...
    [min([data.linesPerFrame,aux(1)+data.size_area_roi]) max([1,aux(2)-data.size_area_roi])];...
    [min([data.linesPerFrame,aux(1)+data.size_area_roi]) min([data.pixels_per_line,aux(2)+data.size_area_roi])]];
delete(data.handles.scan_area_roi)
data.handles.scan_area_roi = plot(aux(:,2),aux(:,1),'+y','markerSize',6);