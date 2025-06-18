%% Wrapper_COSMOS_Stats

clearvars
close all

dir_COSMOS = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\COSMOS_PDF\CSV';
num_orient = 5;

Read_fn_1 = fullfile(dir_COSMOS, 'COSMOS_NumOrient_3T.csv');
DataRead1 = readtable(Read_fn_1, "VariableNamingRule", "preserve");
if num_orient == 3
    col = 5;
elseif num_orient ==  4
    col = 7;
elseif num_orient == 5
    col = 9;
elseif num_orient == 6
    col = 11;
end

Data.Prll_3T = DataRead1(7,col);
Data.Perp_3T = DataRead1(6,col);
Data.Fe_L_3T = DataRead1(5,col);
Data.Fe_H_3T = DataRead1(3,col);
Data.Ca_L_3T = DataRead1(4,col);
Data.Ca_H_3T = DataRead1(2,col);


Read_fn_2 = fullfile(dir_COSMOS, 'COSMOS_NumOrient_7T.csv');
DataRead2 = readtable(Read_fn_2, "VariableNamingRule", "preserve");
Data.Prll_7T = DataRead2(2,col);
Data.Perp_7T = DataRead2(7,col);
Data.Fe_L_7T = DataRead2(6,col);
Data.Fe_H_7T = DataRead2(4,col);
Data.Ca_L_7T = DataRead2(3,col);
Data.Ca_H_7T = DataRead2(5,col);

%     [DataTRR] = ExtractPairsforTRR(Data);
%[DataLDR] = ExtractPairsforLDR(Data);
%[DataFSR] = ExtractPairsforFSR(Data);
%[TRR_ICC, LDR_ICC, FSR_ICC, TV_ICC] = Wrapper_ICC(DataTRR, DataLDR, DataFSR);
%writeICCtoExcel(TRR_ICC, LDR_ICC, FSR_ICC, TV_ICC, strcat(param, '_', ext));