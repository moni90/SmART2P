function help_window_SLS_show(src,event)

global help_win

try
    figure(help_win)
catch
    message = {'HELP', '1. Scroll mouse wheel to increase/decrease surround. Left click to confirm.',...
        '2. Left click to select reference box position.',...
        '3. Scroll mouse to set reference box size. (Right click to undo).',...
        '4. Left click to confirm reference box size and position.',...
        '5. Close window to save SLS trajectory and references'};
    help_win = msgbox(message,'Help','help');
end

end