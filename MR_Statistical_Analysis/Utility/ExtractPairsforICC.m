function [Array_of_Pairs] = ExtractPairsforICC(Data1, Data2)

% Assuming the fields in Data1 and Data2 are identical
fields = fieldnames(Data1);
Array_of_Pairs = [];
for i = 1:length(fields)
    varName = fields{i};
    val1 = Data1.(varName);
    val2 = Data2.(varName);
    Array_of_Pairs = cat(1, Array_of_Pairs, [val1, val2]);
end

end