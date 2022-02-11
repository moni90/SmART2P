function flag = is_in(target,hull)
%determine if a target point is within a convex hull
%points is a vector p*2
target = flip(target);
hull = hull(1:end-1,:);
edge = zeros(1,size(hull,1));
flag = 1;
for i = 1:size(hull,1)
    if i==1
        cos_target = (target-hull(i,:))*(hull(end,:)-hull(i,:))';
        cos_target = cos_target/(sqrt(sum((target-hull(i,:)).^2))*sqrt(sum((hull(end,:)-hull(i,:)).^2)));
        cos_side = (hull(i+1,:)-hull(i,:))*(hull(end,:)-hull(i,:))';
        cos_side = cos_side/(sqrt(sum((hull(i+1,:)-hull(i,:)).^2))*sqrt(sum((hull(end,:)-hull(i,:)).^2)));
        if cos_side>=0 && cos_target<cos_side
            flag = 0;
            break
        elseif cos_side<0 && cos_target<cos_side
            flag = 0;
            break
        end
    elseif i==size(hull,1)
        cos_target = (target-hull(i,:))*(hull(i-1,:)-hull(i,:))';
        cos_target = cos_target/(sqrt(sum((target-hull(i,:)).^2))*sqrt(sum((hull(i-1,:)-hull(i,:)).^2)));
        cos_side = (hull(1,:)-hull(i,:))*(hull(i-1,:)-hull(i,:))';
        cos_side = cos_side/(sqrt(sum((hull(1,:)-hull(i,:)).^2))*sqrt(sum((hull(i-1,:)-hull(i,:)).^2)));
        if cos_side>=0 && cos_target<cos_side
            flag = 0;
            break
        elseif cos_side<0 && cos_target<cos_side
            flag = 0;
            break
        end
    else
        cos_target = (target-hull(i,:))*(hull(i-1,:)-hull(i,:))';
        cos_target = cos_target/(sqrt(sum((target-hull(i,:)).^2))*sqrt(sum((hull(i-1,:)-hull(i,:)).^2)));
        cos_side = (hull(i+1,:)-hull(i,:))*(hull(i-1,:)-hull(i,:))';
        cos_side = cos_side/(sqrt(sum((hull(i+1,:)-hull(i,:)).^2))*sqrt(sum((hull(i-1,:)-hull(i,:)).^2)));        
        if cos_side>=0 && cos_target<cos_side
            flag = 0;
            break
        elseif cos_side<0 && cos_target<cos_side
            flag = 0;
            break
        end
        
    end
end

end