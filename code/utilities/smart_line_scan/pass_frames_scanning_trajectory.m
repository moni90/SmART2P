function pass_frames_scanning_trajectory(~,evnt)
%this functions allows the user to pass the different frames of the movie
%in order to best choose the ROIs.
global data
if evnt.VerticalScrollCount > 0
    data.scan_margin_extra_pixels = max(0,data.scan_margin_extra_pixels-1);
elseif evnt.VerticalScrollCount < 0
    data.scan_margin_extra_pixels = data.scan_margin_extra_pixels+1;
end
if isfield(data.handles,'scan_extra_pixels')
    delete(data.handles.scan_extra_pixels)
end
data = select_surround_px(data,data.scan_margin_extra_pixels);
aux = unique([data.scan_traj'; data.scan_extra_pixels],'rows');
title(['Trajectory length = ' num2str(size(aux,1)) ' (a.u.)'])

data.handles.scan_extra_pixels = plot(data.scan_extra_pixels(:,2),data.scan_extra_pixels(:,1),'+','color','y');
