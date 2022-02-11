function [choice,tform, Arot, CNtransformed] = perform_alignment(CN_ROIs,CNpad,A_ROIs,optimizer,metric)

tform = imregtform(CN_ROIs,CNpad,'rigid',optimizer,metric);
RefImage = imref2d(size(CNpad));
CNtransformed = imwarp(CN_ROIs,tform,'OutputView',RefImage);

%transform each ROI with the estimated motion
Aref = imref2d(size(CN_ROIs));
Arot = zeros(size(CN_ROIs,1)*size(CN_ROIs,2),size(A_ROIs,2));
for i = 1:size(A_ROIs,2)
    A1 = reshape(full(A_ROIs(:,i)),size(CN_ROIs,1),[]);
    A1rot = imwarp(A1,tform,'OutputView',Aref);
    Arot(:,i) = A1rot(:);
end
tam_screen = get(0,'ScreenSize');
alignment = figure('Position',[150 150 tam_screen(3)-300 tam_screen(4)-300]);
plot_contours(Arot,CN_ROIs,[],0);%plot_contours_monocromatic(Arot,CN,[],0);
colormap('gray');
choice = questdlg('Would you like to keep these ROIs?', ...
    'Keep ROIs', ...
    'Yes, with fit','Yes','No','Yes');
close(alignment);
% toc