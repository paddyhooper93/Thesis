%Hysteresis_Plot.m
% VSM_Straw_%: Agarose gel & Ferritin (0.57 mg Fe/mL)

clc
clearvars

input_dir = 'C:\vnm\VSM_220921\';
scatter_dir = 'C:\vnm\VSM_220921\Scatter\';
stats_dir = 'C:\vnm\VSM_220921\Stats\';
cd('C:\vnm\VSM_220921\');
load('220901.mat');

sample_file = 'GelOnly';

%% Inputs for plotting hysteresis graph
cm3_to_m3 = 10^(-6);
Sample_Volume = cm3_to_m3*pi*(0.3^2)*1; % in units m^3. Cylinder shape: 0.3cm radius, 1 cm length

% Sample data
Applied_Field_str = strcat(sample_file,"_mhl.B_analog_T"); 
Applied_Field = eval(Applied_Field_str); % Applied field in Tesla
moment_raw_str = strcat(sample_file,"_mhl.moment_emu");
moment_raw = eval(moment_raw_str); % Measured magnetic moment in emu

% moment in SI units
moment_SI = moment_raw.*10^(-3); % emu to Am^2
moment_vol = moment_SI ./ [Sample_Volume]; % Am^2 to A/m


%% Remove end data points when the gradient coil switches direction
moment_vol(Applied_Field>4.95) = [];
Applied_Field(Applied_Field>4.95) = [];
moment_vol(Applied_Field<-4.95) = [];
Applied_Field(Applied_Field<-4.95) = [];

% % fitlm
mdl = fitlm(Applied_Field,moment_vol);
m1 = mdl.Coefficients{2,1};
b1 = mdl.Coefficients{1,1};

% Confidence bounds
f = fittype('a*x+b');
c_sample = fit(Applied_Field,moment_vol,f);
CI95 = confint(c_sample); % Confidence bounds on coefficients
PI95 = predint(c_sample,Applied_Field); % Prediction bounds on fits

% % Write coefficient estimates, SE, and p-value (that coefficients are zero) to file
Coefficients = [mdl.Coefficients(2,:); mdl.Coefficients(1,:)];
writetable(Coefficients,strcat(stats_dir,strcat(sample_file,'_Coefficients.csv')));

% % Write R-Squared, RMSE values to file
Goodness_fit = array2table([mdl.RMSE mdl.Rsquared.Adjusted],"VariableNames",["RMSE","Adjusted R-Squared"]);
writetable([Goodness_fit],strcat(stats_dir,strcat(sample_file,'_Goodness_Fit.csv')));

% % Fitted magnetic moment in A/m
moment_3T = mdl.Coefficients.Estimate(2).*2.893 + mdl.Coefficients.Estimate(1);
moment_7T = mdl.Coefficients.Estimate(2).*6.8909 + mdl.Coefficients.Estimate(1);

% magnetic field in SI units (A/m)
Tesla_to_Aperm = 10^7 / (4*pi);
H_3T = 2.893 * Tesla_to_Aperm;
H_7T = 6.9809 * Tesla_to_Aperm;

% Chi = dimensionless .* 10^6 to get ppm
ppm = 10^6;
% conc = 0.57; % mg Fe / mL
chi_3T = moment_3T ./ H_3T .* ppm;
chi_7T = moment_7T ./ H_7T .* ppm;

StdDev = mean(PI95(:,2) - mdl.Fitted);

fitted_values = array2table([ moment_3T moment_7T chi_3T chi_7T StdDev], "VariableNames", ["moment_3T (A/m)","moment_7T (A/m)", "chi_3T (ppm)", "chi_7T (ppm)","StdDev"]);
writetable(fitted_values,strcat(stats_dir,strcat(sample_file,'_Fitted_Values.csv')));
    
% Scatter plot 
figure('Position',[400 75 500 300])
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);

grid on
grid minor

p1 = scatter(Applied_Field,moment_vol,'MarkerEdgeColor',[.5 .5 .5])
hold on 

p2 = plot(Applied_Field,mdl.Fitted);
p2.LineStyle = '--';
p2.Color = [.5 .5 .5];
hold on



p5 = plot(Applied_Field,PI95);
labels = {'Measurement','Least squares regression','lower PB', 'upper PB'}; 
lgd = legend(labels,'Location','northwest','FontSize', 9);
title(lgd,'Legend')
subtitle('Hysteresis loop, gel only', 'FontSize', 16)
xlabel('Applied field (Tesla)', 'FontSize', 16);
ylabel('Volume magnetization (A/m)', 'FontSize', 16)
grid on
grid minor

saveas(gcf,strcat(scatter_dir,strcat(sample_file,'_Hysteresis_scatter.svg')));
