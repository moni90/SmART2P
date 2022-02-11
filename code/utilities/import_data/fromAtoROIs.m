function data = fromAtoROIs(data,min_thr)

if nargin<2
    min_thr = 0;
end

data.roi = zeros(1,2,1);
data.rois_inside = zeros(1,2,1);
data.rois_centres = zeros(1,2);
for ind_n=1:size(data.A,2)
    
    A_temp = full(reshape(data.A(:,ind_n),data.linesPerFrame,data.pixels_per_line));
    A_temp = A_temp(:);
    [temp,ind] = sort(A_temp(:).^2,'ascend');
    temp =  cumsum(temp);
    ff = find(temp > min_thr,1,'first');
    
    fp = find(A_temp >= A_temp(ind(ff)));
    [ii,jj] = ind2sub([data.linesPerFrame,data.pixels_per_line],fp);
    CR{ind_n,1} = [jj,ii];
    CR{ind_n,2} = A_temp(fp)';
    
    data.rois_inside(ind_n,:,1:size(CR{ind_n,1},1)) = flip(CR{ind_n,1}');
    data.rois_centres(ind_n,:) = flip(mean(CR{ind_n,1},1));
    data.some_drawing_done = 1;
        
    size_image = size(data.CNimage);
    silueta = zeros(size_image);
    aux_1D = twoD_to_oneD(size_image(1),flip(CR{ind_n,1}')');
    silueta(aux_1D) = 1;
    [a,b] = gradient(silueta);
    [ai aj] = find(a); %#ok<NCOMMA>
    [bi bj] = find(b); %#ok<NCOMMA>
    result = union([ai aj],[bi bj],'rows');
    data.roi(ind_n,:,1:size(result,1)) = result';
    data.numero_puntos(ind_n) = length(fp);
    
end
