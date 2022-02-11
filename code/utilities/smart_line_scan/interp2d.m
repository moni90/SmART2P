function patch_interp = interp2d(patch_activity,traj_x,traj_y,box_edge)

xx = linspace(min(traj_x)+0e-1,max(traj_x)-0e-1,box_edge*2);
yy = linspace(min(traj_y)+0e-1,max(traj_y)-0e-1,box_edge*2);
[xxx,yyy] = meshgrid(xx,yy);
patch_interp = zeros(size(xxx,1),size(xxx,2),size(patch_activity,2));
for i_t = 1:size(patch_activity,2)
    F = scatteredInterpolant(traj_x(:),traj_y(:),patch_activity(:,i_t));%,'method','linear');%,'ExtrapolationMethod','nearest');
    F.Method = 'linear';%'nearest';%'linear';
    F.ExtrapolationMethod = 'linear';%'nearest';
    patch_interp(:,:,i_t) = F(xxx,yyy);
%     patch_interp(:,:,i_t) = griddata(traj_x,traj_y,patch_activity(:,i_t),xxx,yyy,'linear');
end

end