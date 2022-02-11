function [] = build_projections()
%this function buils the avg and DR projections used for the segmentation
global data;

%create stack with grouped frames
Ystack = zeros(ceil(size(data.movie_doc.movie_ruido,1)/data.average_window_choose_roi_current),...
    data.average_window_choose_roi_current,...
    size(data.movie_doc.movie_ruido,2));

for iii=1:size(Ystack,1)
    if min(iii*data.average_window_choose_roi_current,size(data.movie_doc.movie_ruido,1))...
            -(iii-1)*data.average_window_choose_roi_current == data.average_window_choose_roi_current
        Ystack(iii,:,:) =...
        data.movie_doc.movie_ruido((iii-1)*data.average_window_choose_roi_current...
        + 1:min(iii*data.average_window_choose_roi_current,size(data.movie_doc.movie_ruido,1)),:);
    else
        miss = data.average_window_choose_roi_current - (min(iii*data.average_window_choose_roi_current,size(data.movie_doc.movie_ruido,1))...
            -(iii-1)*data.average_window_choose_roi_current);
        Ystack(iii,:,:) = padarray(data.movie_doc.movie_ruido((iii-1)*data.average_window_choose_roi_current...
        + 1:min(iii*data.average_window_choose_roi_current,size(data.movie_doc.movie_ruido,1)),:),...
        [miss 0],NaN,'post');
    end
end

data.movie_doc.movie_stack = Ystack;
data.movie_doc.avg_proj = squeeze(nanmean(Ystack,2));
% when the frame_period is bigger than 0.5*average_window_choose_roi DR_proj becomes a simple mean 
if  size(Ystack,2) > 1
    data.movie_doc.DR_proj = squeeze(nanmax(Ystack,[],2)-nanmin(Ystack,[],2));
else
    data.movie_doc.DR_proj = squeeze(nanmean(Ystack,2));
end
%this is to know which frames to use when showing the visual field
data.current_stack = 1:data.duration;