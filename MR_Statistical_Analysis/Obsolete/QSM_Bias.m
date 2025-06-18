%%QSM_Bias.m
%% Individual and Overall Bias
%% Ref (ppm) = chi_ref*c

% Same derivation used by Liu et al. 2009 (COSMOS Paper)
% Magnetization level for Ferumoxtran:
% reported by Jung & Jacobs (53.6 @0.1T, 94.8 @5T)
% chi_ref_usp3T = (94.8)*(4*pi*10^(-7))*10^(6)/2.893*(55.845*10^(-3));
% chi_ref_usp7T = (94.8)*(4*pi*10^(-7))*10^(6)/7*(55.845*10^(-3));
c_usp = 1.25.*(10:5:30)./ 55.845; %mmol/L
% USP3T_REF = c_usp.*chi_ref_usp3T; % (ppm)
% USP7T_REF = c_usp.*chi_ref_usp7T;

chi_ref_fer = 0.0766; %ppm.L/mmol
c_fer = (210:90:570) ./ 55.845; %mmol/L
FER_REF = c_fer.*chi_ref_fer;
% 210 ug/mL = 210 mg/L = 0.21 g/L

% CRC literature value for CaCl2 -> -54.7 ppm.cm^3/mol

% chi_ref_chl = -54.7*4*pi/1000; % -> -0.6874; %ppm.L/mol
c_chl = (0.1:0.1:0.4)./110.98.*1000; % mol/L
% CHL_REF = c_chl.*chi_ref_chl;

% The CRC literature value should be reliable,
% if we trust Hopkins & Wehrli, 1997
% However, the CRC literature value doesnt agree with our data.
% One can speculate that the Ca and Cl ions disassociate.

% CRC literature value for CaCO3 -> -54.7 ppm.cm^3/mol
% This value is unreliable, since there is a chemical reaction
% when dissolving CaCO3 in H2O
% chi_ref_crb = -0.3027; %ppm.L/mol
c_crb_3T = (0.1:0.1:0.5)./100.0869.*1000; % mol/L
% CRB3T_REF = c_crb_3T.*chi_ref_crb;
% CRB7T_REF = CRB3T_REF(1:4);

%% Fixed and Proportional Bias
%% Molar concentrations

x_USP                = transpose(c_usp); % mmol/L
N                    = length(x_USP);
USP_3T_FITLM         = fitlm(x_USP,USP_3T_OverL);
USP_3T_Beta0         = USP_3T_FITLM.Coefficients{1,1};
USP_3T_Beta0_CIs     = USP_3T_FITLM.Coefficients{1,2}*tinv(0.025,N-2)*-1;
USP_3T_Beta1         = USP_3T_FITLM.Coefficients{2,1}/chi_ref_usp3T;
USP_3T_Beta1_CIs     = USP_3T_FITLM.Coefficients{2,2}/chi_ref_usp3T*tinv(0.025,N-2)*-1;

x_FER                = transpose(c_fer); % (mmol/L)
FER_3T_FITLM         = fitlm(x_FER,FER_3T_OverL);
FER_3T_Beta0         = FER_3T_FITLM.Coefficients{1,1};
FER_3T_Beta0_CIs     = FER_3T_FITLM.Coefficients{1,2}*tinv(0.025,N-2)*-1;
FER_3T_Beta1         = FER_3T_FITLM.Coefficients{2,1}/chi_ref_fer;
FER_3T_Beta1_CIs     = FER_3T_FITLM.Coefficients{2,2}/chi_ref_fer*tinv(0.025,N-2)*-1;

x_CHL                = transpose(c_chl); % mol/L
N                    = length(x_CHL);
CHL_3T_FITLM         = fitlm(x_CHL,CHL_3T_OverL);
CHL_3T_Beta0         = CHL_3T_FITLM.Coefficients{1,1};
CHL_3T_Beta0_CIs     = CHL_3T_FITLM.Coefficients{1,2}*tinv(0.025,N-2);
CHL_3T_Beta1         = CHL_3T_FITLM.Coefficients{2,1}/chi_ref_chl;
CHL_3T_Beta1_CIs     = CHL_3T_FITLM.Coefficients{2,2}/chi_ref_chl*tinv(0.025,N-2);

x_CRB_3T             = transpose(c_crb_3T); % mol/L
N                    = length(x_CRB_3T);
CRB_3T_FITLM         = fitlm(x_CRB_3T,CRB_3T_OverL);
CRB_3T_Beta0         = CRB_3T_FITLM.Coefficients{1,1};
CRB_3T_Beta0_CIs     = CRB_3T_FITLM.Coefficients{1,2}*tinv(0.025,N-2);
CRB_3T_Beta1         = CRB_3T_FITLM.Coefficients{2,1}/chi_ref_crb;
CRB_3T_Beta1_CIs     = CRB_3T_FITLM.Coefficients{2,2}/chi_ref_crb*tinv(0.025,N-2);

USP_7T_FITLM         = fitlm(x_USP,USP_7T_OverL);
USP_7T_Beta0         = USP_7T_FITLM.Coefficients{1,1};
USP_7T_Beta0_CIs     = USP_7T_FITLM.Coefficients{1,2}*tinv(0.025,N-2)*-1;
USP_7T_Beta1         = USP_7T_FITLM.Coefficients{2,1}/chi_ref_usp7T;
USP_7T_Beta1_CIs     = USP_7T_FITLM.Coefficients{2,2}/chi_ref_usp7T*tinv(0.025,N-2)*-1;

FER_7T_FITLM         = fitlm(x_FER,FER_7T_OverL);
FER_7T_Beta0         = FER_7T_FITLM.Coefficients{1,1};
FER_7T_Beta0_CIs     = FER_7T_FITLM.Coefficients{1,2}*tinv(0.025,N-2)*-1;
FER_7T_Beta1         = FER_7T_FITLM.Coefficients{2,1}/chi_ref_fer;
FER_7T_Beta1_CIs     = FER_7T_FITLM.Coefficients{2,2}/chi_ref_fer*tinv(0.025,N-2)*-1;

CHL_7T_FITLM         = fitlm(x_CHL,CHL_7T_OverL);
N                    = length(x_CHL);
CHL_7T_Beta0         = CHL_7T_FITLM.Coefficients{1,1};
CHL_7T_Beta0_CIs     = CHL_7T_FITLM.Coefficients{1,2}*tinv(0.025,N-2);
CHL_7T_Beta1         = CHL_7T_FITLM.Coefficients{2,1}/chi_ref_chl;
CHL_7T_Beta1_CIs     = CHL_7T_FITLM.Coefficients{2,2}/chi_ref_chl*tinv(0.025,N-2);


x_CRB_7T = (0.1:0.1:0.4)./100.0869.*1000; % mol/L
N                    = length(x_CRB_7T);
CRB_7T_FITLM         = fitlm(x_CRB_7T,CRB_7T_OverL);
CRB_7T_Beta0         = CRB_7T_FITLM.Coefficients{1,1};
CRB_7T_Beta0_CIs     = CRB_7T_FITLM.Coefficients{1,2}*tinv(0.025,N-2);
CRB_7T_Beta1         = CRB_7T_FITLM.Coefficients{2,1}/chi_ref_crb;
CRB_7T_Beta1_CIs     = CRB_7T_FITLM.Coefficients{2,2}/chi_ref_crb*tinv(0.025,N-2);

% clear USP_3T_FITLM FER_3T_FITLM CHL_3T_FITLM CRB_3T_FITLM ...
%     USP_7T_FITLM FER_7T_FITLM CHL_7T_FITLM CRB_7T_FITLM ...
%     x_crb_7T x_crb_3T x_CHL x_FER x_USP N ...
%     chi_ref_usp3T chi_ref_usp7T c_usp chi_ref_fer ...
%     c_fer chi_ref_chl c_chl chi_ref_crb c_crb

%% WriteMatrix_Beta0

Beta0_array = 1000.*[USP_3T_Beta0 USP_3T_Beta0_CIs USP_7T_Beta0 USP_7T_Beta0_CIs; ...
    FER_3T_Beta0 FER_3T_Beta0_CIs FER_7T_Beta0 FER_7T_Beta0_CIs; ...
    CHL_3T_Beta0 CHL_3T_Beta0_CIs CHL_7T_Beta0 CHL_7T_Beta0_CIs; ...
    CRB_3T_Beta0 CRB_3T_Beta0_CIs CRB_7T_Beta0 CRB_7T_Beta0_CIs];
writematrix(Beta0_array,"Beta0.csv");

clear USP_3T_Beta0 USP_3T_Beta0_CIs USP_7T_Beta0 USP_7T_Beta0_CIs ...
    FER_3T_Beta0 FER_3T_Beta0_CIs FER_7T_Beta0 FER_7T_Beta0_CIs ...
    CHL_3T_Beta0 CHL_3T_Beta0_CIs CHL_7T_Beta0 CHL_7T_Beta0_CIs ...
    CRB_3T_Beta0 CRB_3T_Beta0_CIs CRB_7T_Beta0 CRB_7T_Beta0_CIs

Beta1_array = [USP_3T_Beta1 USP_3T_Beta1_CIs USP_7T_Beta1 USP_7T_Beta1_CIs; ...
    FER_3T_Beta1 FER_3T_Beta1_CIs FER_7T_Beta1 FER_7T_Beta1_CIs; ...
    CHL_3T_Beta1 CHL_3T_Beta1_CIs CHL_7T_Beta1 CHL_7T_Beta1_CIs; ...
    CRB_3T_Beta1 CRB_3T_Beta1_CIs CRB_7T_Beta1 CRB_7T_Beta1_CIs];
writematrix(Beta1_array,"Beta1.csv");

clear USP_3T_Beta1 USP_3T_Beta1_CIs USP_7T_Beta1 USP_7T_Beta1_CIs ...
    FER_3T_Beta1 FER_3T_Beta1_CIs FER_7T_Beta1 FER_7T_Beta1_CIs ...
    CHL_3T_Beta1 CHL_3T_Beta1_CIs CHL_7T_Beta1 CHL_7T_Beta1_CIs ...
    CRB_3T_Beta1 CRB_3T_Beta1_CIs CRB_7T_Beta1 CRB_7T_Beta1_CIs


%% CalculateOverallBias

% Individual Bias (%) = (Y_Overline-(Ref))/(Ref)*100; => Beta_Idv
% N = size(idx)
% Overall Bias (%)       = sum(Beta_Idv(:,idx))/N => Beta_Hat

%[USP_3T_Beta_Idv, USP_3T_Beta_Hat, USP_3T_Beta_Hat_CIs] = CalculateOverallBias(USP_3T_OverL,USP3T_REF);
%[USP_7T_Beta_Idv, USP_7T_Beta_Hat, USP_7T_Beta_Hat_CIs] = CalculateOverallBias(USP_7T_OverL,USP7T_REF);
[FER_3T_Beta_Idv, FER_3T_Beta_Hat, FER_3T_Beta_Hat_CIs] = CalculateOverallBias(FER_3T_OverL,FER_REF);
[FER_7T_Beta_Idv, FER_7T_Beta_Hat, FER_7T_Beta_Hat_CIs] = CalculateOverallBias(FER_7T_OverL,FER_REF);
%[CHL_3T_Beta_Idv, CHL_3T_Beta_Hat, CHL_3T_Beta_Hat_CIs] = CalculateOverallBias(CHL_3T_OverL,CHL_REF);
%[CHL_7T_Beta_Idv, CHL_7T_Beta_Hat, CHL_7T_Beta_Hat_CIs] = CalculateOverallBias(CHL_7T_OverL,CHL_REF);
%[CRB_3T_Beta_Idv, CRB_3T_Beta_Hat, CRB_3T_Beta_Hat_CIs] = CalculateOverallBias(CRB_3T_OverL,CRB3T_REF);
%[CRB_7T_Beta_Idv, CRB_7T_Beta_Hat, CRB_7T_Beta_Hat_CIs] = CalculateOverallBias(CRB_7T_OverL,CRB7T_REF);

clear CHL_3T_OverL CHL_7T_OverL CHL_REF CRB_3T_OverL CRB3T_REF CRB_7T_OverL CRB7T_REF
clear FER_3T_OverL FER_7T_OverL FER_REF USP_3T_OverL USP_7T_OverL USP3T_REF USP7T_REF

%% WriteMatrix

%BetaIdv_array = [USP_3T_Beta_Idv zeros(3,1) USP_7T_Beta_Idv zeros(3,1) ; ...
%                FER_3T_Beta_Idv  zeros(3,1) FER_7T_Beta_Idv zeros(3,1) ; ...
%                CHL_3T_Beta_Idv  zeros(3,1) CHL_7T_Beta_Idv zeros(3,1) ; ...
%                CRB_3T_Beta_Idv  zeros(3,1) CRB_7T_Beta_Idv zeros(3,1) ];
%BetaHat_array = [USP_3T_Beta_Hat USP_3T_Beta_Hat_CIs USP_7T_Beta_Hat USP_7T_Beta_Hat_CIs;...
%    FER_3T_Beta_Hat FER_3T_Beta_Hat_CIs FER_7T_Beta_Hat FER_7T_Beta_Hat_CIs;...
%    CHL_3T_Beta_Hat CHL_3T_Beta_Hat_CIs CHL_7T_Beta_Hat CHL_7T_Beta_Hat_CIs;...
%    CRB_3T_Beta_Hat CRB_3T_Beta_Hat_CIs CRB_7T_Beta_Hat CRB_7T_Beta_Hat_CIs];

Beta_array    = %[USP_3T_Beta_Hat USP_3T_Beta_Hat_CIs USP_7T_Beta_Hat USP_7T_Beta_Hat_CIs;...
                %USP_3T_Beta_Idv zeros(3,1) USP_7T_Beta_Idv zeros(3,1) ; ...
                % FER_3T_Beta_Hat FER_3T_Beta_Hat_CIs FER_7T_Beta_Hat FER_7T_Beta_Hat_CIs;...
                % FER_3T_Beta_Idv  zeros(3,1) FER_7T_Beta_Idv zeros(3,1) ; ...
                %CHL_3T_Beta_Hat CHL_3T_Beta_Hat_CIs CHL_7T_Beta_Hat CHL_7T_Beta_Hat_CIs;...
                %CHL_3T_Beta_Idv  zeros(3,1) CHL_7T_Beta_Idv zeros(3,1) ; ...
                %CRB_3T_Beta_Hat CRB_3T_Beta_Hat_CIs CRB_7T_Beta_Hat CRB_7T_Beta_Hat_CIs; ...
                %CRB_3T_Beta_Idv  zeros(3,1) CRB_7T_Beta_Idv zeros(3,1) ];

%BetaHat_array = [BetaHat_array; zeros(16,2)];
%Beta_array    = [BetaHat_array(1,:); BetaIdv_array(1:3,:); ...
%                 BetaHat_array(2,:); BetaIdv_array(1:3,:); ...

%BetaHat_array    = [BetaHat_array; BetaIdv_array];

% writematrix(Beta_array,"BetaOverall_Idv.csv");

%Beta0_array = [USP_3T_Beta0 USP_3T_Beta0_CIs USP_7T_Beta0 USP_7T_Beta0_CIs; ...
%    FER_3T_Beta0 FER_3T_Beta0_CIs FER_7T_Beta0 FER_7T_Beta0_CIs; ...
%    CHL_3T_Beta0 CHL_3T_Beta0_CIs CHL_7T_Beta0 CHL_7T_Beta0_CIs; ...
%    CRB_3T_Beta0 CRB_3T_Beta0_CIs CRB_7T_Beta0 CRB_7T_Beta0_CIs];
%writematrix(Beta0_array,"Beta0.csv");

%clear USP_3T_Beta0 USP_3T_Beta0_CIs USP_7T_Beta0 USP_7T_Beta0_CIs ...
%    FER_3T_Beta0 FER_3T_Beta0_CIs FER_7T_Beta0 FER_7T_Beta0_CIs ...
%    CHL_3T_Beta0 CHL_3T_Beta0_CIs CHL_7T_Beta0 CHL_7T_Beta0_CIs ...
%    CRB_3T_Beta0 CRB_3T_Beta0_CIs CRB_7T_Beta0 CRB_7T_Beta0_CIs

    % cell_array = [TRT_3T; LS_3T; SD_Hat_3T];
    % writecell(cell_array_3T, "Precision_3T.xlsx","UseExcel",true);

%% Reproducibility (Field Strength (FS))

% y3_usp_avg = usp_3T(:,7).*2.893;
% y7_usp_avg = usp_7T(:,7).*7;

% data1 = y3_fer_avg;
% data2 = y7_fer_avg;
% data2_1 = data2-data1;
% avg = mean(data2_1);
% data = [transpose(data1); transpose(data2)];
% FS_ratio = data1./data2;