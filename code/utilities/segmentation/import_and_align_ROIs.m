function data = import_and_align_ROIs(data,ROIs_path,flag_align,flag_optimize_SNR)

if nargin<3
    flag_optimize_SNR = 0;
elseif nargin<2
    flag_align = 0;
    flag_optimize_SNR = 0;
end

if strcmp(ROIs_path(end-3:end),'.mat')== 1
    fig_loading = uifigure;
    d = uiprogressdlg(fig_loading,'Title','Loading ROIs',...
        'Indeterminate','on');
    drawnow
    data_aux = load(ROIs_path);
    close(d)
    close(fig_loading)
elseif strcmp(ROIs_path(end-3:end),'.csv')== 1 || strcmp(ROIs_path(end-3:end),'.txt')== 1
    A = readmatrix(ROIs_path);
    data_aux.data.A = A;
    if size(A,1) ~= data.linesPerFrame*data.pixels_per_line
        error('ROIs not compatible with FOV!')
    else
        data_aux.data.linesPerFrame = data.linesPerFrame;
        data_aux.data.pixels_per_line = data.pixels_per_line;
        data_aux.data.CNimage = data.CNimage;
        data_aux.data = fromAtoROIs(data_aux.data);
    end
end

if isequal(data.mode,'Linescan') || isequal(data.mode,'freehand')
    tic
    fig_loading = uifigure;
    d = uiprogressdlg(fig_loading,'Title','Registering ROIs',...
        'Indeterminate','on');
    drawnow
    if ROIs_path~=0
        data = register_ROIs_ls(data,ROIs_path);
    else
        warning('No reference segmentation!')
    end
    close(d)
    close(fig_loading)

    time_int=strcat(num2str(toc),' s');
    disp(['Loading done! Elapsed time:',time_int]);
    if isfield(data,'A') && ~isempty(data.A)
        process_quest_dlg = questdlg('Would you like to process the data?',...
            'Data process','Yes','No','No');
        data = process_ls_data(data, process_quest_dlg);
    end
else
    if isfield(data_aux,'data_reference')
        data_aux.data = data_aux.data_reference;
        data_aux = rmfield(data_aux,'data_reference');
    end
    
    if ~isfield(data_aux.data,'A') || isempty(data_aux.data.A)
        warning('No reference ROIs for alignment!');
        return;
    else
        %remove some data that might have been previously stored
        data = reset_data(data);
        %compute correlation image from NEW TSeries
        tic;
        if isfield(data,'CNimage')
            CN = data.CNimage;
        else
            CN = correlation_image(data.movie_doc.movie_ruido',8,...
                data.linesPerFrame, data.pixels_per_line);
        end
        CNpad = CN;
        %import ROIs and correlation
        A_ROIs = data_aux.data.A;
        
        switch flag_align
            case 1
                if isfield(data_aux.data,'CNimage')
                    CN_ROIs = data_aux.data.CNimage;
                else
                    CN_ROIs = correlation_image(data_aux.data.movie_doc.movie_ruido',8,...
                        data_aux.data.linesPerFrame, data_aux.data.pixels_per_line);
                end
                if size(CN_ROIs,1)~=size(CNpad,1) || size(CN_ROIs,2)~=size(CNpad,2)
                    warning('Alignment can be performed only for FOVs of the same size!');
                    return;
                end
                if isfield(data_aux.data,'scan_traj')
                    scan_traj = data_aux.data.scan_traj;
                    data.scan_margin_extra_pixels = data_aux.data.scan_margin_extra_pixels;
                    data.traj_choice = data_aux.data.traj_choice;
                end
                
                fig_loading = uifigure;
                d = uiprogressdlg(fig_loading,'Title','Alignment of new FOV with the reference FOV',...
                    'Indeterminate','on');
                drawnow

                %compute transformation to align new TSeries with old TSeries
                [optimizer, ~] = imregconfig('multimodal');
                optimizer.GrowthFactor = 1.01;
                optimizer.Epsilon = 1e-7;
                optimizer.MaximumIterations = 800;
                metric = registration.metric.MeanSquares;
                [choice_keep,tform, Arot, CNtransformed] = perform_alignment(CN_ROIs,CNpad,A_ROIs,optimizer,metric);
                close(d);
                close(fig_loading);
                switch choice_keep
                    case 'Yes, with fit'
                        fig_processing = uifigure;
                        d = uiprogressdlg(fig_processing,'Title','ROIs alignment',...
                            'Indeterminate','on');
                        drawnow
                        data = align_ROIs(data,tform,Arot,CNtransformed);
                        close(d);
                        close(fig_processing);
                        if flag_optimize_SNR
                            data = onlyOptimizeSNR(data);
                        end
                        fig_processing = uifigure;
                        d = uiprogressdlg(fig_processing,'Title','Denoising and deconvolving traces',...
                            'Indeterminate','on');
                        drawnow
                        data.noOrder = 1;
                        data.CNMF = 1;
                        data = onlyTemporal(data);
                        close(d);
                        close(fig_processing);
                        data = fluorescence(data);
                        %                         deal_with_new_rois;
                    case 'Yes'
                        fig_processing = uifigure;
                        d = uiprogressdlg(fig_processing,'Title','ROIs alignment',...
                            'Indeterminate','on');
                        drawnow
                        data = align_ROIs(data,tform,Arot,CNtransformed);
                        close(d);
                        close(fig_processing);
                        if flag_optimize_SNR
                            data = onlyOptimizeSNR(data);
                        end
                        data.noOrder = 1;
                        data.CNMF = 0;
                        data = fluorescence(data);
                        %                         deal_with_new_rois;
                    case 'No'
                        disp('import ROIs failed.');
                end
            case 0
                tam_screen = get(0,'ScreenSize');
                alignment = figure('Position',[150 150 tam_screen(3)-300 tam_screen(4)-300]);
                plot_contours(1*(A_ROIs>0),CN,1,0); colormap('gray');
                data.noOrder = 1;
                choice_keep = questdlg('Would you like to keep these ROIs?', ...
                    'Import ROIs', ...
                    'Yes, with fit','Yes','No','Yes');
                switch choice_keep
                    case 'Yes, with fit'
                        data.A = A_ROIs;
                        data.numero_neuronas = size(data.A ,2);
                        data.roi = data_aux.data.roi;
                        data.rois_inside = data_aux.data.rois_inside;
                        data.rois_centres = data_aux.data.rois_centres;
                        data.noOrder = 1;
                        data.CNMF = 1;
                        if flag_optimize_SNR
                            data = onlyOptimizeSNR(data);
                        end
                        fig_processing = uifigure;
                        d = uiprogressdlg(fig_processing,'Title','Denoising and deconvolving traces',...
                            'Indeterminate','on');
                        drawnow
                        data = onlyTemporal(data);
                        close(d);
                        close(fig_processing);
                        data = fluorescence(data);
                        %                         deal_with_new_rois;
                    case 'Yes'
                        data.A = A_ROIs;
                        data.numero_neuronas = size(data.A ,2);
                        data.roi = data_aux.data.roi;
                        data.rois_inside = data_aux.data.rois_inside;
                        data.rois_centres = data_aux.data.rois_centres;
                        data.noOrder = 1;
                        data.CNMF = 0;
                        if flag_optimize_SNR
                            data = onlyOptimizeSNR(data);
                        end
                        data = fluorescence(data);
                        %                         deal_with_new_rois;
                    case 'No'
                        disp('import ROIs failed.');
                end
                close(alignment);
                
        end
    end
    time_int=strcat(num2str(toc),' s');
    disp(['Loading done! Elapsed time:',time_int]);
    
end