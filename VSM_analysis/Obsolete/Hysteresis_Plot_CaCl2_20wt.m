%Hysteresis_Plot.m

clc
clearvars

input_dir = 'C:\Users\rosly\Documents\VSM_RawData\';
scatter_dir = 'C:\Users\rosly\Documents\VSM_Scatter\';
stats_dir = 'C:\Users\rosly\Documents\VSM_Stats\';
sample_file = 'CaCl2 1.8M';
[A DELIM NHEADERLINES] = importdata('Sample 5_T290_00mhl.dat');

%% Inputs for plotting hysteresis graph

% Sample data
Applied_Field = A.data(:,1); %   Applied field (digital) in Tesla
Moment_Raw = 10^6.*A.data(:,3); %      Moment in $\mu$emu
phs = A.data(:,6);
ampl = A.data(:,7);
time = A.data(:,8);

% Moment_Raw in SI units, Ampheres per meter
% Moment_SI = Moment_Raw.*10^(-3); % emu to Am^2
% Moment_Raw = Moment_SI ./ [Sample_Volume]; % Am^2 to A/m

%% Remove end data points when the gradient coil switches direction
Moment_Raw(Applied_Field>4.95) = [];
Applied_Field(Applied_Field>4.95) = [];
Moment_Raw(Applied_Field<-4.95) = [];
Applied_Field(Applied_Field<-4.95) = [];

%% percentage outliers

outliers = isoutlier(Moment_Raw);
num_zero = sum( outliers == 0 );
num_ones = sum( outliers == 1 );

percentage_outliers = num_ones./num_zero.*100;

%% fitlm
mdl = fitlm(Applied_Field,Moment_Raw);
m1 = mdl.Coefficients{2,1};
b1 = mdl.Coefficients{1,1};

% Confidence bounds
f = fittype('a*x+b');
c_sample = fit(Applied_Field,Moment_Raw,f);
CI95 = confint(c_sample); % Confidence bounds on coefficients
PI95 = predint(c_sample,Applied_Field); % Prediction bounds on fits


%% Theoretical moment
mm3_to_m3 = 10^(-9);
Sample_Volume = mm3_to_m3*pi*((2.083^2)*8.7+(1.825^2)*0.4);

% diamagnetic contribution at 5 T in ppm
chi_w = -9.04*10^(-6); % ppm
H = 5; % T
mu_0 = 10^(7) / (4*pi); % A/m.T
Am2_to_emu = 10^(3); %Am2/emu
mu_w = chi_w*Sample_Volume*H*mu_0*Am2_to_emu; %emu

% Calcium chloride contribution at 5 T in ppm


chi_cacl2 = -61.9*10^(-9); %ppb ./ (wt.\%);
c_cacl2 = 20; % (wt.\%)
mu_cacl2 = chi_cacl2 * c_cacl2* Sample_Volume * H*mu_0*Am2_to_emu; %emu


%% fitlm

moment_vol = Moment_Raw ./ Sample_Volume;
mdl2 = fitlm(Applied_Field,moment_vol);
m1 = mdl2.Coefficients{2,1};
b1 = mdl2.Coefficients{1,1};
% % Write coefficient estimates, SE, and p-value (that coefficients are zero) to file
Coefficients = [mdl2.Coefficients(2,:); mdl2.Coefficients(1,:)];
writetable(Coefficients,strcat(stats_dir,strcat(sample_file,'_Coefficients.csv')));

% % Write R-Squared, RMSE values to file
Goodness_fit = array2table([mdl2.RMSE mdl2.Rsquared.Adjusted],"VariableNames",["RMSE","Adjusted R-Squared"]);
writetable([Goodness_fit],strcat(stats_dir,strcat(sample_file,'_Goodness_Fit.csv')));

% Calculate chi (in ppm) from fit
StdDev = mean(PI95(:,2) - mdl.Fitted);
magnetization_3T = mdl2.Coefficients.Estimate(2).*2.893 + mdl2.Coefficients.Estimate(1);
magnetization_7T = mdl2.Coefficients.Estimate(2).*6.981 + mdl2.Coefficients.Estimate(1);

% magnetic field in SI units (A/m)
Tesla_to_Aperm = 10^7 / (4*pi);
H_3T = 3 * Tesla_to_Aperm;
H_7T = 7 * Tesla_to_Aperm;

% Chi = dimensionless .* 10^6 to get ppm
ppm = 10^6;
wtpercent = 20; % wt.%
chi_3T = magnetization_3T ./ H_3T .* ppm;
chi_7T = magnetization_7T ./ H_7T .* ppm;
chi_3T_perwt = chi_3T ./ wtpercent;
chi_7T_perwt = chi_7T ./ wtpercent;


%%
% magnetic field in SI units (A/m)
% 
mu_0 = 10^(7) / (4*pi); % A/m.T
H_3T = 2.893 / mu_0
H_5T = 5 / mu_0;

% paramagnetic contribution at 5 T in ppm
%%

fitted_values = array2table([ magnetization_3T magnetization_7T StdDev chi_3T chi_7T chi_3T_perwt chi_7T_perwt], "VariableNames", ["magnetization_3T (A/m)", "magnetization_7T (A/m)","StdDev (A/m)","chi_3T (ppm)","chi_7T (ppm)","chi_3T (ppm/[mgFe/mL])","chi_7T (ppm/[mgFe/mL])"]);
writetable(fitted_values,strcat(stats_dir,strcat(sample_file,'_Fitted_Values.csv')));
    
% Scatter plot 
figure('Position',[400 75 500 300])
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);

grid on
grid minor

p1 = scatter(Applied_Field,Moment_Raw,'MarkerEdgeColor',[.5 .5 .5])
hold on 

p2 = plot(Applied_Field,mdl.Fitted);
p2.LineStyle = '--';
p2.Color = [.5 .5 .5];
hold on



p5 = plot(Applied_Field,PI95);
labels = {'Measurement','Point estimate','lower PB', 'upper PB'}; 
lgd = legend(labels,'Location','northwest','FontSize', 12);
title(lgd,'Legend')
ylim([-500,500]);
subtitle('Hysteresis loop, CaCl$_2$ 20 wt.\%','interpreter','latex','FontSize', 16)
xlabel('Applied field (Tesla)', 'FontSize', 16);
ylabel('Moment (m, 10$\mu$emu)','interpreter','latex','FontSize', 16)
grid on
grid minor

saveas(gcf,strcat(scatter_dir,strcat(sample_file,'_Hysteresis_scatter.svg')));
