function [TRR_ICC, LDR_ICC, FSR_ICC, TV_ICC] = Wrapper_ICC(DataTRR, DataLDR, DataFSR)

type_for_repeatability = 'A-1';
type_for_reproducibility = 'A-1';


% Initialize outputs
TRR_ICC = struct();
LDR_ICC = struct();
FSR_ICC = struct();
TV_ICC  = struct();

% Process DataTRR
fieldsTRR = fieldnames(DataTRR);
for i = 1:length(fieldsTRR)
    varName = fieldsTRR{i};
    varValue = DataTRR.(varName);
    TRR_ICC.(varName) = calculateICC(varValue, type_for_repeatability);
end

% Process DataLDR
fieldsLDR = fieldnames(DataLDR);
for i = 1:length(fieldsLDR)
    varName = fieldsLDR{i};
    varValue = DataLDR.(varName);
    LDR_ICC.(varName) = calculateICC(varValue, type_for_repeatability);
end

% Process DataFSR
fieldsFSR = fieldnames(DataFSR);
for i = 2:length(fieldsFSR) % skip USPIO
    varName = fieldsFSR{i};
    varValue = DataFSR.(varName);
    FSR_ICC.(varName) = calculateICC(varValue, type_for_reproducibility);
end

for i = 1:4 % USPIO and ferritin only (i = 1:2)
    varName = fieldsFSR{i};
    varValue_3T = DataFSR.(varName)(:,1);
    varValue_7T = DataFSR.(varName)(:,2);
    if i == 1
        x_usp = transpose((10:5:30)./ 55.485); % mmol/L 
        Chi_mol_3T = 1.719; Chi_mol_7T = 0.758; % ppm.L/mmol
        TrueValue_3T = x_usp .* Chi_mol_3T; TrueValue_7T = x_usp .* Chi_mol_7T; 
    elseif i == 2
        x_fer = transpose((210 : 90 : 570) ./ 55.845); % (mmol/L)
        Chi_mol = 0.0766;
        TrueValue_3T = x_fer .* Chi_mol; TrueValue_7T = TrueValue_3T;
    elseif i == 3
        x_chl = transpose((0.1:0.1:0.5)./110.98.*1000); % mol/L
        Chi_mol = -0.687;
        TrueValue_3T = x_chl .* Chi_mol; TrueValue_7T = TrueValue_3T;
    elseif i == 4
        x_crb = transpose((0.1:0.1:0.5)./100.0869.*1000); % mol/L
        Chi_mol = -0.480;
        TrueValue_3T = x_crb .* Chi_mol; TrueValue_7T = TrueValue_3T;
    end
    varName_3T = strcat(varName, '_3T');
    varValue_3T = cat(2, varValue_3T, TrueValue_3T);
    TV_ICC.(varName_3T) = calculateICC(varValue_3T, type_for_reproducibility);
    varName_7T = strcat(varName, '_7T');
    varValue_7T = cat(2, varValue_7T, TrueValue_7T);
    TV_ICC.(varName_7T) = calculateICC(varValue_7T, type_for_reproducibility);
end





    function ICC_Data = calculateICC(varValue, type)
        % Placeholder for ICC calculation function
        str_r = 'r';
        str_low = 'lb';
        str_high = 'ub';
        str_F = 'F';
        str_df1 = 'df1';
        str_df2 = 'df2';
        str_p = 'p';
        str_judgement = 'reliability';
        [ICC_Data.(str_r), ICC_Data.(str_low), ICC_Data.(str_high), ICC_Data.(str_F), ...
            ICC_Data.(str_df1), ICC_Data.(str_df2), ICC_Data.(str_p)] = ...
            ICC(varValue, type);

        % Classify ICC reliability
        if ICC_Data.(str_low) > 0.9
            ICC_Data.(str_judgement) = 'excellent';
        elseif (ICC_Data.(str_low) > 0.75) && (ICC_Data.(str_low) < 0.9) && ...
                (ICC_Data.(str_high) > 0.9)
            ICC_Data.(str_judgement) = 'good to excellent';
        elseif (ICC_Data.(str_low) > 0.75) && (ICC_Data.(str_low) < 0.9) && ... 
                (ICC_Data.(str_high) > 0.75) && (ICC_Data.(str_high) < 0.9)
            ICC_Data.(str_judgement) = 'good';
        elseif (ICC_Data.(str_low) > 0.5) && (ICC_Data.(str_low) < 0.75) && ... 
                (ICC_Data.(str_high) > 0.75) 
            ICC_Data.(str_judgement) = 'moderate to good';
        elseif (ICC_Data.(str_low) > 0.5) && (ICC_Data.(str_low) < 0.75) && ... 
                (ICC_Data.(str_high) > 0.5) && (ICC_Data.(str_high) < 0.75)
            ICC_Data.(str_judgement) = 'moderate';            
        else
            ICC_Data.(str_judgement) = 'poor';
        end

    end
end