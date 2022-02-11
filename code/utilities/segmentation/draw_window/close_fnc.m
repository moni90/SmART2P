function close_fnc(src,~)
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
set(src,'WindowButtonMotionFcn','')
set(src,'WindowButtonDownFcn','')
delete(gcf)
if data.some_drawing_done
        choice = questdlg('Would you like to get denoised and demixed calcium traces?', ...
            'Calcium activity', ...
            'Yes','No','Yes');
        % Handle response
        switch choice
            case 'Yes'
                data.CNMF = 1;
                fig_processing = uifigure;
                d = uiprogressdlg(fig_processing,'Title','Denoising and deconvolving traces',...
                    'Indeterminate','on');
                drawnow
                data = onlyTemporal(data);               
                close(d)
                close(fig_processing)
                data = fluorescence(data);
                data = deal_with_new_rois(data);
            case 'No'
                data.CNMF = 0;
                data.A = fromManualToMatrix(data.rois_inside,...
                    data.roi,data.pixels_per_line,...
                    data.linesPerFrame, data.numero_neuronas,...
                    data.movie_doc.movie_ruido', data.framePeriod);
                data = fluorescence(data);
                data = deal_with_new_rois(data);
        end
%     end
end
data.some_drawing_done = 0;
