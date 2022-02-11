function wbmcb(~,~)
%in this function we save the movements of the mouse on the figure as the
%ROI the user wants to draw.
global data
cp = get(gca,'CurrentPoint');
%increment number of points
data.numero_puntos_ellipse =...
    data.numero_puntos_ellipse + 1;
%add point to the ellipse
data.ellipse(:,data.numero_puntos_ellipse) =...
    round([cp(1,2),cp(1,1)]');
%plot the point and keep its handle so we can delete it if necessary
hold on
h1 = plot(round(cp(1,1)),round(cp(1,2)),'.');
title([num2str(cp(1,1)) '-' num2str(cp(1,2))])
data.handles.ellipse_handles(data.numero_puntos_ellipse) = h1;
drawnow