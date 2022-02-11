function data = add_box(data,cp,size_box)

aux = cp;
[aux1, aux2] = meshgrid(max([1,aux(1)-size_box]):min([data.linesPerFrame,aux(1)+size_box]),...
    max([1,aux(2)-size_box]):min([data.pixels_per_line,aux(2)+size_box]));

data.scan_traj = [data.scan_traj [aux1(:) aux2(:)]'];
data.scan_traj = unique(data.scan_traj','rows','stable')';