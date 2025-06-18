% USPIO_Value.m

clc
clear
close all


% Given values
% M_particle_2T = 23.6; % M[A⋅m^2⋅kg^(-1)] at 2 T
% M_particle_7T = 23.6; % M[A⋅m^2⋅kg^(-1)] at 7 T
%
% % Converting from magnetization (per USPIO particle) to magnetization per iron density:
% ferumoxytol_ptcl = 122; % mg⋅mL^(-1)  (particles)
% ferumoxytol_Fe = 30; % mg⋅mL^(-1)  (Fe)
% particle_to_iron = ferumoxytol_ptcl/ferumoxytol_Fe;
% M_Fe_2T = M_particle_2T * particle_to_iron;
% M_Fe_7T = M_particle_7T * particle_to_iron;
M_USPIO_3T = 23.6; % [A⋅m^2⋅kg^(-1)]
M_USPIO_7T = 25.2; % [A⋅m^2⋅kg^(-1)]

N_Fe = 3; % number of magnetic ions per formula unit


% Constants
mu_0 = 4 * pi * 1e-7; % T⋅m⋅A^(-1)
MW_Fe = 0.055845; % kg/mol
B_0_3T = 2.89; % T at 2 T
B_0_7T = 7; % T at 7 T

% Mass susceptibility calculation
chi_mass_3T_th = (M_USPIO_3T * N_Fe) * mu_0 / B_0_3T .* 10^6; % ppm.m^3/mol at 3 T
chi_mass_7T_th = (M_USPIO_7T * N_Fe) * mu_0 / B_0_7T .* 10^6; % ppm.m^3/mol at 7 T

% Mass susceptibility measurements
chi_mass_3T_meas = 27.4; % m^3/mol at 3 T
chi_mass_7T_meas = 12.5; % m^3/mol at 7 T

% Relative error
err_3T = (chi_mass_3T_meas - chi_mass_3T_th) / chi_mass_3T_th * 100;
err_7T = (chi_mass_7T_meas - chi_mass_7T_th) / chi_mass_7T_th * 100;

% Display results
fprintf('Mass susceptibility at 3 T: %s ppm.L/mmol\n', chi_mass_3T_th);
fprintf('Mass susceptibility at 7 T: %s ppm.L/mmol\n', chi_mass_7T_th);
fprintf('Relative error at 3 T: %0.1f %%\n', err_3T);
fprintf('Relative error at 7 T: %0.1f %%\n', err_7T);
fprintf('e-06 m^3/mol = ppm.L/mmol\n');
% fprintf('Susceptibility ratio: %s\n', chi_mol_ratio);