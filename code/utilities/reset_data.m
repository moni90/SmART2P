function data_aux = reset_data(data_aux,num_cell)
%this function resets different fields of the data variable before
%creating/loading a new movie or predictiong new ROIs
num_neurons = 1;
maximo_numero_puntos = 1;%200;
if nargin==1
    data_aux.roi = zeros(num_neurons,2,maximo_numero_puntos);
    data_aux.rois_inside = zeros(num_neurons,2,maximo_numero_puntos);
    data_aux.rois_centres = zeros(num_neurons,2);
    data_aux.activities = zeros(num_neurons,data_aux.duration);
    data_aux.activities_original = zeros(num_neurons,data_aux.duration);
    data_aux.pixelsTimes = zeros(num_neurons,data_aux.duration);
    data_aux.line_handles = zeros(num_neurons,maximo_numero_puntos);
    data_aux.line_handles_p = zeros(num_neurons,maximo_numero_puntos);
    data_aux.numero_puntos = zeros(num_neurons,1);
    data_aux.snr_per_neuron = zeros(num_neurons,4);
    data_aux.signal_to_noise_ratio_mat= zeros(num_neurons,200);
    data_aux.background = zeros(num_neurons,2,maximo_numero_puntos);
    data_aux.background_inside = zeros(num_neurons,2,maximo_numero_puntos);
    data_aux.bgs_centres = zeros(num_neurons,2);
    data_aux.line_bg_handles = zeros(num_neurons,maximo_numero_puntos);
    data_aux.numero_puntos_background = zeros(num_neurons,1);
    data_aux.bg_activity =  zeros(num_neurons,data_aux.duration);
    
    if isfield(data_aux,'handles')
        s = findobj(data_aux.handles.axes_handles_imagen,'type','line');
        if ~isempty(s)
            delete(s)
        end
        s = findobj(data_aux.handles.axes_handles_activity,'type','line');
        if ~isempty(s)
            delete(s)
        end
        
        data_aux.handles.handles_outline_rois = zeros(num_neurons,maximo_numero_puntos);
        data_aux.handles.handles_inside_rois =  zeros(num_neurons,maximo_numero_puntos);
        
        data_aux.prediction_rois = zeros(data_aux.linesPerFrame,data_aux.pixels_per_line);
        
        data_aux.handles.handles_outline_centres = zeros(num_neurons,maximo_numero_puntos);
        data_aux.handles.handles_inside_centres =  zeros(num_neurons,maximo_numero_puntos);
        data_aux.prediction_centres = zeros(data_aux.linesPerFrame,data_aux.pixels_per_line);
        
        data_aux.handles.handles_outline_background = zeros(num_neurons,maximo_numero_puntos);
        data_aux.handles.handles_inside_background =  zeros(num_neurons,maximo_numero_puntos);
        data_aux.numero_backgrounds = 0;
        data_aux.insides = 0;
        data_aux.background_on = 0;
        data_aux.average_on = 1;
        data_aux.figure_activities = 0;
        data_aux.neurona_elegida = 0;
    end
    
    data_aux.numero_neuronas = 0;
    
    if isfield(data_aux,'CNMF') && data_aux.CNMF==1
        data_aux.A = [];
        data_aux.C = [];
        data_aux.C_df = [];
        data_aux.f = [];
        data_aux.P = [];
        data_aux.S = [];
        data_aux.activities_deconvolved = zeros(num_neurons,data_aux.duration);
    end
    
else
    %data_aux.handles.outline_rois(num_cell,:) = [];
    if isfield(data_aux.handles,'inside_rois')
        data_aux.handles.inside_rois(num_cell,:) = [];
    end
    data_aux.roi(num_cell,:,:) = [];
    data_aux.rois_inside(num_cell,:,:) = [];
    data_aux.rois_centres(num_cell,:) = [];
    data_aux.activities(num_cell,:) = [];
    data_aux.activities_original(num_cell,:) = [];
    data_aux.pixelsTimes(num_cell,:) = [];
    delete(data_aux.line_handles(num_cell,:))
    delete(data_aux.line_handles_p(num_cell,:))
    data_aux.line_handles(num_cell,:) =  [];
    data_aux.line_handles_p(num_cell,:) = [];
    data_aux.numero_puntos(num_cell) = 0;
    data_aux.numero_neuronas = data_aux.numero_neuronas - 1;
    
    if data_aux.CNMF == 1
        data_aux.A(:,num_cell) = [];
        data_aux.C(num_cell,:) = [];
        data_aux.C_df(num_cell,:) = [];
        data_aux.S(num_cell,:) = [];
    elseif isfield(data_aux,'A')
        data_aux.A(:,num_cell) = [];
    end
    
end
end