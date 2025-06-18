%% QSM_Scatter_USPIO.m
% Linear regression between iron concentration and QSM
clear
close all
clc

param = 'L1L2';
ext = 'R2s5_Eddy_GraphCut_NC_RR05';
path_to = 'C:\Users\rosly\Documents\QSM_PH\Analysis\';
path_to_data = fullfile(path_to, ext, param); 
eval(strcat('cd',32,path_to_data));

[Data] = DataRead(param);
[Data_FSR] = ExtractPairsforFSR(Data);
[DataSD] = DataReadSD(param);
[DataSD_FSR] = ExtractPairsforFSR(DataSD);

x_usp = (10:5:30)./ 55.485;% mmol/L
x_usp_plt = (0:6.25:43.75) ./ 55.485;

y3_usp_mean = Data_FSR.USP(:,1).*2.89;
y3_usp_SD = DataSD_FSR.USP(:,1).*2.89;
y7_usp_mean = Data_FSR.USP(:,2).*6.98;
y7_usp_SD = DataSD_FSR.USP(:,2).*6.98;



%% Obtain coefficient
y3_mdl_lm = fitlm(x_usp,y3_usp_mean);
y7_mdl_lm = fitlm(x_usp,y7_usp_mean);

spu_3_plt = y3_mdl_lm.Coefficients{2,1}.* x_usp_plt + y3_mdl_lm.Coefficients{1,1};
spu_7_plt = y7_mdl_lm.Coefficients{2,1}.* x_usp_plt + y7_mdl_lm.Coefficients{1,1};

% Test for linearity
modelfun = @(b,x)(b(1)+b(2).*x+b(3).*x.^2);
beta0 = [0,1,0];
y3_mdl_nlm = fitnlm(x_usp,y3_usp_mean,modelfun,beta0);
y7_mdl_nlm = fitnlm(x_usp,y7_usp_mean,modelfun,beta0);

% Test for influential and outlying points
% Cook's D threshold (influential points): 50th percentile of the F-dist.
% For n = 5, p = 1; v1 = 2, v2 = 3
t_cookd = finv(0.5,2,3);
ind_y3_infl = find(y3_mdl_lm.Diagnostics.CooksDistance > t_cookd);
ind_y7_infl = find(y7_mdl_lm.Diagnostics.CooksDistance > t_cookd);
% plotDiagnostics(y7_mdl_lm,'cookd')
% legend('show')

% Stud. Res threshold (outlying points): 95th percentile of t-dist. 
% For n = 5, p = 1; v = 4
t_stud_res = tinv(0.95,4);
ind_y3_outlier = find(y3_mdl_lm.Residuals.Studentized > t_stud_res);
ind_y7_outlier = find(y7_mdl_lm.Residuals.Studentized > t_stud_res);
% plotResiduals(y7_mdl_lm,'fitted','ResidualType','studentized')
% legend('show')

% Robust fit for linear regression
y3_mdl_lm_robust = fitlm(x_usp,y3_usp_mean,'RobustOpts','on');
y7_mdl_lm_robust = fitlm(x_usp,y7_usp_mean,'RobustOpts','on');


%% Obtain prediction bounds
f = fittype('a*x+b');
c_algo1 = fit(transpose(x_usp),y3_usp_mean,f);
algo1_PI95 = predint(c_algo1,x_usp); 

c_algo2 = fit(transpose(x_usp),y7_usp_mean,f);
algo2_PI95 = predint(c_algo2,x_usp);

%% Experimental

s = get(0, 'ScreenSize');
figure('Position', [0 0 s(3) s(4)]);


err1 = errorbar(x_usp,y3_usp_mean,y3_usp_SD,y3_usp_SD,'o');
err1.Color = "b";
err1.CapSize = 30;
hold on

err2 = errorbar(x_usp,y7_usp_mean,y7_usp_SD,y7_usp_SD,'o');
err2.Color = "r";
err2.CapSize = 30;
hold on


p_main = plot(x_usp,y3_usp_mean,x_usp,y7_usp_mean);
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


p_regression = plot(x_usp_plt,spu_3_plt,x_usp_plt,spu_7_plt);
p_regression(1).LineStyle = '--';
p_regression(1).Color = "b";
p_regression(2).LineStyle = '--';
p_regression(2).Color = "r";
pbaspect([1 1 1])
hold on

% p_CI = plot(x_usp,algo1_PI95,x_usp,algo2_PI95);
% p_CI(1,1).Color = "b";
% p_CI(2,1).Color = "b";
% p_CI(3,1).Color = "r";
% p_CI(4,1).Color = "r";

xlim([0 0.8])
ylim([0 10])

xlabel('[cFe] (mmol/L)','interpreter','latex','fontsize',32);
ylabel('$\chi\cdot B_{0}$ (ppm$\cdot$T)','interpreter','latex','fontsize',32)
xticks([0, 0.1 0.2 0.3 0.4 0.5 0.6 0.7])
xticklabels({'0', '0.1', '0.2', '0.3', '0.4', '0.5', '0.6','0.7'})

legend({'3 T','7 T'},'location','northwest','FontSize', 32,'interpreter','latex');

ax = gca; % current axes
ax.FontSizeMode = 'manual';
ax.FontSize = 32;
saveas(gcf,fullfile(path_to_data,'USPIO_QSMTimesB0_scatter.png'));