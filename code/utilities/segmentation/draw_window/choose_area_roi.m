function choose_area_roi(~,evnt)
%this functions allows the user to pass the different frames of the movie
%in order to best choose the ROIs.
global data
hold on
size_image = size(data.imagesc.CData);
increment = 1;
if evnt.VerticalScrollCount > 0
    data.size_area_roi = data.size_area_roi + increment;
elseif evnt.VerticalScrollCount < 0
    data.size_area_roi = max([1,data.size_area_roi - increment]);
end
aux = data.current_point_choose_area_roi;
aux = [aux;[max([1,aux(1)-data.size_area_roi]) max([1,aux(2)-data.size_area_roi])];...
    [max([1,aux(1)-data.size_area_roi]) min([size_image(2),aux(2)+data.size_area_roi])];...
    [min([size_image(1),aux(1)+data.size_area_roi]) max([1,aux(2)-data.size_area_roi])];...
    [min([size_image(1),aux(1)+data.size_area_roi]) min([size_image(2),aux(2)+data.size_area_roi])]];
axes(data.handles.drawing_figure_handle)
delete(data.handles.area_roi)
data.handles.area_roi = plot(aux(:,2),aux(:,1),'+y','markerSize',6);
if  ~isequal(data.mode,'Linescan') && ~isequal(data.mode,'freehand')
    axes(data.handles.large_proj_axes)
    delete(data.handles.area_roi_p)
    data.handles.area_roi_p = plot(aux(:,2),aux(:,1),'+y','markerSize',6);
end
