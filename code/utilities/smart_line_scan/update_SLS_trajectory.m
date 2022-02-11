function data = update_SLS_trajectory(data)

data.scan_traj = unique([data.scan_traj'; data.scan_extra_pixels],'rows','stable');

%calculate the shortest path visiting all neurons
aux = twoD_to_oneD(data.linesPerFrame,data.scan_traj);
traj_tags = data.scan_neuron_tag_all_pixels(aux);
data.scan_traj = group_pixels_and_calculate_shortest_path(data.scan_traj,traj_tags)';