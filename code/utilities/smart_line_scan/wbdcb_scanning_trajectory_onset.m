function wbdcb_scanning_trajectory_onset(src,~)
global data
set(src,'WindowButtonDownFcn',@wbdcb_scanning_trajectory)
set(src,'WindowScrollWheelFcn','')
if isfield(data.handles,'scan_extra_pixels')
    data.handles = rmfield(data.handles,'scan_extra_pixels');
end

%calculate the shortest path visiting all neurons
data = update_SLS_trajectory(data);

% data.scan_traj = shortest_path(data.scan_traj)';
s = findobj('color','y');
if ~isempty(s)
    delete(s)
end
plot(data.scan_traj(2,:),data.scan_traj(1,:),'-','color','m');
distancia =  sum(sqrt(diff(data.scan_traj(1,:)).^2 + diff(data.scan_traj(2,:)).^2));
title(['Trajectory length = ' num2str(distancia) ' (a.u.)'])