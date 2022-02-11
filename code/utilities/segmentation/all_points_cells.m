function data_aux = all_points_cells(data_aux)
%this function put together all pixels contained in all neurons. This
%function is called by ROIs.m
data_aux.all_points_cells = [];
for ind_n=1:data_aux.numero_neuronas
    %take the roi info and remove the zeros
    a = squeeze(data_aux.rois_inside(ind_n,:,:));
    a(:,a(1,:)==0) = [];
    a = unique(a','rows');
    data_aux.all_points_cells = [data_aux.all_points_cells; a];
end
end