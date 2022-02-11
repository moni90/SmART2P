function data = onlyOptimizeSNR(data)

fig_processing = uifigure;
d = uiprogressdlg(fig_processing,'Title','Optimizing SNR',...
    'Indeterminate','on');
drawnow
                
Y = data.movie_doc.movie_ruido;
Y = Y';
%transform select ROIs in a matrix format
A = fromManualToMatrix(data.rois_inside,data.roi,...
    data.pixels_per_line, data.linesPerFrame, data.numero_neuronas,Y,data.framePeriod);
%select only pixels maximizing SNR
A_SNR = reduce_px_SNR(full(A),Y,data.framePeriod);
data.A = A_SNR;
data = fromAtoROIs(data);

close(d)
close(fig_processing);
end


