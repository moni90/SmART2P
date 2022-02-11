function [A_or,C_or,C_df,S_or,P_or] = auto_segmentation_CaImAn(Y,K,tau,framePeriod)
%from demo_script.m in CaImAn-MATLAB-Master
%Y = d1*d2*T movie
%K = number of components to be found
%tau = std of gaussian kernel (half size of neuron) 

if ~isa(Y,'single');    Y = single(Y);  end         % convert to single

[d1,d2,T] = size(Y);                                % dimensions of dataset
d = d1*d2;                                          % total number of pixels

% Set parameters
if framePeriod<1
    p = 2;
else
    p = 1;
end
options = CNMFSetParms(...   
    'd1',d1,'d2',d2,...                         % dimensionality of the FOV
    'p',p,...                                   % order of AR dynamics    
    'gSig',tau,...                              % half size of neuron
    'merge_thr',0.80,...                        % merging threshold  
    'nb',2,...                                  % number of background components    
    'min_SNR',3,...                             % minimum SNR threshold
    'space_thresh',0.5,...                      % space correlation threshold
    'cnn_thr',0.2...                            % threshold for CNN classifier    
    );
% Data pre-processing
[P,Y] = preprocess_data(Y,p);

% fast initialization of spatial components using greedyROI and HALS
[Ain,Cin,bin,fin,center] = initialize_components(Y,K,tau,options,P);  % initialize
% display centers of found components
Cn =  correlation_image(Y); %reshape(P.sn,d1,d2);  %max(Y,[],3); %std(Y,[],3); % image statistic (only for display purposes)
figure;imagesc(Cn);
axis equal; axis tight; hold all;
scatter(center(:,2),center(:,1),'mo');
title('Center of ROIs found from initialization algorithm');
drawnow;

% update spatial components
Yr = reshape(Y,d,T);
[A,b,Cin] = update_spatial_components(Yr,Cin,fin,[Ain,bin],P,options);

% update temporal components
P.p = 0;    % set AR temporarily to zero for speed
[C,f,P,S,YrA] = update_temporal_components(Yr,A,b,Cin,fin,P,options);

% classify components
rval_space = classify_comp_corr(Y,A,C,b,f,options);
ind_corr = rval_space > options.space_thresh;           % components that pass the correlation test
                                        % this test will keep processes
                                        
% further classification with cnn_classifier
try  % matlab 2017b or later is needed
    [ind_cnn,value] = cnn_classifier(A,[d1,d2],'cnn_model',options.cnn_thr);
catch
    ind_cnn = true(size(A,2),1);                        % components that pass the CNN classifier
end     
                            
% event exceptionality
fitness = compute_event_exceptionality(C+YrA,options.N_samples_exc,options.robust_std);
ind_exc = (fitness < options.min_fitness);

% select components
keep = (ind_corr | ind_cnn) & ind_exc;

% display kept and discarded components
A_keep = A(:,keep);
C_keep = C(keep,:);
figure;
    subplot(121); montage(extract_patch(A(:,keep),[d1,d2],[30,30]),'DisplayRange',[0,0.15]);
        title('Kept Components');
    subplot(122); montage(extract_patch(A(:,~keep),[d1,d2],[30,30]),'DisplayRange',[0,0.15])
        title('Discarded Components');

% merge found components
[Am,Cm,K_m,merged_ROIs,Pm,Sm] = merge_components(Yr,A_keep,b,C_keep,f,P,S,options);

% refine estimates excluding rejected components
Pm.p = p;    % restore AR value
[A2,b2,C2] = update_spatial_components(Yr,Cm,f,[Am,b],Pm,options);
%select px based on SNR of extracted activity
A_SNR = reduce_px_SNR(full(A2),Yr,framePeriod);

[C2,f2,P2,S2,YrA2] = update_temporal_components(Yr,sparse(A_SNR),b2,C2,f,Pm,options);

%do some plotting
[A_or,C_or,S_or,P_or] = order_ROIs(A_SNR,C2,S2,P2); % order components
K_m = size(C_or,1);
[C_df,~] = extract_DF_F(Yr,A_or,C_or,P_or,options); % extract DF/F values (optional)

figure;
[Coor,json_file] = plot_contours(A_or,Cn,options,1); % contour plot of spatial footprints

