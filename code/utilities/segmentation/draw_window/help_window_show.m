function help_window_show(src,event)

global help_win

try
    figure(help_win)
catch
    message = {'SHORTCUTS','1: DR projection', '2: AVG projection', 'C: correlation projection',...
        'A: AVG (large)', 'X: DR (large)', 'A+spacebar: AVG all', 'X+spacebar: DR all',...
        'arrows: Change contrast','H: Hide/show ROIs'};
    help_win = msgbox(message,'Help','help');%,'modal');
end

end