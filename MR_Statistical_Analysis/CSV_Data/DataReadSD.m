function [DataSD] = DataReadSD(param)

DataRead1 = readtable(strcat('3T_',param,'.csv'),"VariableNamingRule","preserve"); 
DataSD.USP_3T = cat(2, DataRead1{2:6, 6:2:10}, flip(DataRead1{12:16, 12:2:14}, 1)) ;
DataSD.FER_3T = cat(2, DataRead1{7:11, 6:2:10}, flip(DataRead1{2:6, 12:2:14}, 1)) ;
DataSD.CHL_3T = DataRead1{12:16, 6:2:10} ;
% DataRead2 = readtable(strcat('TE1to7_',param, ext,'.csv'),"VariableNamingRule","preserve"); 
DataSD.CRB_3T = DataRead1{17:21, 10:2:14};
DataSD.CRB_3T([7 10]) = DataSD.CRB_3T([10 7]);
DataSD.CRB_3T([6 9]) = DataSD.CRB_3T([9 6]);
DataSD.CRB_3T([11 14]) = DataSD.CRB_3T([14 11]);
DataSD.CRB_3T([12 15]) = DataSD.CRB_3T([15 12]);
DataRead2 = readtable(strcat('7T_',param,'.csv'),"VariableNamingRule","preserve"); 
DataSD.USP_7T = cat(2, DataRead2{2:6, 6:2:10}, flip(DataRead2{12:16, 12:2:14}, 1)) ;
DataSD.FER_7T = cat(2, DataRead2{7:11, 6:2:10}, flip(DataRead2{2:6, 12:2:14}, 1)) ;
DataSD.CHL_7T = DataRead2{12:16, 6:2:10} ;
% DataRead4 = readtable(strcat('TE1to3_',param, ext,'.csv'),"VariableNamingRule","preserve"); 
DataSD.CRB_7T = DataRead2{17:21, 10:2:14};
DataSD.CRB_7T([7 10]) = DataSD.CRB_7T([10 7]);
DataSD.CRB_7T([6 9]) = DataSD.CRB_7T([9 6]);
DataSD.CRB_7T([11 14]) = DataSD.CRB_7T([14 11]);
DataSD.CRB_7T([12 15]) = DataSD.CRB_7T([15 12]);

% Note on 24mth time-point (Cols 11 to 14):
% ROIs were flipped for USP, FER and swapped for CRB.
% 2 ROIs (i.e., vials) were removed for CHL, 
% so we didn't analyse CHL for 24mth time-point.

end