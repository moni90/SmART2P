function data_aux = fluorescence(data_aux)
%this function will compute the fluorescence of each neuron along the video
%duration. To do so, it takes all pixels belonging to the neuron and
%average their activities across time. The it does the dF0 = (F-F0)/F0
%data.activities = dF0 of the raw fluorescence
%data.activties_original = raw fluorescence
%data.activities_Paninski = dF/F of denoised fluorescence (C_df)

video = data_aux.movie_doc.movie_ruido;
for ind_n=1:data_aux.numero_neuronas
    if length(size(data_aux.rois_inside))==3
        roi_dots = squeeze(data_aux.rois_inside(ind_n,:,:));
        roi_dots(:,roi_dots(1,:)==0) = [];
    elseif length(size(data_aux.rois_inside))==2
        roi_dots = squeeze(data_aux.rois_inside(ind_n,:));
        roi_dots = roi_dots';
    end
    if isequal(data_aux.mode,'freehand_scan')% && ~isequal(data_aux.mode,'Linescan') && ~isequal(data_aux.mode,'freehand')
        pixels_delays = zeros(1,size(roi_dots,2));
        for ind_p=1:size(roi_dots,2)
            [dist,ind] = min(sqrt((data_aux.freehand_scan(1,:)-roi_dots(1,ind_p)).^2 + (data_aux.freehand_scan(2,:)-roi_dots(2,ind_p)).^2));
            pixels_delays(ind_p) = ind*data_aux.dwellTime;
            assert(dist<1)
        end
        data_aux.pixelsTimes(ind_n,:) = mean(repmat(data_aux.frameTimes',1,size(roi_dots,2)) +...
            repmat(pixels_delays,numel(data_aux.frameTimes),1),2);
    elseif ~isempty(strfind(data_aux.scanningType,'Spiral'))
        data_aux.pixelsTimes(ind_n,:) = data_aux.frameTimes';
    else
        pixels_delays = data_aux.scanlinePeriod*(roi_dots(1,:)-1) + data_aux.dwellTime*(roi_dots(2,:)-1);
        data_aux.pixelsTimes(ind_n,:) = mean(repmat(data_aux.frameTimes',1,size(roi_dots,2)) +...
            repmat(pixels_delays,numel(data_aux.frameTimes),1),2);
    end
    roi_dots_1D = twoD_to_oneD(data_aux.linesPerFrame,roi_dots');
    roi_activity = video(:,roi_dots_1D);
    roi_activity = mean(roi_activity,2);
    baseline = mean(roi_activity(roi_activity<median(roi_activity)));
    df0_activity = (roi_activity-baseline)./baseline;
    data_aux.activities(ind_n,:) = df0_activity;
    data_aux.activities_original(ind_n,:) = roi_activity;
    if isfield(data_aux,'CNMF') && data_aux.CNMF==1 && isfield(data_aux,'C_df') && ~isempty(data_aux.C_df)
        data_aux.activities_deconvolved(ind_n,:) = data_aux.C_df(ind_n,:);
    end
end

