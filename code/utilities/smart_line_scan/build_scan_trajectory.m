function [scan_traj, neurons_tags] = build_scan_trajectory(num_neurons,centres,insides,choice)
step = 0;
num_pix_path = 40;%(only for fit) number of points that will be input to polyval
mat_num_pixels = zeros(2,num_neurons);
neurons_left = 1:num_neurons;
scan_traj = [];
last_point = [0;0];
for ind_n=1:num_neurons
    %find next neuron
    distancias = sqrt((last_point(1)-centres(neurons_left,1)).^2 + (last_point(2)-centres(neurons_left,2)).^2);
    [~,ind_dist] = min(distancias);
    %find farthest points
    roi_dots = squeeze(insides(neurons_left(ind_dist),:,:));
    roi_dots(:,roi_dots(1,:)==0) = [];
    dots_to_use = roi_dots;
    mat_num_pixels(1,neurons_left(ind_dist)) = size(dots_to_use,2);
    
    %all pixels
    if isequal(choice,'half of the pixels')
        path_neuron = dots_to_use;
        distancias = sqrt((last_point(1)-path_neuron(1,[1,size(path_neuron,2)])).^2 + (last_point(2)-path_neuron(2,[1,size(path_neuron,2)])).^2);
        if distancias(1)>distancias(2)
            path_neuron = path_neuron(:,end:-1:1);
        end
        x = last_point;
        y = path_neuron(:,1);
        if abs(x(1)-y(1))>abs(x(2)-y(2))
            t = min([x(1),y(1)]):step:max([x(1),y(1)]);
            line_aux = (y(2)-x(2))*(t-x(1))/(y(1)-x(1))+x(2);
        else
            line_aux = min([x(2),y(2)]):step:max([x(2),y(2)]);
            t = (y(1)-x(1))*(line_aux-x(2))/(y(2)-x(2))+x(1);
        end
        if any(last_point~=[0;0])
            scan_traj = [scan_traj [t;line_aux] path_neuron]; %#ok<AGROW>
            neurons_tags = [neurons_tags zeros(1,numel(t)) neurons_left(ind_dist)*ones(1,size(path_neuron,2))]; %#ok<AGROW>
        else
            scan_traj = path_neuron;
            neurons_tags = neurons_left(ind_dist)*ones(1,size(path_neuron,2));
        end
        last_point = scan_traj(:,end);
    else
        dots_hr_1 = min(dots_to_use(1,:))+(max(dots_to_use(1,:))-min(dots_to_use(1,:)))/num_pix_path:(max(dots_to_use(1,:))-min(dots_to_use(1,:)))/num_pix_path:max(dots_to_use(1,:));
        [p,s1] = polyfit(dots_to_use(1,:),dots_to_use(2,:),2);
        y2 = polyval(p,dots_hr_1);
        dots_hr_2 = min(dots_to_use(2,:))+(max(dots_to_use(2,:))-min(dots_to_use(2,:)))/num_pix_path:(max(dots_to_use(2,:))-min(dots_to_use(2,:)))/num_pix_path:max(dots_to_use(2,:));
        [p,s2] = polyfit(dots_to_use(2,:),dots_to_use(1,:),2);
        
        y1 = polyval(p,dots_hr_2);
        
        %choose the best fit
        if s1.normr<s2.normr
            path = [dots_hr_1; y2];
            mat_num_pixels(2,neurons_left(ind_dist)) = numel(unique(dots_to_use(1,:)));
        else
            path = [y1; dots_hr_2];
            mat_num_pixels(2,neurons_left(ind_dist)) = numel(unique(dots_to_use(2,:)));
        end
        distancias = sqrt((last_point(1)-path(1,[1,size(path,2)])).^2 + (last_point(2)-path(2,[1,size(path,2)])).^2);
        if distancias(1)>distancias(2)
            path = path(:,end:-1:1);
        end
        x = last_point;
        y = path(:,1);
        if abs(x(1)-y(1))>abs(x(2)-y(2))
            t = min([x(1),y(1)]):step:max([x(1),y(1)]);
            line_aux = (y(2)-x(2))*(t-x(1))/(y(1)-x(1))+x(2);
        else
            line_aux = min([x(2),y(2)]):step:max([x(2),y(2)]);
            t = (y(1)-x(1))*(line_aux-x(2))/(y(2)-x(2))+x(1);
        end
        if any(last_point~=[0;0])
            scan_traj = [scan_traj [t;line_aux] path]; %#ok<AGROW>
            neurons_tags = [neurons_tags zeros(1,numel(t)) neurons_left(ind_dist)*ones(1,size(path,2))]; %#ok<AGROW>
        else
            scan_traj = path;
            neurons_tags = neurons_left(ind_dist)*ones(1,size(path,2));
        end
        last_point = scan_traj(:,end);
    end
    %remove neuron from pool
    neurons_left(ind_dist) = [];
end
if isequal(choice,'fit')
    scan_traj = round(scan_traj);
end
