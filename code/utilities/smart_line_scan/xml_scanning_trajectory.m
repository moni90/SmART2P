function xml_scanning_trajectory(path,saving_name)
if nargin==0
    close all
    num_points = 50;
    total_num_points = 512;
    step = 1;
    type = 'diag';
    factor = 1;
    
    traj = fopen(['C:\Users\neural\Desktop\data\ETIC\ETIC\data for smart-lineScan\' type '_numPoints_' num2str(num_points) '_totNumPoints_' num2str(total_num_points)  '_step_' num2str(step) '_factor_' num2str(factor) '.xml'],'w');
    
    if isequal(type,'corner')
        aux = 1:step:num_points;
        path = [aux;num_points*ones(1,numel(aux))];
        aux = num_points-step:-step:1;
        path = [path [num_points*ones(1,numel(aux));aux]];%/(2*total_num_points);
    elseif isequal(type,'vert')
        path = 1:step:num_points;
        path = [num_points*ones(1,numel(path));path];%/(2*total_num_points);
    elseif isequal(type,'diag')
        path = 1:step:num_points;
        path = [path;path/factor];%/(2*total_num_points);
    elseif isequal(type,'curve')
        path = 1:step:total_num_points;
        path = [path;((path-num_points)/10).^2];%/(2*total_num_points);
    elseif isequal(type,'spiral')
        path = 1:step:8*num_points;
        path = 2*pi*path/num_points;
        decrease = 1-1/(8*num_points/step):-1/(8*num_points/step):0;
        path = [((sin(path).*decrease+1)*0.25);((cos(path).*decrease+1)*0.25)];
    elseif isequal(type,'snake')
        aux = 1:step:num_points;
        path = [aux;num_points*ones(1,numel(aux))];
        aux = num_points-step:-step:1;
        path = [path [num_points*ones(1,numel(aux));aux]];%/(2*total_num_points);
        aux = num_points+step:step:2*num_points;
        path = [path [aux;ones(1,numel(aux))]];%/(2*total_num_points);
        aux = 1+step:step:num_points;
        path = [path [2*num_points*ones(1,numel(aux));aux]];%/(2*total_num_points);
    elseif isequal(type,'corner_diag')
        aux = 1:step:num_points;
        path = [aux;aux/factor];%/(2*total_num_points);
        aux = 1:step:num_points;
        path = [path [aux+num_points;aux(end:-1:1)/factor]];%/(2*total_num_points);
    end
    distancias = sqrt(diff(path(1,:)).^2 + diff(path(2,:)).^2);
    if nnz(distancias<1)>0
        keyboard
    end
    distancia = sum(distancias);
    if ~isequal(type,'spiral')
        path = path/total_num_points;
    end
    
    h1 = figure;
    hold on
    plot([0 1],[0 0],'c')
    plot([0 1],[1 1],'c')
    plot([0 0],[0 1],'c')
    plot([1 1],[0 1],'c')
    plot(path(1,:),path(2,:),'+')
    axis([-0.1 1.1 -0.1 1.1])
    title(['num points: ' num2str(distancia)])
    saveas(h1,['C:\Users\neural\Desktop\data\ETIC\ETIC\data for smart-lineScan\' type '_numPoints_' num2str(num_points) '_totNumPoints_' num2str(total_num_points)  '_step_' num2str(step) '_factor_' num2str(factor)],'png')
else
    traj = fopen([saving_name '.xml'],'w');
end
fprintf(traj,'<?xml version="1.0" encoding="utf-8"?> \n');
fprintf(traj,'<PVLinescanDefinition mode="freeHand"> \n');
for ind_p=1:size(path,2)
    fprintf(traj,['<PVFreehand x="' num2str(path(2,ind_p)) '" y="' num2str(path(1,ind_p)) '" /> \n']);
end
fprintf(traj,'</PVLinescanDefinition> \n');
fclose(traj);
end