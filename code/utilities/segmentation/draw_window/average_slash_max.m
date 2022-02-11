function imagen = average_slash_max(mat)
global data
if isequal(data.average_slash_max,'DR') && size(mat,1)==data.duration
    imagen = max(mat,[],1)-min(mat,[],1);
else
    imagen = mean(mat,1);
end