function path_all = group_pixels_and_calculate_shortest_path(path,tags)
%this function groups calculate each pixel centroid and call shortest_path
%to get the shortest path it can find. Then it builds the whole path by
%applying a greedy search to each neuron's pixels.
% close all
% tic
tags_unique = unique(tags);
nodes = zeros(numel(tags_unique),2);
for ind_n=1:numel(tags_unique)
    nodes(ind_n,:) = mean(path(tags==tags_unique(ind_n),:),1);
end


userConfig = struct('xy',nodes,'showProg',false,'showResult',false,'showWaitbar',false);
resultStruct = tsp_ga(userConfig);
path_neurons = resultStruct.xy(resultStruct.optRoute,:);% [path_neurons,distancia] = shortest_path(nodes);
% 
% figure
% hold on
% plot(path(:,2),path(:,1),'.')
% plot(nodes(:,2),nodes(:,1),'+')
% plot(path_neurons(:,2),path_neurons(:,1),'-')
% plot(resultStruct.xy(resultStruct.optRoute,2),resultStruct.xy(resultStruct.optRoute,1),'-')
% axis equal

%once we get the path going over all neurons, we put all pixels from all neurons together
last_point_path = [0;0];
path_all = [];
for ind_tag=1:numel(tags_unique)
    tag_aux = tags_unique(sum(abs(nodes-repmat(path_neurons(ind_tag,:),numel(tags_unique),1)),2)==0);
    nodes_group = path(tags==tag_aux,:);
    last_point = last_point_path;
    path_aux = zeros(size(nodes_group));
    pixels_left = 1:size(nodes_group,1);
    for ind_px=1:size(nodes_group,1)
        %find next neuron
        distancias = sqrt((last_point(1)-nodes_group(pixels_left,1)).^2 + (last_point(2)-nodes_group(pixels_left,2)).^2);
        [~,ind_dist] = min(distancias);
        last_point = nodes_group(pixels_left(ind_dist),:);
        path_aux(ind_px,:) = last_point;
        pixels_left(ind_dist) = [];
    end
    last_point_path = path_aux(end,:);
%     plot(path_aux(:,2),path_aux(:,1))
    path_all = [path_all;path_aux]; %#ok<AGROW>
end
% plot(path_all(:,1),path_all(:,2),'--')
end