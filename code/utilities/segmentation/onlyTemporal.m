function data = onlyTemporal(data)

Y = data.movie_doc.movie_ruido;
Y = Y';
d1 = data.linesPerFrame; d2 = data.pixels_per_line;
if isfield(data,'CNimage')
    CN = data.CNimage;
else
    CN = correlation_image(Y,8,d1,d2);
end


%transform select ROIs in a matrix format
A = fromManualToMatrix(data.rois_inside,data.roi,...
    data.pixels_per_line, data.linesPerFrame, data.numero_neuronas,Y,data.framePeriod);


%extract raw fluorescence
Fraw = zeros(size(A,2),size(Y,2));
for ii=1:size(A,2)
    Fraw(ii,:) = mean(Y(find(A(:,ii)),:),1);
end

if data.framePeriod <0.5
    options = CNMFSetParms(...
        'd1',d1,'d2',d2,...                         % dimensionality of the FOV
        'p',2 ...                                   % order of AR dynamics
        );
    P.p=2;
else
    options = CNMFSetParms(...
        'd1',d1,'d2',d2,...                         % dimensionality of the FOV
        'p',1 ...                                   % order of AR dynamics
        );
    P.p=1;
end
b = 1*(sum(A,2)==0);

[C,f,P,S,YrA] = update_temporal_components(Y,A,[],[],[],P,options);
if isfield(data,'noOrder') && data.noOrder == 1
    [C_df,Df] = extract_DF_F(Y,A,C,[],[]);
    P.p = options.p;
else
    [A,C,S,P,srt] = order_ROIs(A,C,S,[]); % order components
    [C_df,Df] = extract_DF_F(Y,A,C,[],[]);
    Fraw = Fraw(srt,:);
end

data.Fraw = Fraw;
data = save_results_paninski(data,Y,A,C,C_df,b,f,S,P,[]);
end


