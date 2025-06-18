%Hysteresis_Plot.m
% VSM_Straw_%: Agarose gel & Ferritin (0.57 mg Fe/mL)

clc
clearvars


input_dir = 'C:\Users\rosly\Documents\VSM_RawData\';
scatter_dir = 'C:\Users\rosly\Documents\VSM_Scatter\';
stats_dir = 'C:\Users\rosly\Documents\VSM_Stats\';
sample_file = 'Ferritin 10-21mM';
[A DELIM NHEADERLINES] = importdata('sample 1.dat');

%% Inputs for plotting hysteresis graph

% Sample data
Applied_Field = A.data(:,1); %   Applied field (digital) in Tesla
Moment_SI = 10^(-3).*A.data(:,3); % emu to Am^2
Moment_SI = 10^(6).*Moment_SI; % Am^2 to $\mu$Am^2
ampl = A.data(:,7);


% Moment_Raw in SI units, Ampheres per meter

% Moment_Raw = Moment_SI ./ [Sample_Volume]; % Am^2 to A/m

%% Remove end data points when the gradient coil switches direction
Moment_SI(Applied_Field>4.95) = [];
ampl(Applied_Field>4.95) = [];
Applied_Field(Applied_Field>4.95) = [];
Moment_SI(Applied_Field<-4.95) = [];
ampl(Applied_Field<-4.95) = [];
Applied_Field(Applied_Field<-4.95) = [];



%% percentage outliers

outliers = isoutlier(Moment_SI);
num_zero = sum( outliers == 0 );
num_ones = sum( outliers == 1 );

percentage_outliers = num_ones./num_zero.*100;


%% fitlm
% Confidence bounds
f = fittype('a*x+b');
c_sample = fit(Applied_Field,Moment_SI,f);
CI95 = confint(c_sample); % Confidence bounds on coefficients
PI95 = predint(c_sample,Applied_Field); % Prediction bounds on fits

%% Scatter  
figure('Position',[400 75 500 300])
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
grid on
grid minor

p1 = scatter(Applied_Field,Moment_SI,'MarkerEdgeColor',[.5 .5 .5]);
hold on 

mdl1 = fitlm(Applied_Field,Moment_SI);
moment_5T = mdl1.Coefficients.Estimate(2)*5+mdl1.Coefficients.Estimate(1);

p2 = plot(Applied_Field,mdl1.Fitted);
p2.LineStyle = '--';
p2.Color = [.5 .5 .5];
hold on

p3 = plot(Applied_Field,PI95);
labels = {'Measurement','Line of best fit','lower PB', 'upper PB'}; 
lgd = legend(labels,'Location','northwest','FontSize', 12);
title(lgd,'Legend')
ylim([-5,5]);
subtitle('m vs \textbf{H}, ferritin 10.21 mM','interpreter','latex', 'FontSize', 16)
xlabel('Applied field (\textbf{H}, Tesla)','interpreter','latex', 'FontSize', 16);
ylabel('Moment (m, $\mu$A$\cdot$m$^2$)','interpreter','latex','FontSize', 16)

saveas(gcf,strcat(scatter_dir,strcat(sample_file,'_m_versus_H_scatter.png')));

%% Plot sensor amplitude (mm?)

% Confidence bounds
f = fittype('a*x+b');
c_sample = fit(Applied_Field,Moment_SI,f);
CI95 = confint(c_sample); % Confidence bounds on coefficients
PI95 = predint(c_sample,Applied_Field); % Prediction bounds on fits

figure('Position',[400 75 500 300])
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
grid on
grid minor

p4 = scatter(Applied_Field,ampl,'MarkerEdgeColor',[.5 .5 .5]);
hold on

mdl_ampl = fitlm(Applied_Field,ampl);

p5 = plot(Applied_Field,mdl_ampl.Fitted);
p5.LineStyle = '--';
p5.Color = [.5 .5 .5];
hold on

p6 = plot(Applied_Field,PI95);
labels = {'Measurement','Line of best fit','lower PB', 'upper PB'}; 
lgd = legend(labels,'Location','northwest','FontSize', 12);
title(lgd,'Legend')
subtitle('A vs \textbf{H}, ferritin 10.21 mM','interpreter','latex', 'FontSize', 16)
xlabel('Applied field (\textbf{H}, Tesla)','interpreter','latex', 'FontSize', 16);
ylabel('Sensor Amplitude (A, mm)','interpreter','latex','FontSize', 16)

saveas(gcf,strcat(scatter_dir,strcat(sample_file,'_Ampl_versus_H_scatter.png')));

%% Theoretical moment
mm3_to_m3 = 10^(-9);
Sample_Volume = mm3_to_m3*pi*((2.083^2)*8.7+(1.825^2)*0.4);

% diamagnetic contribution at 5 T in ppm
chi_w = -9.04*10^(-6); % ppm
H = 5; % T
mu_0 = 10^(7) / (4*pi); % A/m.T
Am2_to_emu = 10^(3); %Am2/emu
mu_w = chi_w*Sample_Volume*H*mu_0*Am2_to_emu; %emu

% paramagnetic contribution at 5 T in ppm
chi_ferritin = 1.33*10^(-6); %ppm ./ mgFepermL;
c_Fe = 0.57; % mg Fe / mL
mu_para = chi_ferritin * c_Fe * Sample_Volume * H * mu_0 *Am2_to_emu; %emu


%% fitlm
% mdl2 = fitlm(Applied_Field,Magnetization);
% m1 = mdl2.Coefficients{2,1};
% b1 = mdl2.Coefficients{1,1};
% 
% % relative_noise = Moment_Raw - mdl.Fitted; 
% % p3 = scatter(Applied_Field,relative_noise,'MarkerEdgeColor',[0 0 0]);
% % hold on
% 
% % % Write coefficient estimates, SE, and p-value (that coefficients are zero) to file
% Coefficients = [mdl2.Coefficients(2,:); mdl2.Coefficients(1,:)];
% writetable(Coefficients,strcat(stats_dir,strcat(sample_file,'_Coefficients.csv')));
% 
% % % Write R-Squared, RMSE values to file
% Goodness_fit = array2table([mdl2.RMSE mdl2.Rsquared.Adjusted],"VariableNames",["RMSE","Adjusted R-Squared"]);
% writetable([Goodness_fit],strcat(stats_dir,strcat(sample_file,'_Goodness_Fit.csv')));
% 
% % % Fitted magnetic moment in A/m
% StdDev = mean(PI95(:,2) - mdl2.Fitted);
% magnetization_3T = mdl2.Coefficients.Estimate(2).*2.893 + mdl2.Coefficients.Estimate(1);
% magnetization_5T = mdl2.Coefficients.Estimate(2).*5 + mdl2.Coefficients.Estimate(1);

% Chi = dimensionless .* 10^6 to get ppm
% uemu / (A/m)
ppm = 10^6;

% magnetic field in SI units (A/m)
% 1 G = 10^-4 T
% 1 G = 10^3/(4\pi) A/m
% 1 T = 10^7/(4\pi) A/m

mu_0 = 10^(7) / (4*pi); % A/m.T
H_3T = 2.893 / mu_0;
H_5T = 5 / mu_0;



% chi_3T = magnetization_3T ./ H_3T .* ppm;
% chi_5T = magnetization_5T ./ H_5T .* ppm;
% chi_3T_percFe = chi_3T ./ c_Fe; 
% chi_5T_percFe = chi_5T ./ c_Fe; 

% fitted_values = array2table([ magnetization_3T magnetization_5T StdDev chi_3T chi_5T chi_3T_percFe chi_5T_percFe], "VariableNames", ["moment_3T (\muemu)", "moment_5T (\muemu)","StdDev (\muemu)","chi_3T (ppm)","chi_5T (ppm)","chi_3T (ppm/[mgFe/mL])","chi_5T (ppm/[mgFe/mL])"]);
% writetable(fitted_values,strcat(stats_dir,strcat(sample_file,'_Fitted_Values.csv')));
    
% %% Gel_Correction
% 
% Gel_Fit = readtable(strcat(stats_dir,'GelOnly_Fitted_Values.csv'));
% Gel_chi_3T_permgFepermL = Gel_Fit{1,3} ./ mgFepermL;
% Gel_chi_7T_permgFepermL = Gel_Fit{1,4} ./ mgFepermL;
% 
% chi_3T_corrected = chi_3T_permgFepermL - Gel_chi_3T_permgFepermL;
% chi_7T_corrected = chi_7T_permgFepermL - Gel_chi_7T_permgFepermL;
% fitted_values_corrected = array2table([chi_3T_corrected chi_7T_corrected],"VariableNames", ["chi_3T_corrected", "chi_7T_corrected"]);
% writetable(fitted_values_corrected,strcat(stats_dir,strcat(sample_file,'_Fitted_Values_corrected.csv')));
