function data = inizialize_data(import_TS_path,options)
    
    if import_TS_path(end)=='\' || import_TS_path(end)=='/'
        import_TS_path = import_TS_path(1:end-1);
    end
    if ispc
        id_slash = strfind(import_TS_path,'\');
        id_slash = id_slash(end);
    else
        id_slash = strfind(import_TS_path,'/');
        id_slash = id_slash(end);
    end
    if contains(import_TS_path(id_slash+1:end),'.')
        data.path = import_TS_path(1:id_slash);
        data.file = import_TS_path(id_slash+1:end);
    else
        if ispc
            data.path = [import_TS_path '\'];
        else
            data.path = [import_TS_path '/'];
        end
        data.file = [];
    end

    if isfield(options,'mode')
        if strcmp(options.mode,'raster')
            data.mode = 'TSeries';
        else
            data.mode = 'freehand';
        end
    else
        data.mode = 'TSeries'; %default value is raster
    end
    
    colores = [[1 0 0];[0 1 0];[0 0 1];[0 1 1];[1 0 1];[1 1 0];];%[0 0 0]];%colores is the variable that keeps the colours used to draw the ROIs
    data.colores = [colores(2:end,:);colores(1:end,:)*0.9;colores(1:end,:)*0.8,;colores(1:end,:)*0.7;...
        colores(1:end,:)*0.6;colores(1:end,:)*0.5,;colores(1:end,:)*0.4];
    data.colores = repmat(data.colores,10,1);
    

end