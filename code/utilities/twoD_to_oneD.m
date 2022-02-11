function oneD_coord = twoD_to_oneD(size_mat,twoD_coord)
%size_mat is the number of lines
    oneD_coord = (twoD_coord(:,2)-1)*size_mat+twoD_coord(:,1);
end