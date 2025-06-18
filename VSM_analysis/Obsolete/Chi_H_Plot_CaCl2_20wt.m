%Hysteresis_Plot.m

clc
clearvars

input_dir = 'C:\vnm\VSM_221205\';
scatter_dir = 'C:\vnm\VSM_221205\Scatter\';
stats_dir = 'C:\vnm\VSM_221205\Stats\';
% cd('C:\vnm\VSM_221103\');
load('221205.mat');

sample_file = 'CaCl2_20wt';

%% Inputs for plotting hysteresis graph
mm3_to_m3 = 10^(-9);
Sample_Volume = mm3_to_m3*pi*(3.5^2)*9.5; % in units m^3. Cylinder shape: 3.5 mm radius, 9.5 mm length

% Sample data
Applied_Field_str = strcat(sample_file,".B_analog_T"); 
Applied_Field = eval(Applied_Field_str); % Applied field in Tesla
Tesla_to_Aperm = 10^7 / (4*pi);
Applied_Field_SI = Applied_Field * Tesla_to_Aperm;
moment_raw_str = strcat(sample_file,".moment_emu");
moment_raw = eval(moment_raw_str); % Measured magnetic moment in emu

% moment in SI units
moment_SI = moment_raw.*10^(-3); % emu to Am^2
moment_vol = moment_SI ./ [Sample_Volume]; % Am^2 to A/m

% Magnetic susceptibility (ppm)
% Chi = dimensionless .* 10^6 to get ppm
ppm = 10^6;
chi_dimensionless = moment_vol ./ Applied_Field_SI * ppm;


%% Remove end data points when the gradient coil switches direction
chi_dimensionless(Applied_Field>4.995) = [];
Applied_Field(Applied_Field>4.995) = [];
chi_dimensionless(Applied_Field<-4.995) = [];
Applied_Field(Applied_Field<-4.995) = [];
filter = Applied_Field >= -0.05 & Applied_Field <= 0.05;
chi_dimensionless(filter) = [];
Applied_Field(filter) = [];
% % fitlm
mdl = fitlm(Applied_Field,chi_dimensionless);
m1 = mdl.Coefficients{2,1};
b1 = mdl.Coefficients{1,1};

% Confidence bounds
f = fittype('a*x+b');
c_sample = fit(Applied_Field,chi_dimensionless,f);
CI95 = confint(c_sample); % Confidence bounds on coefficients
PI95 = predint(c_sample,Applied_Field); % Prediction bounds on fits


% % Write coefficient estimates, SE, and p-value (that coefficients are zero) to file
Coefficients = [mdl.Coefficients(2,:); mdl.Coefficients(1,:)];
writetable(Coefficients,strcat(stats_dir,strcat(sample_file,'_Coefficients.csv')));

% % Write R-Squared, RMSE values to file
Goodness_fit = array2table([mdl.RMSE mdl.Rsquared.Adjusted],"VariableNames",["RMSE","Adjusted R-Squared"]);
writetable([Goodness_fit],strcat(stats_dir,strcat(sample_file,'_Goodness_Fit.csv')));

% Calculate chi (in ppm) from fit
chi_3T = mdl.Coefficients.Estimate(2).*2.893 + mdl.Coefficients.Estimate(1);
chi_7T = mdl.Coefficients.Estimate(2).*6.981 + mdl.Coefficients.Estimate(1);

% 
% % magnetic field in SI units (A/m)
% Tesla_to_Aperm = 10^7 / (4*pi);
% H_3T = 3 * Tesla_to_Aperm;
% H_7T = 7 * Tesla_to_Aperm;
% 
% 
wtpercent = 20; % wt.%
% chi_3T = moment_3T ./ H_3T .* ppm;
% chi_7T = moment_7T ./ H_7T .* ppm;
chi_3T_perwt = chi_3T ./ wtpercent;
chi_7T_perwt = chi_7T ./ wtpercent;

StdDev = mean(PI95(:,2) - mdl.Fitted);

fitted_values = array2table([chi_3T chi_7T StdDev chi_3T_perwt chi_7T_perwt], "VariableNames", ["chi_3T (ppm)", "chi_7T (ppm)","StdDev","chi_3T (ppm/wt.%)", "chi_7T (ppm/wt.%)"]);
writetable(fitted_values,strcat(stats_dir,strcat(sample_file,'_Fitted_Values.csv')));
    
% Scatter plot 
figure('Position',[400 75 500 300])
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);

grid on
grid minor

p1 = scatter(Applied_Field,chi_dimensionless,'MarkerEdgeColor',[.5 .5 .5])
hold on 

p2 = plot(Applied_Field,mdl.Fitted);
p2.LineStyle = '--';
p2.Color = [.5 .5 .5];
hold on



p5 = plot(Applied_Field,PI95);
labels = {'Measurement','Least squares regression','lower PB', 'upper PB'}; 
lgd = legend(labels,'Location','northwest','FontSize', 9);
title(lgd,'Legend')
subtitle('Hysteresis loop, calcium chloride 20 wt.%', 'FontSize', 16)
xlabel('Applied field (Tesla)', 'FontSize', 16);
ylabel('Magnetic susceptibility (ppm)', 'FontSize', 16)
grid on
grid minor

saveas(gcf,strcat(scatter_dir,strcat(sample_file,'_Chi_H.svg')));
