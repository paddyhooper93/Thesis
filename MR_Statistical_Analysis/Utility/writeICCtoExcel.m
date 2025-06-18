function writeICCtoExcel(TRR_ICC, LDR_ICC, FSR_ICC, TV_ICC, fname)

% Structs and their respective sheet names
Structs = {TRR_ICC, LDR_ICC, FSR_ICC, TV_ICC};
sheetNames = {'TRR_ICC', 'LDR_ICC', 'FSR_ICC', 'TV_ICC'};

% Loop through each structure and file name
for k = 1:4
    % Get current structure and file name
    currentStruct = Structs{k};
    sheetName = sheetNames{k};
    
    % Initialize a cell array to hold the table for each field
    fields = fieldnames(currentStruct);
    mergedTable = [];
    fieldColumn = {}; % Store fieldnames for the first column
    
    % Loop over each field in Struct
    for i = 1:numel(fields)
        % Get the substructure
        subStruct = currentStruct.(fields{i});
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
        
        % Store the current field name in the first column
        fieldColumn = [fieldColumn; {fields{i}}];
        
        % Concatenate values across fields
        mergedTable = [mergedTable; subfieldData];
    end
    
    % Convert to table and add headers as column names
    resultTable = cell2table([fieldColumn, mergedTable], 'VariableNames', headers);
    
    
    
    % Write the final table for this struct to the appropriate sheet
    writetable(resultTable, strcat(fname,'_ICC.xlsx'), 'Sheet', sheetName);
end

end