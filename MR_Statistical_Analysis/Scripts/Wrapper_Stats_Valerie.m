function Wrapper_Stats_Valerie(dir_stats, flag_rmvstraw)

if nargin < 2
    flag_rmvstraw = false;
end


close all

% QSM_fn_3T = 'QSM_SMV3_FLIRT';
% QSM_fn_7T = 'QSM_SMV3_FLIRT';
QSM_fn_3T = 'QSM0_FLIRT';
QSM_fn_7T = 'QSM0_FLIRT';
% QSM_fn_7T = 'QSM_SMV2_FLIRT';

%dir_stats = 'C:\Users\rosly\Documents\Valerie_PH\Stats';
cd(dir_stats)



% Bland-Altman input vars
Title = '';
if flag_rmvstraw
    gnames = {'Fe\_Low', 'Fe\_High', 'Ca\_Low', 'Ca\_High'};
else
    gnames = {'Str\_Prll', 'Str\_Perp', 'Fe\_Low', 'Fe\_High', 'Ca\_Low', 'Ca\_High'};
end

%% Part 1: Reliability, MEDI+0 (Neutral vs Angulations)
dir_MEDI = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\MEDI0';
[Data_3T_NvsA] = Obtain_MEDI_Data('3T', 6, dir_MEDI, QSM_fn_3T, flag_rmvstraw);
[Data_7T_NvsA] = Obtain_MEDI_Data('7T', 6, dir_MEDI, QSM_fn_7T, flag_rmvstraw);

Data_3T_A = ObtainMeanStruct(Data_3T_NvsA, 6, 2);
Data_7T_A = ObtainMeanStruct(Data_7T_NvsA, 6, 2);

orientations = 2:6;
for i = orientations
    Reliability_NvsA_3T.(sprintf('Orient_%d', i)) = calculateICC(Data_3T_NvsA.Orient_1, Data_3T_NvsA.(sprintf('Orient_%d', i)));
    Reliability_NvsA_7T.(sprintf('Orient_%d', i)) = calculateICC(Data_7T_NvsA.Orient_1, Data_7T_NvsA.(sprintf('Orient_%d', i)));
end

% orient_init = 2;
Reliability_NvsA_3T.(sprintf('AVG')) = calculateICC(Data_3T_NvsA.Orient_1, Data_3T_A);
Reliability_NvsA_7T.(sprintf('AVG')) = calculateICC(Data_7T_NvsA.Orient_1, Data_7T_A);

Label = {'\chi_{3T, 1}', '\chi_{3T, 2to6}', 'ppm'};
BA_stats = struct();
[~, ~, BA_stats.NvsA_3T] = BlandAltman(struct2array(Data_3T_NvsA.Orient_1), struct2array(Data_3T_A), ...
    Label, Title, gnames);
saveas(gcf,fullfile(dir_stats,'BA_MEDI0_3T_NvsA.png'));
Label = {'\chi_{7T, 1}', '\chi_{7T, 2to6}', 'ppm'};
[~, ~, BA_stats.NvsA_7T] = BlandAltman(struct2array(Data_7T_NvsA.Orient_1), struct2array(Data_7T_A), ...
    Label, Title, gnames);
saveas(gcf,fullfile(dir_stats,'BA_MEDI0_7T_NvsA.png'));
%% Part 2a: Reliability and BA plot, MEDI+0 (3T vs 7T)
orientations = 1:6;
for i = orientations
    [Data_3T_Mean] = ObtainMeanStruct(Data_3T_NvsA, i);
    [Data_7T_Mean] = ObtainMeanStruct(Data_7T_NvsA, i);
end

Label = {'\chi_{3T, MEDI+0}', '\chi_{7T, MEDI+0}', 'ppm'};

[~, ~, BA_stats.MEDI_3Tvs7T] = BlandAltman(struct2array(Data_3T_Mean), struct2array(Data_7T_Mean), ...
    Label, Title, gnames);

saveas(gcf,fullfile(dir_stats,'BA_MEDI_3Tvs7T.png'));

orientations = 1:6;
for i = orientations
    Reliability_MEDI_3Tvs7T.(sprintf('Orient_%d', i)) = calculateICC(Data_3T_NvsA.(sprintf('Orient_%d', i)), Data_7T_NvsA.(sprintf('Orient_%d', i)));
end

Reliability_MEDI_3Tvs7T.('AVG') = calculateICC(Data_3T_Mean, Data_7T_Mean);

%% Part 2b: Reliability and BA plot, COSMOS (3T vs 7T)
dir_COSMOS = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\COSMOS_SNRwAVG_PDF\deGibbs';
Recon_Method = 'CF'; %'LSQR'

orientations = 3:6;
for i = orientations
    [Data_3T_COSMOS] = Obtain_COSMOS_Data('3T', i, dir_COSMOS, Recon_Method, flag_rmvstraw);
    [Data_7T_COSMOS] = Obtain_COSMOS_Data('7T', i, dir_COSMOS, Recon_Method, flag_rmvstraw);
    Reliability_COSMOS_3Tvs7T.(sprintf('Orient_%d', i)) = calculateICC(Data_3T_COSMOS, Data_7T_COSMOS);
end
%%
opt_Norient_3T = 6;
opt_Norient_7T = 5;

COSMOS_opt_3T = Obtain_COSMOS_Data('3T', opt_Norient_3T, dir_COSMOS, Recon_Method, flag_rmvstraw);
COSMOS_opt_7T = Obtain_COSMOS_Data('7T', opt_Norient_7T, dir_COSMOS, Recon_Method, flag_rmvstraw);
Reliability_COSMOS_3Tvs7T.('OPT') = calculateICC(COSMOS_opt_3T, COSMOS_opt_7T);

Label = {'\chi_{COSMOS, 3T}', '\chi_{COSMOS, 7T}', 'ppm'};
[~, ~, BA_stats.COSMOS_3Tvs7T] = BlandAltman(struct2array(COSMOS_opt_3T), struct2array(COSMOS_opt_7T), ...
    Label, Title, gnames);
saveas(gcf,fullfile(dir_stats,'BA_COSMOS_3Tvs7T.png'));


%% Part 3: Reliability and BA plot, QSM Algorithm (COSMOS vs MEDI)

orientations = 1:6;
for i = orientations
    Reliability_MEDIvsCOSMOS_3T.(sprintf('Orient_%d', i)) = calculateICC(Data_3T_NvsA.(sprintf('Orient_%d', i)), COSMOS_opt_3T);
    Reliability_MEDIvsCOSMOS_7T.(sprintf('Orient_%d', i)) = calculateICC(Data_7T_NvsA.(sprintf('Orient_%d', i)), COSMOS_opt_7T);
end

Reliability_MEDIvsCOSMOS_3T.('AVG') = calculateICC(Data_3T_Mean, COSMOS_opt_3T);
Reliability_MEDIvsCOSMOS_7T.('AVG') = calculateICC(Data_7T_Mean, COSMOS_opt_7T);

Label = {'\chi_{COSMOS, 3T}', '\chi_{MEDI+0, 3T}', 'ppm'};
[~, ~, BA_stats.COSMOSvsMEDI0_3T] = BlandAltman(struct2array(COSMOS_opt_3T), struct2array(Data_3T_Mean), ...
    Label, Title, gnames, 'data1Mode', 'Truth');

saveas(gcf,fullfile(dir_stats,'BA_3T_COSMOSvsMEDI0.png'));

Label = {'\chi_{COSMOS, 7T}', '\chi_{MEDI+0, 7T}', 'ppm'};
[~, ~, BA_stats.COSMOSvsMEDI0_7T] = BlandAltman(struct2array(COSMOS_opt_7T), struct2array(Data_7T_Mean), ...
    Label, Title, gnames, 'data1Mode', 'Truth');

% Fit_7T = fitlm(struct2array(COSMOS_opt_7T), struct2array(Data_7T_Mean));

saveas(gcf,fullfile(dir_stats,'BA_7T_COSMOSvsMEDI0.png'));


%% Part 4: Accuracy, QSM Algorithm (MEDI vs Inf Cyl)
gnames = {'Str\_Prll', 'Str\_Perp', 'Fe\_Low', 'Fe\_High'};
Fe_Low_GT = 0.0766*3.76;
Fe_High_GT = 0.0766*10.21;



save(fullfile(dir_stats, 'icc_stats.mat'),  "Reliability_NvsA_3T",...
    "Reliability_NvsA_7T", "Reliability_MEDIvsCOSMOS_3T", "Reliability_MEDIvsCOSMOS_7T", ...
    "Reliability_COSMOS_3Tvs7T", "Reliability_MEDI_3Tvs7T", "BA_stats")

% dir_Delta = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\COSMOS_SNRwAVG_PDF\Num_Orient_6';
% [chi_InfCyl_3T] = Obtain_InfCyl_Data('3T', 6, dir_Delta);
% [chi_InfCyl_7T] = Obtain_InfCyl_Data('7T', 6, dir_Delta);




