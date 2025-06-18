function [DataTRR] = ExtractPairsforTRR(Data)

fields = fieldnames(Data);

for i = 1:length(fields)
    varName = fields{i};
    varValue = Data.(varName);
        if contains(varName, ("USP"|"FER"))
            tmp00 = varValue(:,[1 2]);
            str00 = strcat(varName,"_BL");
            DataTRR.(str00) = tmp00;
            tmp24 = varValue(:,[4 5]);
            str24 = strcat(varName,"_24mth");
            DataTRR.(str24) = tmp24;
        elseif contains(varName, "CHL")
            tmp00 = varValue(:,[1 2]);
            str00 = strcat(varName,"_BL");
            DataTRR.(str00) = tmp00;
        elseif contains(varName, "CRB")
            tmp24 = varValue(:,[2 3]);
            str24 = strcat(varName,"_24mth");
            DataTRR.(str24) = tmp24;
        end
end

end