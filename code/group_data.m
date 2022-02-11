function  [x_m,y_m,y_sem] = group_data(xx,yy,n_trials)

n_groups = floor(length(xx)/n_trials);
x_m = NaN*ones(n_groups,1);
y_m = NaN*ones(n_groups,1);
y_sem = NaN*ones(n_groups,1);

[xx_sort, ind_sort] = sort(xx);
yy_sort = yy(ind_sort);

for i = 1:n_groups
    if i == n_groups
        xx_temp = xx_sort((i-1)*n_trials+1:end);
        yy_temp = yy_sort((i-1)*n_trials+1:end);
    else
        xx_temp = xx_sort((i-1)*n_trials+1:min(i*n_trials,length(xx)));
        yy_temp = yy_sort((i-1)*n_trials+1:min(i*n_trials,length(yy)));
    end
    x_m(i) = nanmean(xx_temp);
    y_m(i) = nanmean(yy_temp);
    y_sem(i) = nanstd(yy_temp)/sum(1-isnan(yy_temp));
end

