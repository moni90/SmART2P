function [data, ind_cut, pca_motion_fig, ref_box_fig, motion_fig] = sls_large_artefacts_PCA(data, options)

[score_all, fit_all, ind_cut, pca_motion_fig] = estimate_motion_pca(data.movie_doc.movie_ruido, data.frameTimes, data.framePeriod);

if strcmp(options.ref_box, 'Yes')   
    [ref_box_movie, ref_box_fig] = find_ref_box(data.movie_doc.movie_ruido, data.freehand_scan);
    [time_down,down_rate,ref_box_movie_correct,shifts_x,shifts_y,shifts_all, motion_fig] = estimate_rigid_motion(ref_box_movie, data.framePeriod, options.down_rate);
else
    ref_box_fig = [];
    motion_fig = [];
end


if ~isempty(ind_cut)
    cut_quest_dlg = questdlg(['Do you want to cut the acquisition at the line ' num2str(ind_cut) ' out of ' num2str(size(data.movie_doc.movie_ruido,1)) '?'],...
        'Confirm large artefact','Yes','No','Yes');
    switch cut_quest_dlg
        case 'Yes'
            data.frameTimes = data.frameTimes(1:ind_cut);
            data.duration = ind_cut;
            data.activities = data.activities(1:ind_cut);
            data.activities_original = data.activities_original(1:ind_cut);
            data.pixelsTimes = data.pixelsTimes(1:ind_cut);
            data.bg_activity = data.bg_activity(1:ind_cut);
            data.activities_deconvolved = data.activities_deconvolved(1:ind_cut);
            data.movie_doc.movie_ruido = data.movie_doc.movie_ruido(1:ind_cut,:);
            data.movie_doc.num_frames = ind_cut;
            
            if strcmp(options.ref_box, 'Yes')
                ind_cut_down = find(time_down<=data.frameTimes(ind_cut),1);
                time_down = time_down(1:ind_cut_down);
                ref_box_movie_correct = ref_box_movie_correct(:,:,1:ind_cut_down);
                shifts_x = shifts_x(1:ind_cut_down);
                shifts_y = shifts_y(1:ind_cut_down);
            end
        case 'No'
    end
end