function m_scanning_trajectory(path,lines_per_frame, pixels_per_line, save_dir, save_name)

%save trajectory for scanimage
scan_traj_all_pixels_ScanImage0(1,:) = path(1,:);
scan_traj_all_pixels_ScanImage0(2,:) = path(2,:);
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
scan_traj_all_pixels_ScanImage(1,:) = scan_traj_all_pixels_ScanImage(1,:)/(lines_per_frame/2) -1;
scan_traj_all_pixels_ScanImage(2,:) = scan_traj_all_pixels_ScanImage(2,:)/(pixels_per_line/2) -1;
n_px = size(scan_traj_all_pixels_ScanImage,2);
% save_name = ['sls_trajectory_npx_' num2str(n_px) '_' file_name];
export_traj_scanimage(save_dir, save_name, scan_traj_all_pixels_ScanImage);
