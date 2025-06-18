%% Placeholder for ICC calculation function
function ICC_Data = calculateICC(Data1, Data2, type)

if nargin < 3
    type = 'A-1';
end


Pairs = ExtractPairsforICC(Data1, Data2);

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
    ICC(Pairs, type);

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
