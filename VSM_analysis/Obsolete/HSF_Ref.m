%% HSF_Ref.m

clc
clearvars

hsf_ref = 1.96*10^-9; % Am^2 / T (At 300 K, From Brem et al., 2006, page 123906-4)
% 345 u_B
% 2.16 * 10^-6; emu/T
%% Taking into account Fe ions
% LF=4500 Fe ions;
% MW_iron = 55.847 g/mol


%% Am^2 / T to Am^-1 / T

Sample_Volume = pi*(0.2^2)*1*10^(-6); % in units m^3. Cylinder shape: 0.2 cm radius, 1 cm length
hsf_magnetization = hsf_ref / Sample_Volume; % Am^-1 / T
%% Am^-1 / T to Am^-1 / Am^-1 (unitless)
Aperm_per_Tesla = 10^7 / (4*pi); % Am^-1 / T
hsf_susceptibility = hsf_magnetization / Aperm_per_Tesla;

%% (Unitless) to ppm/[mgFe/mL]
% hsf_iron_conc = 8.5; %mgFe/mL
ppm = 10^6;
hsf_SPU = hsf_susceptibility * ppm;
% hsf_SPU = hsf_susceptibility / hsf_iron_conc * ppm;