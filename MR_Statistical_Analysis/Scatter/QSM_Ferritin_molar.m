%% QSM_Scatter_Ferritin.m
% Least sqauares linear regression between [cFe] and Chi

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

y3_fer_mean = Data_FSR.FER(:,1);
y3_fer_SD = DataSD_FSR.FER(:,1);
y7_fer_mean = Data_FSR.FER(:,2);
y7_fer_SD = DataSD_FSR.FER(:,2);

x_fer = (210 : 90 : 570) ./ 55.845; % (mmol/L)
% uncert = 5 ./ (420:180:1140) .* x_fer; % (mmol/L)
x_fer_plt = [0,650] ./ 55.845;

FS_ratio = mean(y3_fer_mean ./ y7_fer_mean);

%% Obtain coefficient
y3_mdl = fitlm(x_fer,y3_fer_mean);
y7_mdl = fitlm(x_fer,y7_fer_mean);
y3_line =  y3_mdl.Coefficients{2,1}.*x_fer_plt + y3_mdl.Coefficients{1,1};
y7_line =  y7_mdl.Coefficients{2,1}.*x_fer_plt + y7_mdl.Coefficients{1,1};

% Test for influential and outlying points
% Cook's D threshold (influential points): 50th percentile of the F-dist.
% For n = 5, p = 1; v1 = 2, v2 = 3
t_cookd = finv(0.5,2,3);
ind_y3_infl = find(y3_mdl.Diagnostics.CooksDistance > t_cookd);
ind_y7_infl = find(y7_mdl.Diagnostics.CooksDistance > t_cookd);
% plotDiagnostics(y3_mdl,'cookd')
% legend('show')

% Stud. Res threshold (outlying points): 95th percentile of t-dist. 
% For n = 5, p = 1; v = 4
t_stud_res = tinv(0.95,4);
ind_y3_outlier = find(y3_mdl.Residuals.Studentized > t_stud_res);
ind_y7_outlier = find(y7_mdl.Residuals.Studentized > t_stud_res);
% plotResiduals(y3_mdl,'fitted','ResidualType','studentized')
% legend('show')
%% Obtain prediction bounds
f = fittype('a*x+b');
c_algo1 = fit(transpose(x_fer),y3_fer_mean,f);
algo1_PI95 = predint(c_algo1,x_fer); 

c_algo2 = fit(transpose(x_fer),y7_fer_mean,f);
algo2_PI95 = predint(c_algo2,x_fer);

%% 3 T Experimental

s = get(0, 'ScreenSize');
figure('Position', [0 0 s(3) s(4)]);
pbaspect([1 1 1])

err1 = errorbar(x_fer,y3_fer_mean,y3_fer_SD,y3_fer_SD,'o');
err1.Color = "b";
err1.CapSize = 30;
hold on

err2 = errorbar(x_fer,y7_fer_mean,y7_fer_SD,y7_fer_SD,'o');
err2.Color = "r";
err2.CapSize = 30;
hold on

p_main = plot(x_fer,y3_fer_mean,x_fer,y7_fer_mean);
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


p_regression = plot(x_fer_plt,y3_line,x_fer_plt,y7_line);
p_regression(1).LineStyle = '--';
p_regression(1).Color = "b";
p_regression(2).LineStyle = '--';
p_regression(2).Color = "r";
pbaspect([1 1 1])
hold on

p_CI = plot(x_fer,algo1_PI95,x_fer,algo2_PI95);
p_CI(1,1).Color = "b";
p_CI(2,1).Color = "b";
p_CI(3,1).Color = "r";
p_CI(4,1).Color = "r";

xlim([0 12]);
ylim([-0.1, 1.0]);

x_fer_diff = x_fer(2)-x_fer(1);
x_fer_plt = [(x_fer(1)-2*x_fer_diff), (x_fer(1)-x_fer_diff), x_fer];
xticks(x_fer_plt)
xticklabels(compose("%.1f", x_fer_plt));
y_fer_plt = 0:0.2:0.8;
yticks(y_fer_plt);
yticklabels(compose("%.1f", y_fer_plt));

ax = gca; % current axes
ax.FontSizeMode = 'manual';
ax.FontSize = 26;
% set(gca,'GridColor',"k",'GridAlpha',0.5,'MinorGridAlpha',0.5)

xlabel('Ferritin [cFe] (mmol/L)', 'interpreter','latex','fontsize',32);
ylabel('$\chi$ (ppm)','interpreter','latex','fontsize',32)

% grid on
  
legend({'3 T','7 T'},'location','northwest','FontSize', 32,'interpreter','latex');

% Save data
saveas(gcf,fullfile(path_to_data,'Ferritin_QSM_scatter.png'));