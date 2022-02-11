function [scan_traj, neurons_tags, data] = build_SLS_trajectory(data,traj_choice)

data.traj_choice = traj_choice;
[scan_traj, neurons_tags] = build_scan_trajectory(data.numero_neuronas,data.rois_centres,data.rois_inside,data.traj_choice);

data.scan_traj = scan_traj;
%here I calculate distances from all points to the scan trajectory. I have
%changed this so it matches with the transformation done by twoD_to_oneD
[aux1, aux2] =  meshgrid(1:data.pixels_per_line,1:data.linesPerFrame);
all_pixels = [aux2(:) aux1(:)];
data.scan_distances_to_trajectory = zeros(1,size(all_pixels,1));
data.scan_neuron_tag_all_pixels = zeros(1,size(all_pixels,1));
for ind_sc=1:size(all_pixels,1)
    [data.scan_distances_to_trajectory(ind_sc),index] =...
        min(sqrt((all_pixels(ind_sc,1)-data.scan_traj(1,:)).^2 + (all_pixels(ind_sc,2)-data.scan_traj(2,:)).^2));
    %here we get as well the tag of each pixels to quickly assign tags to
    %any trajectory
    data.scan_neuron_tag_all_pixels(ind_sc) = neurons_tags(index);
end