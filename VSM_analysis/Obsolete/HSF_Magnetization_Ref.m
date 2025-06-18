%% HSF_Ref.m

clc
clearvars
% Reading off fig 6a (Moment: 4.8 Am^2, Field 5.0 T, Moment: 4.0 Am^2, Field 2.0 T)
% page 224427-3 (PHYSICAL REVIEW B 73, 224427 (2006))
% Converting from (Am^2 / kg) to (Am^2 / mg)
moment = 4.8; %Am^2 / mg
Sample_Volume = pi*(0.35^2)*0.95*10^(-6); % in units m^3. Cylinder shape: 0.35 cm radius, 0.95 cm length (UNC No.8)
magnetization = moment / Sample_Volume; % Am^-1 / mg

%% Convert field strength from Tesla to Am^-1 
Aperm_per_Tesla = 10^7 / (4*pi); % Am^-1 / T
field_strength = 7 * Aperm_per_Tesla; % Am^-1

%% Divide moment by field strength (ppm/mg)
ppm = 10^6;
m3_to_mL = 10^6;
susceptibility = ppm*magnetization/field_strength/m3_to_mL;

%% HoSF content: 65 mg
HoSF_content = 65;
susceptibility_ppm = susceptibility*HoSF_content;

% %% (Unitless) to ppm/[mgFe/mL]
% % hsf_iron_conc = 8.5; %mgFe/mL
% ppm = 10^6;
% hsf_SPU = hsf_susceptibility * ppm;
% % hsf_SPU = hsf_susceptibility / hsf_iron_conc * ppm;