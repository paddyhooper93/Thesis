function [DataFSR] = ExtractPairsforFSR(Data, hdr)

% Check if 'hdr' is provided; if not, set default values
if nargin < 2
    hdr.TP9mth_only = false; 
end

if hdr.TP9mth_only
    DataFSR.USP = cat(2, Data.USP_3T, Data.USP_7T);
    DataFSR.FER = cat(2, Data.FER_3T, Data.FER_7T);
    DataFSR.CHL = cat(2, Data.CHL_3T, Data.CHL_7T);
    DataFSR.CRB = cat(2, Data.CRB_3T, Data.CRB_7T);
    return
end

fields = fieldnames(Data);

for i = 1:length(fields)
    varName = fields{i};
    varValue = Data.(varName);
        if contains(varName, ("USP" | "FER"))
            tmp00 = varValue(:,[1,2]);
            tmp09 = varValue(:,3);
            tmp24 = varValue(:,[4 5]);      
            tmp = cat(2, tmp00, tmp09, tmp24);
            tmp = mean(tmp,2);
            TempStruct.(varName) = tmp;     
        elseif contains(varName, "CHL")
            tmp00 = varValue(:,[1 2]);
            tmp09 = varValue(:,3);
            tmp = cat(2, tmp00, tmp09);
            tmp = mean(tmp,2);
            TempStruct.(varName) = tmp;      
        elseif contains(varName, "CRB")
            tmp09 = varValue(:,3);
            tmp24 = varValue(:,[2 3]);
            tmp = cat(2, tmp09, tmp24);
            tmp = mean(tmp,2);            
            TempStruct.(varName) = tmp;      
        end
end
clear fields varName varValue
% Initialize an empty structure to hold the empty fields 
DataFSR = struct();
% Get all field names of the structure
fieldNames = fieldnames(TempStruct);
% Loop over the field names
for i = 1:length(fieldNames)
    for j = i+1:length(fieldNames)
        % Compare first three characters of the field names
        if strncmp(fieldNames{i}, fieldNames{j}, 3)
            % Concatenate arrays and store in the new structure
            DataFSR.(fieldNames{i}(1:3)) = ...
                [TempStruct.(fieldNames{i}), TempStruct.(fieldNames{j})];
        end
    end
end


end