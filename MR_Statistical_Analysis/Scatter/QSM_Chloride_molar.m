%% QSM_Scatter_Chloride.m
% Linear regression between iron concentration and Chi

clc
clearvars
close all
param = 'QSM';
ext = 'MEDI+0';
path_to = 'C:\Users\rosly\Documents\QSM_PH\Analysis\VSH8_SEPIA_Idpt\';
path_to_data = fullfile(path_to, ext); 
eval(strcat('cd',32,path_to_data));

[Data] = DataRead(param);
[Data_FSR] = ExtractPairsforFSR(Data);
[DataSD] = DataReadSD(param);
[DataSD_FSR] = ExtractPairsforFSR(DataSD);

% 10 wt.\% = 10 g/100mL = 0.1 g/mL
% molar mass: 110.98 g/mol
x_chl = (0.1:0.1:0.5)./110.98.*1000; % mol/L
x_chl_plt = [0,0.55]./110.98.*1000; % mol/L

y3_chl_mean = Data_FSR.CHL(:,1);
y3_chl_SD = DataSD_FSR.CHL(:,1);
y7_chl_mean = Data_FSR.CHL(:,2);
y7_chl_SD = DataSD_FSR.CHL(:,2);

%% Obtain coefficient
y3_mdl_spu = fitlm(x_chl,y3_chl_mean);
y7_mdl_spu = fitlm(x_chl,y7_chl_mean);
y3_line_spu =  y3_mdl_spu.Coefficients{2,1}.*x_chl_plt + y3_mdl_spu.Coefficients{1,1};
y7_line_spu =  y7_mdl_spu.Coefficients{2,1}.*x_chl_plt + y7_mdl_spu.Coefficients{1,1};

%% Obtain prediction bounds
f = fittype('a*x+b');
c_algo1 = fit(transpose(x_chl),(y3_chl_mean),f);
algo1_PI95 = predint(c_algo1,x_chl); 

c_algo2 = fit(transpose(x_chl),(y7_chl_mean),f);
algo2_PI95 = predint(c_algo2,x_chl);

%% 3 T Exp'm

s = get(0, 'ScreenSize');
figure('Position', [0 0 s(3) s(4)]);
pbaspect([1 1 1])

err1 = errorbar(x_chl,y3_chl_mean,y3_chl_SD,y3_chl_SD,'o');
err1.Color = "b";
err1.CapSize = 30;
hold on

err2 = errorbar(x_chl,y7_chl_mean,y7_chl_SD,y7_chl_SD,'o');
err2.Color = "r";
err2.CapSize = 30;
hold on

p_main = plot(x_chl,y3_chl_mean,x_chl,y7_chl_mean);
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


p_regression = plot(x_chl_plt,y3_line_spu,x_chl_plt,y7_line_spu);
p_regression(1).LineStyle = '--';
p_regression(1).Color = "b";
p_regression(2).LineStyle = '--';
p_regression(2).Color = "r";
pbaspect([1 1 1])
hold on

p_CI = plot(x_chl,algo1_PI95,x_chl,algo2_PI95);
p_CI(1,1).Color = "b";
p_CI(2,1).Color = "b";
p_CI(3,1).Color = "r";
p_CI(4,1).Color = "r";


xlim([0 5]);
ylim([-1.4 0]);

ax = gca; % current axes
ax.FontSizeMode = 'manual';
ax.FontSize = 26;

xlabel('CaCl$_{2}$ (mol/L)','interpreter','latex','fontsize',32);
ylabel('$\chi$ (ppm)','interpreter','latex','fontsize',32)

xticks([0 0.9 1.8 2.7 3.6, 4.5])
xticklabels({'0', '0.9', '1.8', '2.7', '3.6', '4.5'})

y_chl_plt = -1.2:0.4:0;
yticks(y_chl_plt);
yticklabels(compose("%.1f", y_chl_plt));
% yticks([-1.0, -.8, -.4, 0])% yticklabels({'-1.2', '-0.8', '-0.4', '0'})

legend({'3 T','7 T'},'location','northeast','FontSize', 32,'interpreter','latex');

% Save data
saveas(gcf,fullfile(path_to_data,'CaCl2_QSM_scatter.png'));
