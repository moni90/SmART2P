function twoD_coord = oneD_to_twoD(size_mat,oneD_coord)

twoD_coord = zeros(numel(oneD_coord),2);
 twoD_coord(:,2) = floor((1/size_mat)*(oneD_coord-1))+1;
 twoD_coord(:,1) = mod(oneD_coord-1,size_mat) +1; 
 
end