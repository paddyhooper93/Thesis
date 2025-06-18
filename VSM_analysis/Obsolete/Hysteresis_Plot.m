%Hysteresis_Plot.m
% VSM_Straw_%: Agarose gel & Ferritin (0.57 mg Fe/mL)

clc
clearvars

input_dir = 'C:\vnm\VSM_220921\';
scatter_dir = 'C:\vnm\VSM_220921\Scatter\';
stats_dir = 'C:\vnm\VSM_220921\Stats\';
cd('C:\vnm\VSM_220921\');
load('220901.mat');

sample_file = 'Sample5';
gel_ref_file = 'GelOnly';

%% Inputs for calculating mgFe
% Mass = 0.2318; % in units g
% concentration = 0.57; % in units mg Fe/mL
Sample_Volume = pi*(0.3^2)*1; % in units mL. Cylinder shape: 0.6cm diameter, 1 cm length

% Sample data
Applied_Field_str = strcat(sample_file,"_mhl.B_analog_T"); 
Applied_Field = eval(Applied_Field_str); % Applied field in Tesla
moment_raw_str = strcat(sample_file,"_mhl.moment_emu");
moment_raw = eval(moment_raw_str); % Measured magnetic moment in emu

% emu/mgFe = emu ./ [mgFe/mL .* mL]
moment_mgFe = moment_raw ./ [Sample_Volume]; % emu/mL
moment_gFe = moment_mgFe.*10^(3); % emu/mgFe to emu/gFe
% H_in_SI_units = 10^(6) / (4*pi);  Vacuum permittivity
% Can skip this step, since we multiply by 10^6 to convert m^3 to mL
% and we divide by (4*pi) to convert 

%% Remove end data points when the gradient coil switches direction
moment_gFe(Applied_Field>4.95) = [];
Applied_Field(Applied_Field>4.95) = [];
moment_gFe(Applied_Field<-4.95) = [];
Applied_Field(Applied_Field<-4.95) = [];

% % fitlm
mdl = fitlm(Applied_Field,moment_gFe);
m1 = mdl.Coefficients{2,1};
b1 = mdl.Coefficients{1,1};

% Confidence bounds
f = fittype('a*x+b');
c_sample = fit(Applied_Field,moment_gFe,f);
CI95 = confint(c_sample); % Confidence bounds on coefficients
PI95 = predint(c_sample,Applied_Field); % Prediction bounds on fits

% % Write coefficient estimates, SE, and p-value (that coefficients are zero) to file
Coefficients = [mdl.Coefficients(2,:); mdl.Coefficients(1,:)];
writetable(Coefficients,strcat(stats_dir,strcat(sample_file,'_Coefficients.csv')));

% % Write R-Squared, RMSE values to file
Goodness_fit = array2table([mdl.RMSE mdl.Rsquared.Adjusted],"VariableNames",["RMSE","Adjusted R-Squared"]);
writetable([Goodness_fit],strcat(stats_dir,strcat(sample_file,'_Goodness_Fit.csv')));

% % Fitted magnetic moment
moment_3T = mdl.Coefficients.Estimate(2).*3 + mdl.Coefficients.Estimate(1);
moment_7T = mdl.Coefficients.Estimate(2).*7 + mdl.Coefficients.Estimate(1);

chi_3T = moment_3T .* 10^-6 ./ (2.893 * 10^7 / (4*pi)) * 10^6 * 10^6;
chi_7T = moment_7T .* 10^-6 ./ (6.9809 * 10^7 / (4*pi)) * 10^6 * 10^6;

StdDev = mean(PI95(:,2) - mdl.Fitted);

fitted_values = array2table([ moment_3T moment_7T chi_3T chi_7T StdDev], "VariableNames", ["moment_3T","moment_7T", "chi_3T", "chi_7T","StdDev"]);
writetable(fitted_values,strcat(stats_dir,strcat(sample_file,'_Fitted_Values.csv')));
    
% Scatter plot 
figure('Position',[400 75 500 300])
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);

grid on
grid minor

p1 = scatter(Applied_Field,moment_gFe,'MarkerEdgeColor',[.5 .5 .5])
hold on 

p2 = plot(Applied_Field,mdl.Fitted);
p2.LineStyle = '--';
p2.Color = [.5 .5 .5];
hold on



p5 = plot(Applied_Field,PI95);
labels = {'Measurement','Least squares regression','lower PB', 'upper PB'}; 
lgd = legend(labels,'Location','northwest','FontSize', 9);
title(lgd,'Legend')
subtitle('Hysteresis loop, ferritin 0.57 mgFe/mL', 'FontSize', 16)
xlabel('Applied field (Tesla)', 'FontSize', 16);
ylabel('Magnetic moment (emu/gFe)', 'FontSize', 16)
grid on
grid minor

saveas(gcf,strcat(scatter_dir,strcat(sample_file,'_Hysteresis_scatter.svg')));
