%% HSF_Ref_Reverse.m

clc
clearvars

fer_susceptibility = 1.3; %ppm.[mL/mgFe]
fer_iron_conc = 8.5; %mgFe/mL

%% ppm.[mL/mgFe] to Am^-1/T.[mL/mgFe]
ppm = 10^6;
Tesla_per_Aperm = (4*pi) / 10^7;
Aperm_per_Tesla = 10^7 / (4*pi); % Am^-1 / T
fer_magnetization_perunit = fer_susceptibility*Aperm_per_Tesla/ppm; % Am^-1/T.[mL/mgFe]

%% Am^-1/T.[mL/mgFe] to Am^-1/T

fer_magnetization = fer_magnetization_perunit * fer_iron_conc; % Am^-1/T

%% Am^-1/T to Am^2/T

Sample_Volume = pi*(0.2^2)*1*10^(-6);
fer_moment = fer_magnetization*Sample_Volume; %Am^2/T