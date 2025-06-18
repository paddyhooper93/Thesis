%% QSM_Scatter_Carbonate.m
% Linear regression between iron concentration and Chi

clc
clearvars
close all
param = 'QSM';
ext = 'SNRwAVG_MEDI+0';
path_to = 'C:\Users\rosly\Documents\QSM_PH\Analysis\VSH8_SEPIA\';
path_to_data = fullfile(path_to, ext); 
eval(strcat('cd',32,path_to_data));

[Data] = DataRead(param);
[Data_FSR] = ExtractPairsforFSR(Data);
[DataSD] = DataReadSD(param);
[DataSD_FSR] = ExtractPairsforFSR(DataSD);

% 10 wt.\% = 10 g/100mL = 0.1 g/mL
% molar mass: 100.0869 g/mol
x_crb = (0.1:0.1:0.5)./100.0869.*1000; % mol/L
x_crb_7T = (0.1:0.1:0.5)./100.0869.*1000; % mol/L
x_crb_plt = [0,0.55]./100.0869.*1000; % mol/L

y3_crb_mean = Data_FSR.CRB(:,1);
y3_crb_SD = DataSD_FSR.CRB(:,1);
y7_crb_mean = Data_FSR.CRB(:,2);
y7_crb_SD = DataSD_FSR.CRB(:,2);

%% Obtain coefficient
y3_mdl = fitlm(x_crb,y3_crb_mean);
y7_mdl = fitlm(x_crb_7T,y7_crb_mean);

%% Obtain line-of-best-fit

y3_line =  y3_mdl.Coefficients{2,1}.*x_crb_plt + y3_mdl.Coefficients{1,1};
y7_line =  y7_mdl.Coefficients{2,1}.*x_crb_plt + y7_mdl.Coefficients{1,1};

%% Obtain prediction bounds
f = fittype('a*x+b');
c_algo1 = fit(transpose(x_crb),(y3_crb_mean),f);
algo1_PI95 = predint(c_algo1,x_crb); 

c_algo2 = fit(transpose(x_crb_7T),(y7_crb_mean),f);
algo2_PI95 = predint(c_algo2,x_crb_7T);

%% Exp'm
s = get(0, 'ScreenSize');
figure('Position', [0 0 s(3) s(4)]);
pbaspect([1 1 1])

err1 = errorbar(x_crb,y3_crb_mean,y3_crb_SD,y3_crb_SD,'o');
err1.Color = "b";
err1.CapSize = 30;
hold on

err2 = errorbar(x_crb_7T,y7_crb_mean,y7_crb_SD,y7_crb_SD,'o');
err2.Color = "r";
err2.CapSize = 30;
hold on

p_main = plot(x_crb,y3_crb_mean,x_crb_7T,y7_crb_mean);
p_main(1).Marker = '.';
p_main(1).MarkerSize = 30;
p_main(2).Marker = '.';
p_main(2).MarkerSize = 30;
p_main(1).MarkerEdgeColor = "b";
p_main(2).MarkerEdgeColor = "r";
p_main(1).MarkerFaceColor = "b";
p_main(2).MarkerFaceColor = "r";
p_main(1).LineStyle = 'none';
p_main(2).LineStyle = 'none';
hold on

p_regression = plot(x_crb_plt,y3_line,x_crb_plt,y7_line);
p_regression(1).LineStyle = '--';
p_regression(1).Color = "b";
p_regression(2).LineStyle = '--';
p_regression(2).Color = "r";
pbaspect([1 1 1])
hold on

p_CI = plot(x_crb,algo1_PI95,x_crb_7T,algo2_PI95);
p_CI(1,1).Color = "b";
p_CI(2,1).Color = "b";
p_CI(3,1).Color = "r";
p_CI(4,1).Color = "r";

xlim([0 6]);
ylim([-0.65 0.10]);

xlabel('CaCO$_{3}$ (mol/L)','interpreter','latex','fontsize',32);
ylabel('$\chi$ (ppm)','interpreter','latex','fontsize',32)

x_crb_plt = 0:1:5;
xticks(x_crb_plt)
xticklabels(compose("%d", x_crb_plt))
y_crb_plt = -0.6:0.2:0;
yticks(y_crb_plt);
yticklabels(compose("%.1f", y_crb_plt));

legend({'3 T','7 T'},'location','northeast','FontSize', 32,'interpreter','latex');
ax = gca; % current axes
ax.FontSizeMode = 'manual';
ax.FontSize = 26;
% Save data
saveas(gcf,fullfile(path_to_data,'CaCO3_QSM_scatter.png'));
