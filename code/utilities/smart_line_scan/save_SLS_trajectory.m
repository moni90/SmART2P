function save_SLS_trajectory(data,save_dir)

if ~exist(save_dir)
    mkdir(save_dir);
end
if isempty(data.file)
    if ispc
        ind_slash = strfind(data.path,'\');
        file_name = data.path(ind_slash(end-1)+1:end-1);
    else
        ind_slash = strfind(data.path,'/');
        file_name = data.path(ind_slash(end-1)+1:end-1);
    end
else
    file_name = data.file;
    if strfind(file_name,'.')
        id_dots = strfind(file_name,'.');
        file_name = file_name(1:id_dots(1)-1);
    end
end

%save trajectory as xml
scan_traj_all_pixels(1,:) = data.scan_traj(1,:)/data.linesPerFrame;
scan_traj_all_pixels(2,:) = data.scan_traj(2,:)/data.pixels_per_line;
distancia = sum(sqrt(diff(data.scan_traj(1,:)).^2 + diff(data.scan_traj(2,:)).^2));
xml_scanning_trajectory(scan_traj_all_pixels,[save_dir file_name '_surround_' num2str(data.scan_margin_extra_pixels)...
    '_n_' num2str(data.numero_neuronas)  '_time_' num2str(round(distancia*4.4e-3)) '_' data.traj_choice])
%save trajectory for scanimage
scan_traj_all_pixels_ScanImage0(1,:) = data.scan_traj(1,:);
scan_traj_all_pixels_ScanImage0(2,:) = data.scan_traj(2,:);
%add linear segments between ROIs
dist_px = sqrt(diff(scan_traj_all_pixels_ScanImage0(1,:)).^2 + diff(scan_traj_all_pixels_ScanImage0(2,:)).^2);
scan_traj_all_pixels_ScanImage = [];
id_lines = find(dist_px>5);
if isempty(id_lines)
    scan_traj_all_pixels_ScanImage = [scan_traj_all_pixels_ScanImage0 scan_traj_all_pixels_ScanImage0(:,1)];
else
    scan_traj_all_pixels_ScanImage = scan_traj_all_pixels_ScanImage0(:,1:id_lines(1));
    for i=1:length(id_lines)
        step = 2;
        pt0 = scan_traj_all_pixels_ScanImage0(:,id_lines(i));
        pt1 = scan_traj_all_pixels_ScanImage0(:,id_lines(i)+1);
        tg_teta = (pt1(2)-pt0(2))/(pt1(1)-pt0(1));
        n_pts = floor(sqrt(sum((pt1-pt0).^2))/step);
        for j = 1:n_pts
            if isinf(tg_teta)
                if pt1(1)<pt0(1)
                    new_pt = pt0 - [j*step; 0];
                else
                    new_pt = pt0 + [j*step; 0];
                end
            else
                dir = atan(tg_teta);
                if pt1(1)>pt0(1)
                        new_pt = pt0 + j*[cos(dir)*step; sin(dir)*step];
                else
                        new_pt = pt0 + j*[-cos(dir)*step; -sin(dir)*step];
                end
            end
            scan_traj_all_pixels_ScanImage = ...
                [scan_traj_all_pixels_ScanImage ...
                new_pt];
        end
        if i<length(id_lines)
        scan_traj_all_pixels_ScanImage = ...
            [scan_traj_all_pixels_ScanImage ...
            scan_traj_all_pixels_ScanImage0(:,id_lines(i)+1:id_lines(i+1))];
        else
            scan_traj_all_pixels_ScanImage = ...
            [scan_traj_all_pixels_ScanImage ...
            scan_traj_all_pixels_ScanImage0(:,id_lines(i)+1:end)];
        end
    end
    scan_traj_all_pixels_ScanImage = ...
            [scan_traj_all_pixels_ScanImage ...
            scan_traj_all_pixels_ScanImage0(:,1)];
end
scan_traj_all_pixels_ScanImage(1,:) = scan_traj_all_pixels_ScanImage(1,:)/(data.linesPerFrame/2) -1;
scan_traj_all_pixels_ScanImage(2,:) = scan_traj_all_pixels_ScanImage(2,:)/(data.pixels_per_line/2) -1;
n_px = size(scan_traj_all_pixels_ScanImage,2);
save_name = ['sls_trajectory_npx_' num2str(n_px) '_' file_name '_surround_' num2str(data.scan_margin_extra_pixels)...
    '_n_' num2str(data.numero_neuronas) '_' data.traj_choice];
export_traj_scanimage(save_dir, save_name, scan_traj_all_pixels_ScanImage);
%save reference rois
data_aux = data;
if isfield(data_aux,'handles')
    data_aux = rmfield(data_aux,'handles');
end
data_reference.roi = data_aux.roi;
data_reference.rois_centres = data_aux.rois_centres;
data_reference.rois_inside = data_aux.rois_inside;
data_reference.numero_neuronas = data_aux.numero_neuronas;
data_reference.linesPerFrame = data_aux.linesPerFrame;
data_reference.pixels_per_line = data_aux.pixels_per_line; 

save([save_dir file_name '_reference_surround_' num2str(data.scan_margin_extra_pixels) '_n_' num2str(data.numero_neuronas) '_time_' num2str(round(distancia*4.4e-3))],'data_reference')
if~(exist([save_dir file_name '_reference_surround_' num2str(data.scan_margin_extra_pixels) '_n_' num2str(data.numero_neuronas) '_time_' num2str(round(distancia*4.4e-3)) '.mat'],'File'))
   errordlg('Attention the trajectory was not saved properly!!!','Warning');
else
    msgbox('The trajectory and reference ROIs have been saved!','Operation completed');
end
   
%save trajectory as .mat
scan_traj = data.scan_traj; 
ref_ROIs_path = [save_dir file_name '_reference_surround_' num2str(data.scan_margin_extra_pixels) '_n_' num2str(data.numero_neuronas) '_time_' num2str(round(distancia*4.4e-3)) '.mat'];
save([save_dir file_name '_surround_' num2str(data.scan_margin_extra_pixels) '_n_' num2str(data.numero_neuronas)  '_time_' num2str(distancia*4.4e-3),...
    '.mat'],'scan_traj','ref_ROIs_path');