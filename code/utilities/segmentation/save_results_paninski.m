function data = save_results_paninski(data,Y,A,C,C_df,b,f,S,P,options)

data.numero_neuronas = size(A,2);
data.A = A;
data.C = C;
data.C_df = C_df;
peaks = zeros(size(data.C_df)); %find C_df peaks
for i = 1:size(peaks,1)
    [pks,locs] = findpeaks(data.C_df(i,:));
    peaks(i,locs) = pks;
end
peaks(peaks<0.1)=0;
data.peaks = peaks;
if ~isempty(b)
    data.b = b;
end
data.f = f;
data.S = S;
data.P = P;
if ~isempty(options)
    data.opt = options;
else
    options.d1 = data.linesPerFrame;
    options.d2 = data.pixels_per_line;
    options.nrgthr = 1;
end

data = fromAtoROIs(data,0.01);