function manual_drawing()
% function to draw manually ROIs on the FOV
global data;

%prepare projections for drawing
data.avg_proj = reshape(data.movie_doc.avg_proj',data.linesPerFrame,...
    data.pixels_per_line,[]);
data.DR_proj = reshape(data.movie_doc.DR_proj',data.linesPerFrame,...
    data.pixels_per_line,[]);
data.large_proj = data.DR_proj;
if data.average_window_choose_roi_current>1
    data.selected_proj = 'DR';
else
    data.selected_proj = 'AVG';
end
data.current_stack_p = 1;

s = findobj(data.handles.axes_handles_imagen,'type','line');
if ~isempty(s)
    delete(s)
end
s = findobj(data.handles.axes_handles_activity,'type','line');
if ~isempty(s)
    delete(s)
end
tam_screen = get(0,'ScreenSize');
%this is the figure in which ROIs will be drawn.
%user can draw ROIs in 2 ways:
%1. right click to draw a box, wheel scroll to adjust box size, left click
%to confirm box size, wheel scroll to select pixels, left click to confirm
%2. left click to draw a ROI, left click to confirm ROI, wheel scroll to
%select pixels, left click to confirm
%right click to undo ROI drawing at any step
%legend for user
% message = {'SHORTCUTS','1: DR projection', '2: AVG projection', 'C: correlation projection',...
%     'A: AVG (large)', 'X: DR (large)', 'A+spacebar: AVG all', 'X+spacebar: DR all',...
%     'arrows: Change contrast','H: Hide/show ROIs'};
% f = msgbox(message,'Help','help');

figure('WindowButtonDownFcn',@wbdcb,'CloseRequestFcn',@close_fnc,...
    'WindowScrollWheelFcn',@pass_frames,'WindowKeyPressFcn',@average_on,...
    'OuterPosition',[10 10 tam_screen(3) tam_screen(4)]);

help_button = uicontrol('Parent',gcf,'Style','pushbutton','String','HELP',...
    'Units','normalized','Position',[0.01 0.95 0.05 0.04]);%,'Visible','on');
help_button.Callback = @help_window_show;

%small square for DR projection
DR_proj_axes = axes('Units','normalized', ...
    'Position',[0.03 0.1 0.2 0.25], ...
    'XTickLabel','', ...
    'YTickLabel','');
data.imDR = imagesc(data.DR_proj(:,:,data.current_stack_p));
axis image
if data.average_window_choose_roi_current > 1
    title(['1. DR proj ', ...
        num2str(1+(data.current_stack_p-1)*data.average_window_choose_roi_current) ,...
        ' - ', ...
        num2str(min(data.duration,(data.current_stack_p)*data.average_window_choose_roi_current))]);
else
    title(['1. AVG proj ', ...
        num2str(1+(data.current_stack_p-1)*data.average_window_choose_roi_current) ,...
        ' - ', ...
        num2str(min(data.duration,(data.current_stack_p)*data.average_window_choose_roi_current))]);
end
colormap(gray);
data.handles.DR_proj_axes = DR_proj_axes;

%small square for average projection
avg_proj_axes = axes('Units','normalized', ...
    'Position',[0.25 0.1 0.2 0.25], ...
    'XTickLabel','', ...
    'YTickLabel','');
data.imavg = imagesc(data.avg_proj(:,:,data.current_stack_p));
axis image
title(['2. AVG proj ', ...
    num2str(1+(data.current_stack_p-1)*data.average_window_choose_roi_current) ,...
    ' - ', ...
    num2str(min(data.duration,(data.current_stack_p)*data.average_window_choose_roi_current))]);
colormap(gray)
data.handles.avg_proj_axes = avg_proj_axes;

%large square for selected projection
large_proj_axes = axes('Units','normalized', ...
    'Position',[0.03 0.4 0.4 0.55], ...
    'XTickLabel','', ...
    'YTickLabel','');
data.imlarge = imagesc(data.large_proj(:,:,data.current_stack_p));
axis image
title([data.selected_proj, ' proj ', ...
    num2str(1+(data.current_stack_p-1)*data.average_window_choose_roi_current) ,...
    ' - ', ...
    num2str(min(data.duration,(data.current_stack_p)*data.average_window_choose_roi_current))]);
colormap(gray)
hold on;
for ind_n=1:data.numero_neuronas
    roi_dots = squeeze(data.roi(ind_n,:,:));
    roi_dots(:,roi_dots(1,:)==0) = [];
    data.line_handles_p(ind_n,:) = plot(roi_dots(2,:),roi_dots(1,:),'.','markersize',4,'color',data.colores(ind_n,:));
    centro = data.rois_centres(ind_n,:);
    plot(centro(2),centro(1),'+','color',data.colores(ind_n,:));
end
data.handles.large_proj_axes = large_proj_axes;

%small square for fluorescence or calcium trace of selected pixels
wholeTrace_axes = axes('Units','normalized', ...
    'Position',[0.5 0.1 0.2 0.15], ...
    'XTickLabel','', ...
    'YTickLabel','');
wholeTrace_axes.XLabel.String = 'Time (frames)';
wholeTrace_axes.YLabel.String = 'Fluo (a.u.)';
wholeTrace_axes.Title.String = 'Raw fluorescence';
% xlabel('Time (frames)'); ylabel('Fluo');
% title('Fluo trace');
data.handles.whole_trace_axes = wholeTrace_axes;

%small square for SNR trace of selected pixels
SNR_axes = axes('Units','normalized', ...
    'Position',[0.75 0.1 0.2 0.15], ...
    'XTickLabel','', ...
    'YTickLabel',''); 
SNR_axes.XLabel.String = 'Num of pixels';
SNR_axes.YLabel.String = 'SNR (a.u.)';
SNR_axes.Title.String = 'ROI SNR';
% xlabel('Num of pixels'); ylabel('SNR');
% title('ROI SNR');
data.handles.SNR_axes = SNR_axes;

%large square for single frame TSeries visualization
fov_axes = axes('Units','normalized', ...
    'Position',[0.5 0.3 0.45 0.65], ...
    'XTickLabel','', ...
    'YTickLabel','');
data.handles.drawing_figure_handle = fov_axes;
%I keep the handle of the image because I will need it later
% set(data.handles.axes_handles_imagen,'XTick',[],'YTick',[])
data.imagesc = imagesc(data.imagen);

colorbar
data.caxis = caxis;
hold on
if isfield(data,'auto_init') && data.auto_init == 1
    data.some_drawing_done = 1;
    data.auto_init = 0;
else
    data.some_drawing_done = 0;
end
data.numero_puntos_ellipse = 0;
axis image
colormap(gray)
hold on
title([num2str(data.frame_plot) '   ' data.average_slash_max ' frames:' num2str(data.current_stack(1)) '-' num2str(data.current_stack(end))])
for ind_n=1:data.numero_neuronas
    roi_dots = squeeze(data.roi(ind_n,:,:));
    roi_dots(:,roi_dots(1,:)==0) = [];
    data.line_handles(ind_n,:) = plot(roi_dots(2,:),roi_dots(1,:),'.','markersize',4,'color',data.colores(ind_n,:));
    centro = data.rois_centres(ind_n,:);
    plot(centro(2),centro(1),'+','color',data.colores(ind_n,:));
end
