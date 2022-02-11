function value = find_values(xml_info,key,smart_line_scan_info_start)
looking_for_word = find(~cellfun(@isempty,strfind(xml_info,key)));
looking_for_word(looking_for_word<smart_line_scan_info_start) = [];
for ind=1:3
    aux = xml_info{looking_for_word(1)+ind};
    if ~isempty(strfind(aux,'value'))
        value = aux;
        break
    end
end
value = str2double(value(8:end-1));