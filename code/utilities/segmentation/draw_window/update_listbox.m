function update_listbox(num_neuronas)
global data
lista = cell(1,num_neuronas);
for ind=1:num_neuronas
    lista{ind} = ['N' num2str(ind)];
end
set(data.handles.neurons_list,'value',1)
set(data.handles.neurons_list,'string',lista)
