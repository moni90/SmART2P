function data = align_ROIs(data,tform,Arot,CN)

data.alignment = tform;
% data.CNMF = 1;
data.A = Arot;
data.CN = CN;
data.numero_neuronas = size(data.A ,2);
data = fromAtoROIs(data);

data.noOrder = 1;