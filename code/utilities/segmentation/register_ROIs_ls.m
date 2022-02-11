function data = register_ROIs_ls(data,ROIs_ref_file)

% global data;
scan_path = data.freehand_scan(2:-1:1,:);
distancias = (sqrt(diff(scan_path(1,:)).^2 + diff(scan_path(2,:)).^2));
distancia = sum(distancias);
%ask for the ROIs reference
% [filename, pathname] = uigetfile([data.path '*.mat'], 'Select the corresponding ROIs .mat data');
figure
% if pathname~=0
    aux = load(ROIs_ref_file,'-mat');
%     aux = load([pathname filename],'-mat');
    if isfield(aux,'data')
        aux.data_reference = aux.data;
        aux = rmfield(aux,'data');
    end
    if nnz(data.reference_image)==0
        data.reference_image = aux.data_reference.reference_image;
    end
    data.roi = aux.data_reference.roi;
    data.rois_centres = aux.data_reference.rois_centres;
    data.rois_inside = aux.data_reference.rois_inside;
    data.numero_neuronas = aux.data_reference.numero_neuronas;
    %get rois
    rois_assignment = zeros(1,size(scan_path,2));
    %pixels in ROIs
    data.A = zeros(data.pixels_per_line,data.numero_neuronas);
    %pixels in surroundings
    data.surrounding = zeros(data.pixels_per_line,data.numero_neuronas);
    data.ring = zeros(data.pixels_per_line,data.numero_neuronas);
    %pixels in trajectory
    data.neuropil = zeros(data.pixels_per_line,data.numero_neuronas);
    data.CNMF = 0;
    for ind_n = 1:aux.data_reference.numero_neuronas
        roi_dots = squeeze(aux.data_reference.rois_inside(ind_n,:,:));
        %                 roi_dots = [roi_dots squeeze(aux.data_reference.roi(ind_n,:,:))];
        roi_dots(:,roi_dots(1,:)==0) = [];
        plot(roi_dots(1,:),roi_dots(2,:),'*','color',data.colores(ind_n,:))
        K = convhull(roi_dots');
        %assign pixels in the trajectory to ROIs
        for j = 1:size(scan_path,2)
            min_dist = min(sqrt((scan_path(1,j)-roi_dots(2,:)).^2 + (scan_path(2,j)-roi_dots(1,:)).^2));
            if min_dist <= 1
                rois_assignment(j)=ind_n;
                data.A(j,ind_n) = 1;
            elseif min_dist < 2
                data.ring(j,ind_n) = 1;
            elseif min_dist<=4
                if is_in(scan_path(:,j)',roi_dots(:,K)')
                    data.ring(j,ind_n) = 1;
                else
                    data.surrounding(j,ind_n) = 1;
                end
            elseif min_dist>4
                data.neuropil(j,ind_n) = 1;
            end
        end
        
    end
    %remove pixels in any ROI from neuropil
    data.neuropil(find(sum(data.A,2)>0) ,:) = 0;
    %remove pixels in any ROI from surrounding
    data.neuropil(find(sum(data.surrounding,2)>0) ,:) = 0;
    data.neuropil(find(sum(data.ring,2)>0) ,:) = 0;
    %remove pixels in any surrounding from neuropil and pixels
    %closer than 2
    data.surrounding(find(sum(data.A,2)>0) ,:) = 0;
    data.surrounding(find(sum(data.ring,2)>0) ,:) = 0;
    %remove pixels belonging to more than one ROI
    data.A( find(sum(data.A,2)>1) ,:) = 0;
    data.numero_puntos = sum(data.A>0, 1);
    title(num2str(distancia))
    data.freehand_original_size = [aux.data_reference.linesPerFrame aux.data_reference.pixels_per_line];
% else
%     warning('No reference segmentation!')
% end
imagesc(data.reference_image')
hold on
plot(scan_path(2,:),scan_path(1,:),'-','color',[1 1 0])
colormap('gray')
axis image
for ind_n=1:data.numero_neuronas
    hold on;
    plot(scan_path(2,find(data.A(:,ind_n))),scan_path(1,find(data.A(:,ind_n))),...
        '.','color','g','MarkerSize',15);
    
    if ~isempty(find(data.surrounding(:,ind_n)))
        hold on;
        plot(scan_path(2,find(data.surrounding(:,ind_n))),...
            scan_path(1,find(data.surrounding(:,ind_n))),...
            '.','color','r','MarkerSize',15);
    end
    if ~isempty(find(data.ring(:,ind_n)))
        hold on;
        plot(scan_path(2,find(data.ring(:,ind_n))),...
            scan_path(1,find(data.ring(:,ind_n))),...
            '.','color',[1 1 1],'MarkerSize',15);
    end
end
hold on;
plot(scan_path(2,find(data.neuropil(:,ind_n))),...
    scan_path(1,find(data.neuropil(:,ind_n))),...
    '.','color','b','MarkerSize',15);

save_path = fullfile(data.path, 'Analyses');
if ~exist(save_path)
    mkdir(save_path);
end
saveas(gcf,fullfile(save_path, 'SLS_pixels_to_ROI_assigment.png'));
savefig(gcf,fullfile(save_path, 'SLS_pixels_to_ROI_assigment.fig'));
close(gcf);
