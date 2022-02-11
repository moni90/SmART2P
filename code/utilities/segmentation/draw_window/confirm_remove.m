function confirm_remove(src,~)
%confirm removal of ROI. left click to remove a ROI, right click to
%deselect chosen ROI
global data

if strcmp(get(src,'SelectionType'),'alt')
    set(src,'WindowButtonDownFcn',@wbdcb)
    data = rmfield(data,'remove_rois');
elseif strcmp(get(src,'SelectionType'),'normal')
    set(src,'WindowButtonDownFcn',@wbdcb)
    data = reset_data(data,data.remove_rois);
    
    update_listbox(data.numero_neuronas)
end
%visually deselect ROI
s = findobj(data.handles.drawing_figure_handle,'color',[1 0 0]);
if ~isempty(s)
    delete(s)
end
s = findobj(data.handles.large_proj_axes,'color',[1 0 0]);
if ~isempty(s)
    delete(s)
end
