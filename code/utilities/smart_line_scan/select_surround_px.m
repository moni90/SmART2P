function data = select_surround_px(data,scan_margin_extra_pixels)

[aux1, aux2] =  meshgrid(1:data.pixels_per_line,1:data.linesPerFrame);
all_pixels = [aux2(:) aux1(:)];
data.scan_extra_pixels = all_pixels(data.scan_distances_to_trajectory<=scan_margin_extra_pixels,:);
