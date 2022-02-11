function [patch_interp, ref_box_fig] = find_ref_box(movie, scan_traj)

length_traj = min(size(scan_traj,2),2000);

x_0 = scan_traj(1,end);
y_0 = scan_traj(2,end);
%seelct last part of the trajectory
traj_x = scan_traj(1,end:-1:end-length_traj);
traj_y = scan_traj(2,end:-1:end-length_traj);
%plot trajectory to make sure it is the patch
ref_box_fig = figure;
scatter(traj_x,traj_y);

%look for box size
if traj_x(2)-traj_x(1)==0
    sign_y = traj_y(2)-traj_y(1);
    d_x = diff(traj_x) == 0;
    up = find(diff(d_x)==1);
    sign_x = traj_x(up(1)+1)-traj_x(1);
    down = [-1 find(diff(d_x)==-1)];
    [box_edge, id_edge] = max(up(1:min([length(up) length(down) 5])) - down(1:min([length(up) length(down) 5]))); 
    box_size = abs(traj_y(up(id_edge)+1)-traj_y(down(id_edge))+1)+4;
%     box_edge = find(diff(traj_x)~=0,1)+1;
%     box_size = abs(traj_y(box_edge)-traj_y(1))+1; %add 1 to have some margin
elseif traj_y(2)-traj_y(1)==0
    sign_x = traj_x(2)-traj_x(1);
    d_y = diff(traj_y) == 0;
    up = find(diff(d_y)==1);
    sign_y = traj_y(up(1)+1)-traj_y(1);
    down = [-1 find(diff(d_y)==-1)];
    [box_edge, id_edge] = max(up(1:min([length(up) length(down) 5])) - down(1:min([length(up) length(down) 5]))); 
    box_size = abs(traj_x(up(id_edge)+1)-traj_x(down(id_edge))+1)+4;
%     box_edge = find(diff(traj_y)~=0,1)+1;
%     box_size = abs(traj_x(box_edge)-traj_x(1))+1; %add 1 to have some margin
end

id_box1 = find(((abs(traj_x-x_0)<=box_size) + (abs(traj_y-y_0)<=box_size))==2);
id_box2 = find((((traj_x-x_0)*sign_x>=0) + ((traj_y-y_0)*sign_y>=0))==2);
id_box = intersect(id_box1, id_box2);
id_cut = find(diff(id_box)>1);
if ~isempty(id_cut)
    id_box = id_box(1:id_cut);
end
traj_x = traj_x(id_box);
traj_y = traj_y(id_box);
hold on; scatter(traj_x,traj_y,'.');


patch_activity = movie(:,end-length(traj_x)+1:end)';
patch_interp = interp2d(patch_activity,traj_x,traj_y,box_edge);
