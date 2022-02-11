function [] = export_traj_scanimage(save_path, save_name, path)

traj = fopen([save_path save_name '.m'],'w');

%headline
fprintf(traj,['function [xx,yy] = ' save_name '(tt,varargin) \n']);
fprintf(traj,'\n');
fprintf(traj,'xx = nan(size(tt)); \n');
fprintf(traj,'yy = nan(size(tt)); \n');

for ind_p=1:size(path,2)
    fprintf(traj,['xx(' num2str(ind_p) ') = ' num2str(path(2,ind_p)) '; ']);
    fprintf(traj,['yy(' num2str(ind_p) ') = ' num2str(path(1,ind_p)) '; \n']);
end

fprintf(traj,'end \n');
fclose(traj);