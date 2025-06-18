function [Data] = Obtain_COSMOS_Data_CSV(FS_str, num_orient)

dir_COSMOS_CSV = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\COSMOS_PDF\CSV';

if num_orient == 3
    col = 5;
elseif num_orient == 4
    col = 7;
elseif num_orient == 5
    col = 9;
elseif num_orient == 6
    col = 11;
end

Read_fn = fullfile(dir_COSMOS_CSV, ['COSMOS_NumOrient_', FS_str, '.csv']);
Vars = readmatrix(Read_fn); % , "VariableNamingRule", "preserve"

if matches(FS_str, '3T')
    
    Data.Prll = Vars(7,col);
    Data.Perp = Vars(6,col);
    Data.Fe_L = Vars(5,col);
    Data.Fe_H = Vars(3,col);
    Data.Ca_L = Vars(4,col);
    Data.Ca_H = Vars(2,col);
    
elseif matches(FS_str, '7T')
    
    Data.Prll = Vars(7,col);
    Data.Perp = Vars(2,col);
    Data.Fe_L = Vars(6,col);
    Data.Fe_H = Vars(4,col);
    Data.Ca_L = Vars(3,col);
    Data.Ca_H = Vars(5,col);
    
end

%     [DataTRR] = ExtractPairsforTRR(Data);
%[DataLDR] = ExtractPairsforLDR(Data);
%[DataFSR] = ExtractPairsforFSR(Data);
%[TRR_ICC, LDR_ICC, FSR_ICC, TV_ICC] = Wrapper_ICC(DataTRR, DataLDR, DataFSR);
%writeICCtoExcel(TRR_ICC, LDR_ICC, FSR_ICC, TV_ICC, strcat(param, '_', ext));