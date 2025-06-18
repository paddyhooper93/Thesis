function [Bias] = QSM_Accuracy(DataFSR)

USP_3T              = DataFSR.USP(:,1);
USP_7T              = DataFSR.USP(:,2);
FER_3T              = DataFSR.FER(:,1);
FER_7T              = DataFSR.FER(:,2);
CHL_3T              = DataFSR.CHL(:,1);
CHL_7T              = DataFSR.CHL(:,2);
CRB_3T              = DataFSR.CRB(:,1);
CRB_7T              = DataFSR.CRB(:,2);

MW_Fe = 55.845; % gram per mol, or equivalently "milligram per millimole" (mg/mmol)
c_USP              = (10:5:30) ./ MW_Fe; % millimole per liter (mmol/L)
N                    = length(c_USP);
USP_3T_FITLM         = fitlm(c_USP,USP_3T);
Bias.USP.Beta0_3T         = USP_3T_FITLM.Coefficients{1,1}; % ppm
Bias.USP.Beta0_3T_CIs     = USP_3T_FITLM.Coefficients{1,2}*tinv(0.025,N-2)*-1;
Bias.USP.Slope_3T         = USP_3T_FITLM.Coefficients{2,1}; % ppm.L.g^(-1)
Bias.USP.Slope_3T_CIs     = USP_3T_FITLM.Coefficients{2,2}*tinv(0.025,N-2)*-1;

c_FER                = 210:90:570; % milligram per liter (mg/L)
c_FER                = c_FER ./ MW_Fe; % millimole per liter (mmol/L)
% chi_ref_fer          = 0.0766; % ppm.L/mmol
FER_3T_FITLM         = fitlm(c_FER,FER_3T);
Bias.FER.Beta0_3T         = FER_3T_FITLM.Coefficients{1,1}; % ppm
Bias.FER.Beta0_3T_CIs     = FER_3T_FITLM.Coefficients{1,2}*tinv(0.025,N-2)*-1;
Bias.FER.Slope_3T         = FER_3T_FITLM.Coefficients{2,1}; % ppm.L.(mmol)^(-1)
Bias.FER.Slope_3T_CIs     = FER_3T_FITLM.Coefficients{2,2}*tinv(0.025,N-2)*-1;
% Bias.FER.Beta1_3T         = FER_3T_FITLM.Coefficients{2,1}/chi_ref_fer;
% Bias.FER.Beta1_3T_CIs     = FER_3T_FITLM.Coefficients{2,2}/chi_ref_fer*tinv(0.025,N-2)*-1;

c_CHL                = (0.1:0.1:0.5)./110.98.*1000; % mole per liter (mol/L)
N                    = length(c_CHL);
CHL_3T_FITLM         = fitlm(c_CHL,CHL_3T);
Bias.CHL.Beta0_3T         = CHL_3T_FITLM.Coefficients{1,1}; % ppm
Bias.CHL.Beta0_3T_CIs     = CHL_3T_FITLM.Coefficients{1,2}*tinv(0.025,N-2);
Bias.CHL.Slope_3T         = CHL_3T_FITLM.Coefficients{2,1}; % ppm.L.(mol)^(-1)
Bias.CHL.Slope_3T_CIs     = CHL_3T_FITLM.Coefficients{2,2}*tinv(0.025,N-2);

c_CRB_3T             = (0.1:0.1:0.5)./100.0869.*1000; % % mole per liter (mol/L)
N                    = length(c_CRB_3T);
CRB_3T_FITLM         = fitlm(c_CRB_3T,CRB_3T);
Bias.CRB.Beta0_3T         = CRB_3T_FITLM.Coefficients{1,1}; % ppm
Bias.CRB.Beta0_3T_CIs     = CRB_3T_FITLM.Coefficients{1,2}*tinv(0.025,N-2);
Bias.CRB.Slope_3T         = CRB_3T_FITLM.Coefficients{2,1}; % ppm.L.(mol)^(-1)
Bias.CRB.Slope_3T_CIs     = CRB_3T_FITLM.Coefficients{2,2}*tinv(0.025,N-2);

USP_7T_FITLM         = fitlm(c_USP,USP_7T);
N                    = length(c_USP);
Bias.USP.Beta0_7T         = USP_7T_FITLM.Coefficients{1,1}; 
Bias.USP.Beta0_7T_CIs     = USP_7T_FITLM.Coefficients{1,2}*tinv(0.025,N-2)*-1;
Bias.USP.Slope_7T         = USP_7T_FITLM.Coefficients{2,1}; 
Bias.USP.Slope_7T_CIs     = USP_7T_FITLM.Coefficients{2,2}*tinv(0.025,N-2)*-1;

FER_7T_FITLM         = fitlm(c_FER,FER_7T);
Bias.FER.Beta0_7T         = FER_7T_FITLM.Coefficients{1,1}; 
Bias.FER.Beta0_7T_CIs     = FER_7T_FITLM.Coefficients{1,2}*tinv(0.025,N-2)*-1;
Bias.FER.Slope_7T         = FER_7T_FITLM.Coefficients{2,1}; 
Bias.FER.Slope_7T_CIs     = FER_7T_FITLM.Coefficients{2,2}*tinv(0.025,N-2)*-1;
%Bias.FER.Beta1_7T         = FER_7T_FITLM.Coefficients{2,1}/chi_ref_fer;
%Bias.FER.Beta1_7T_CIs     = FER_7T_FITLM.Coefficients{2,2}/chi_ref_fer*tinv(0.025,N-2)*-1;

CHL_7T_FITLM         = fitlm(c_CHL,CHL_7T);
N                    = length(c_CHL);
Bias.CHL.Beta0_7T         = CHL_7T_FITLM.Coefficients{1,1};
Bias.CHL.Beta0_7T_CIs     = CHL_7T_FITLM.Coefficients{1,2}*tinv(0.025,N-2);
Bias.CHL.Slope_7T         = CHL_7T_FITLM.Coefficients{2,1};
Bias.CHL.Slope_7T_CIs     = CHL_7T_FITLM.Coefficients{2,2}*tinv(0.025,N-2);


c_CRB_7T             = (0.1:0.1:0.5)./100.0869.*1000; % mol/L
N                    = length(c_CRB_7T);
CRB_7T_FITLM         = fitlm(c_CRB_7T,CRB_7T);
Bias.CRB.Beta0_7T         = CRB_7T_FITLM.Coefficients{1,1};
Bias.CRB.Beta0_7T_CIs     = CRB_7T_FITLM.Coefficients{1,2}*tinv(0.025,N-2);
Bias.CRB.Slope_7T         = CRB_7T_FITLM.Coefficients{2,1};
Bias.CRB.Slope_7T_CIs     = CRB_7T_FITLM.Coefficients{2,2}*tinv(0.025,N-2);