function writeBiastoExcel(Bias, fname)

%Bias = Structs{k};
%sheetName = fieldnames(Bias);

% Initialize a cell array to hold the table for each field
fieldNames = fieldnames(Bias);

% Loop over each field in Struct
for i = 1:numel(fieldNames)
    % Get the substructure
    subStruct = Bias.(fieldNames{i});
    subfieldNames = fieldnames(subStruct);
    
    % Initialize an empty cell array to store the data
    subfieldData = cell(1, numel(subfieldNames));
    
    % For the first field, include subfield names as headers
    if i == 1
        headers = [{'FieldName'}, subfieldNames']; % Add "FieldName" as first column header
    end
    
    % Collect the values associated with each subfield
    for j = 1:numel(subfieldNames)
        subfieldData{j} = subStruct.(subfieldNames{j});
    end

    % mergedTable = [];
    % fieldColumn = {}; % Store fieldnames for the first column
    
    % Store the current field name in the first column
    % fieldColumn = [fieldColumn; {fieldNames{i}}];
    
    % Concatenate values across fieldsy
    % mergedTable = [mergedTable; subfieldData];

    merged_cell = [fieldNames{i} subfieldData];

    % Convert to table and add headers as column names
    resultTable = cell2table(merged_cell, 'VariableNames', headers);



    % Write the final table for this struct to the appropriate sheet
    writetable(resultTable, strcat(fname,'_Bias.xlsx'), 'Sheet', fieldNames{i});

end


end