%Hysteresis_Plot.m
% VSM_Straw_%: Agarose gel & Ferritin (0.57 mg Fe/mL)

clc
clearvars

input_dir = 'C:\vnm\VSM\';
scatter_dir = 'C:\vnm\VSM\Scatter\';
stats_dir = 'C:\vnm\VSM\Stats\';
cd('C:\vnm\VSM\');
sample_file = 'GelOnly';
[A DELIM NHEADERLINES] = importdata('VSM_20220921_GelOnly.dat');


%% Theoretical moment
mm3_to_m3 = 10^(-9);
Sample_Volume = mm3_to_m3*pi*[(2.083^2)*8.7+(1.825^2)*0.4]
% cm3_to_m3 = 10^(-6);
% Sample_Volume = cm3_to_m3*pi*((0.04*(0.365/2)^2)+0.87*((0.4166/2)^2)); % in units m^3
chi_w = -9.04*10^(-6); %dimensionless
H = 5; %T
mu_0 = 10^(7) / (4*pi); % A/m.T
Am2_to_emu = 10^(3); %Am2/emu
mu_w = chi_w*Sample_Volume*H*mu_0*Am2_to_emu; %emu


%% Inputs for plotting hysteresis graph


% Sample data
Applied_Field = A.data(:,1); %   Applied field (digital) in Tesla
Moment_Raw = 10^5.*A.data(:,3); %      Moment in \mu-emu
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

%% Descriptive statistics



%% Least squares linear fitting

% Confidence bounds
f = fittype('a*x+b');
c_sample = fit(Applied_Field,Moment_Raw,f);
linear_model = fitlm(Applied_Field, Moment_Raw);
CI95 = confint(c_sample); % Confidence bounds on coefficients
PI95 = predint(c_sample,Applied_Field); % Prediction bounds on fits

%% Scatter

figure('Position',[400 75 500 300])
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);

set(gca,'GridColor',"k",'GridAlpha',0.5,'MinorGridAlpha',0.5);
ax = gca; % current axes
ax.FontSizeMode = 'manual';
ax.FontSize = 32;

grid on
grid minor

p1 = scatter(Applied_Field,Moment_Raw,'MarkerEdgeColor',[.5 .5 .5])
hold on 

% % fitlm
mdl1 = fitlm(Applied_Field,Moment_Raw);
moment_5T = mdl1.Coefficients.Estimate(2)*5+mdl1.Coefficients.Estimate(1);

% relative_noise = Moment_Raw - mdl1.Fitted;

% p3 = scatter(Applied_Field,relative_noise,'MarkerEdgeColor',[0 0 0]);
% hold on

p2 = plot(Applied_Field,mdl1.Fitted);
p2.LineStyle = '--';
p2.Color = [.5 .5 .5];
hold on

p5 = plot(Applied_Field,PI95);
labels = {'Measurement','Point estimate','lower PB', 'upper PB'}; 
lgd = legend(labels,'Location','northwest','FontSize', 12);
title(lgd,'Legend')
ylim([-500,500]);
subtitle('Hysteresis loop, gel only', 'FontSize', 16)
xlabel('Applied field (Tesla)', 'FontSize', 16);
ylabel('Moment ($\mu_{m}$, 10$^{-5}$emu)','interpreter','latex','FontSize', 16)
grid on
grid minor

saveas(gcf,strcat(scatter_dir,strcat(sample_file,'_RelativeNoise.svg')));


%% Stats

%m3_to_m3 = 10^(-6);
%Sample_Volume = cm3_to_m3*pi*((4.166/2)^2)*0.91; %

Magnetization = Moment_Raw./Sample_Volume;

% % fitlm
mdl2 = fitlm(Applied_Field,Magnetization);
m1 = mdl2.Coefficients{2,1};
b1 = mdl2.Coefficients{1,1};

% % Write coefficient estimates, SE, and p-value (that coefficients are zero) to file
Coefficients = [mdl2.Coefficients(2,:); mdl2.Coefficients(1,:)];
writetable(Coefficients,strcat(stats_dir,strcat(sample_file,'_Coefficients.csv')));

% % Write R-Squared, RMSE values to file
Goodness_fit = array2table([mdl2.RMSE mdl2.Rsquared.Adjusted],"VariableNames",["RMSE","Adjusted R-Squared"]);
writetable([Goodness_fit],strcat(stats_dir,strcat(sample_file,'_Goodness_Fit.csv')));

% % Fitted Moment_Raw at 3 T and UHF
StdDev = mean(PI95(:,2) - mdl1.Fitted);
moment_3T = mdl2.Coefficients.Estimate(2).*2.893 + mdl2.Coefficients.Estimate(1);
moment_7T = mdl2.Coefficients.Estimate(2).*5 + mdl2.Coefficients.Estimate(1);

% magnetic field in SI units (A/m)
Tesla_to_Aperm = 10^7 / (4*pi);
H_3T = 2.893 * Tesla_to_Aperm;
H_7T = 5 * Tesla_to_Aperm;

% Chi = dimensionless .* 10^6 to get ppm
ppm = 10^6;
chi_3T = moment_3T ./ H_3T .* ppm;
chi_7T = moment_7T ./ H_7T .* ppm;

% StdDev = mean(PI95(:,2) - mdl.Fitted);

fitted_values = array2table([ moment_3T moment_7T chi_3T chi_7T StdDev], "VariableNames", ["moment_3T (A/m)","moment_5T (A/m)", "chi_3T (ppm)", "chi_5T (ppm)","StdDev"]);
writetable(fitted_values,strcat(stats_dir,strcat(sample_file,'_Fitted_Values.csv')));
    