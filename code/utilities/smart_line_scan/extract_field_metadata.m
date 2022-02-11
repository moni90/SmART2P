function data_out = extract_field_metadata(filename, expr)
filetext = fileread(filename);
matches = regexp(filetext,expr,'match');
pos_field = strfind(matches{1},'=') + 2;
data_out = str2double(matches{1}(pos_field:end-1));
if isempty(data_out) || isnan(data_out)
    error('metadata not read properly');
end
end