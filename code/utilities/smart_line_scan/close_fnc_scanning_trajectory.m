function close_fnc_scanning_trajectory(src,~)
%this function closes the figure used for drawing ROIs and obtains the
%inside of the ROIs using the function relleno (line 646). It also calls
%build_samples if the user wants to add the ROIs to the samples.
global data
global help_win

try
    close(help_win)
catch   
end
clearvars -global help_win

set(src,'WindowButtonUpFcn','')
set(src,'WindowButtonDownFcn','')
delete(gcf)
if ispc
    save_dir = [data.path 'SLS_trajectory\'];
else
    save_dir = [data.path 'SLS_trajectory/'];
end
if ~exist(save_dir)
    mkdir(save_dir);
end

save_SLS_trajectory(data,save_dir)