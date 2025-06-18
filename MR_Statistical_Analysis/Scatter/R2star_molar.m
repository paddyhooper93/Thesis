% R2star_scatter.m
% Least squares linear regression between iron concentration and R2star

clc
clearvars
close all
param = 'R2s';
ext = 'NormalTEs';
path_to = 'C:\Users\rosly\Documents\QSM_PH\Analysis\R2s_SDC\';
path_to_data = fullfile(path_to, ext); 
eval(strcat('cd',32,path_to_data));

hdr = struct();
if ~isfield(hdr, 'NoScatter')
    hdr.NoScatter = false;
end

[Data] = DataRead(param);
[Data_FSR] = ExtractPairsforFSR(Data);
[DataSD] = DataReadSD(param);
[DataSD_FSR] = ExtractPairsforFSR(DataSD);

x.usp = (10:5:30)./ 55.845; % mmol/L
x.usp_plt = [0,43.75] ./ 55.845;
x.fer = (210:90:570) ./ 55.845;
x.fer_plt = [0,650] ./ 55.845;
x.chl = (0.1:0.1:0.5)./110.98.*1000; 
x.chl_plt = [0,0.45]./110.98.*1000;
x.crb = (0.1:0.1:0.5)./100.0869.*1000;
x.crb_plt = [0,0.55]./100.0869.*1000; 

labels = {'3 T','7 T'};  

%% Production Uncertainty

uncert.usp = 5 ./ (20:10:60) .* x.usp; % mmol/L
% uncert_usp = [3.44 3.80 4.26 4.78 5.34] ./ 55.845;
uncert.fer = 5 ./ (420:180:1140) .* x.fer; % (mmol/L)

fields = fieldnames(uncert);

for i = 1:length(fields)
    varName = fields{i};
    absValue = uncert.(varName);
    relValue = absValue ./ x.(varName) .* 100;
    if mean(relValue) < 10
        fprintf('%s uncertainty: %f mmol/L, %f pc < 10pc, leave off plot \n', varName, mean(absValue), mean(relValue));
    else
        fprintf('%s uncertainty: %f mmol/L, %f pc > 10pc, include on plot \n', varName, mean(absValue), mean(relValue));
    end
end

%% USPIO

y3_usp_mean = Data_FSR.USP(:,1);
y3_usp_SD = DataSD_FSR.USP(:,1);
y7_usp_mean = Data_FSR.USP(:,2);
y7_usp_SD = DataSD_FSR.USP(:,2);

y3_usp_mdl = fitlm(x.usp,y3_usp_mean);
y7_usp_mdl = fitlm(x.usp,y7_usp_mean);
y3_usp_line = y3_usp_mdl.Coefficients{2,1}.*x.usp_plt + y3_usp_mdl.Coefficients{1,1};
y7_usp_line = y7_usp_mdl.Coefficients{2,1}.*x.usp_plt + y7_usp_mdl.Coefficients{1,1};
f = fittype('a*x+b');
c_algo1 = fit(transpose(x.usp),(y3_usp_mean),f);
algo1_PI95 = predint(c_algo1,x.usp); 
c_algo2 = fit(transpose(x.usp),(y7_usp_mean),f);
algo2_PI95 = predint(c_algo2,x.usp);

if ~hdr.NoScatter


s = get(0, 'ScreenSize');
figure('Position', [0 0 s(3) s(4)]);

err1 = errorbar(x.usp,y3_usp_mean,y3_usp_SD,y3_usp_SD,uncert.usp,uncert.usp,'o');
err1.Color = "b";
err1.CapSize = 30;
hold on

err2 = errorbar(x.usp,y7_usp_mean,y7_usp_SD,y7_usp_SD,uncert.usp,uncert.usp,'o');
err2.Color = "r";
err2.CapSize = 30;
hold on

p_main = plot(x.usp,y3_usp_mean,x.usp,y7_usp_mean);
p_main(1).Marker = '.';
p_main(1).MarkerSize = 30;
p_main(2).Marker = '.';
p_main(2).MarkerSize = 30;
p_main(1).MarkerEdgeColor = 'b';
p_main(2).MarkerEdgeColor = 'r';
p_main(1).MarkerFaceColor = 'b';
p_main(2).MarkerFaceColor = 'r';
p_main(1).LineStyle = 'none';
p_main(2).LineStyle = 'none';
hold on

p_regression = plot(x.usp_plt,y3_usp_line,x.usp_plt,y7_usp_line);
p_regression(1).LineStyle = '--';
p_regression(1).Color = "b";
p_regression(2).LineStyle = '--';
p_regression(2).Color = "r";
pbaspect([1 1 1])
hold on

p_CI = plot(x.usp,algo1_PI95,x.usp,algo2_PI95);
p_CI(1,1).Color = "b";
p_CI(2,1).Color = "b";
p_CI(3,1).Color = "r";
p_CI(4,1).Color = "r";
 
legend(labels,'Location','northwest','interpreter','latex','FontSize',32);
xlim([0 0.6])
ylim([0 75]);

xlabel('USPIO [cFe] (mmol/L)','interpreter','latex','fontsize',32);
ylabel('R$_2^*$ ($s^{-1}$)','interpreter','latex','FontSize', 32)

x.usp_ticks = [(x.usp(1) - (x.usp(2)-x.usp(1))) x.usp];
xticks(x.usp_ticks(1:6))
xticklabels(compose("%.2f", x.usp_ticks(1:6)));
yticks([0, 20, 40, 60]);
yticklabels({'0', '20', '40', '60'});

ax = gca; % current axes
ax.FontSizeMode = 'manual';
ax.FontSize = 26;
% Save data
saveas(gcf,fullfile(path_to_data,strcat(param,'_USPIO_scatter.png')));

end

%% FERRITIN

y3_fer_mean = Data_FSR.FER(:,1);
y3_fer_SD = DataSD_FSR.FER(:,1);
y7_fer_mean = Data_FSR.FER(:,2);
y7_fer_SD = DataSD_FSR.FER(:,2);

y3_fer_mdl = fitlm(x.fer,y3_fer_mean);
y7_fer_mdl = fitlm(x.fer,y7_fer_mean);
y3_fer_line = y3_fer_mdl.Coefficients{2,1}.*x.fer_plt + y3_fer_mdl.Coefficients{1,1};
y7_fer_line = y7_fer_mdl.Coefficients{2,1}.*x.fer_plt + y7_fer_mdl.Coefficients{1,1};
f = fittype('a*x+b');
c_algo3 = fit(transpose(x.fer),(y3_fer_mean),f);
algo3_PI95 = predint(c_algo3,x.fer); 
c_algo4 = fit(transpose(x.fer),(y7_fer_mean),f);
algo4_PI95 = predint(c_algo4,x.fer);

if ~hdr.NoScatter

s = get(0, 'ScreenSize');
figure('Position', [0 0 s(3) s(4)]);

err1 = errorbar(x.fer,y3_fer_mean,y3_fer_SD,y3_fer_SD,'o');
err1.Color = "b";
err1.CapSize = 30;
hold on

err2 = errorbar(x.fer,y7_fer_mean,y7_fer_SD,y7_fer_SD,'o');
err2.Color = "r";
err2.CapSize = 30;
hold on

p_main = plot(x.fer,y3_fer_mean,x.fer,y7_fer_mean);
p_main(1).Marker = '.';
p_main(1).MarkerSize = 30;
p_main(2).Marker = '.';
p_main(2).MarkerSize = 30;
p_main(1).MarkerEdgeColor = 'b';
p_main(2).MarkerEdgeColor = 'r';
p_main(1).MarkerFaceColor = 'b';
p_main(2).MarkerFaceColor = 'r';
p_main(1).LineStyle = 'none';
p_main(2).LineStyle = 'none';
hold on

p_regression = plot(x.fer_plt,y3_fer_line,x.fer_plt,y7_fer_line);
p_regression(1).LineStyle = '--';
p_regression(1).Color = "b";
p_regression(2).LineStyle = '--';
p_regression(2).Color = "r";
pbaspect([1 1 1])
hold on

p_CI = plot(x.fer,algo3_PI95,x.fer,algo4_PI95);
p_CI(1,1).Color = "b";
p_CI(2,1).Color = "b";
p_CI(3,1).Color = "r";
p_CI(4,1).Color = "r";
 
legend(labels,'Location','northwest','FontSize', 32,'interpreter','latex');
xlim([0 12]);
ylim([0 45]);

xlabel('Ferritin [cFe] (mmol/L)','interpreter','latex','fontsize',32);
ylabel('R$_2^*$ ($s^{-1}$)','interpreter','latex','FontSize', 32);

x.fer_diff = x.fer(2)-x.fer(1);
x.fer_ticks = [(x.fer(1)-2*x.fer_diff), (x.fer(1)-x.fer_diff), x.fer];
xticks(x.fer_ticks)
xticklabels(compose("%.1f", x.fer_ticks));
y_fer_ticks = 0:10:40;
yticks(y_fer_ticks);
yticklabels(compose("%.1f", y_fer_ticks));
% xticks([0 2 4 6 8 10])
% xticklabels({'0', '2', '4', '6', '8', '10'});
% yticks([0 10 20 30 40])
% yticklabels({'0','10','20','30','40'});

ax = gca; % current axes
ax.FontSizeMode = 'manual';
ax.FontSize = 26;

saveas(gcf,fullfile(path_to_data,strcat(param,'_Ferritin_scatter.png')));

end

%% CALCIUM CHLORIDE

y3_chl_mean = Data_FSR.CHL(:,1);
y3_chl_SD = DataSD_FSR.CHL(:,1);
y7_chl_mean = Data_FSR.CHL(:,2);
y7_chl_SD = DataSD_FSR.CHL(:,2);

% ratio_FS = (y7_chl_mean-y3_chl_mean);
% 
% y3_chl_M_avg = mean(y3_chl_mean(1:4));
% y3_chl_SD_avg = std(y3_chl_mean(1:4));
% y7_chl_M_avg = mean(y7_chl_mean(1:4));
% y7_chl_SD_avg = std(y7_chl_mean(1:4));

y3_chl_mdl = fitlm(x.chl,y3_chl_mean);
y7_chl_mdl = fitlm(x.chl,y7_chl_mean);
y3_chl_line = y3_chl_mdl.Coefficients{2,1}.*x.chl_plt + y3_chl_mdl.Coefficients{1,1};
y7_chl_line = y7_chl_mdl.Coefficients{2,1}.*x.chl_plt + y7_chl_mdl.Coefficients{1,1};
f = fittype('a*x+b');
c_algo5 = fit(transpose(x.chl),(y3_chl_mean),f);
algo5_PI95 = predint(c_algo5,x.chl); 
c_algo6 = fit(transpose(x.chl),(y7_chl_mean),f);
algo6_PI95 = predint(c_algo6,x.chl);

if ~hdr.NoScatter

s = get(0, 'ScreenSize');
figure('Position', [0 0 s(3) s(4)]);

err1 = errorbar(x.chl,y3_chl_mean,y3_chl_SD,y3_chl_SD,'o');
err1.Color = "b";
err1.CapSize = 30;
hold on

err2 = errorbar(x.chl,y7_chl_mean,y7_chl_SD,y7_chl_SD,'o');
err2.Color = "r";
err2.CapSize = 30;
hold on

p_main = plot(x.chl,y3_chl_mean,x.chl,y7_chl_mean);
p_main(1).Marker = '.';
p_main(1).MarkerSize = 30;
p_main(2).Marker = '.';
p_main(2).MarkerSize = 30;
p_main(1).MarkerEdgeColor = 'b';
p_main(2).MarkerEdgeColor = 'r';
p_main(1).MarkerFaceColor = 'b';
p_main(2).MarkerFaceColor = 'r';
p_main(1).LineStyle = 'none';
p_main(2).LineStyle = 'none';
hold on

p_regression = plot(x.chl_plt,y3_chl_line,x.chl_plt,y7_chl_line);
p_regression(1).LineStyle = '--';
p_regression(1).Color = "b";
p_regression(2).LineStyle = '--';
p_regression(2).Color = "r";
pbaspect([1 1 1])
hold on

p_CI = plot(x.chl,algo5_PI95,x.chl,algo6_PI95);
p_CI(1,1).Color = "b";
p_CI(2,1).Color = "b";
p_CI(3,1).Color = "r";
p_CI(4,1).Color = "r";

legend(labels,'Location','northwest','FontSize', 32,'interpreter','latex');
xlim([0 5]);
ylim([-5 40]);

xticks([0 0.9 1.8 2.7 3.6 4.5])
xticklabels({'0', '0.9', '1.8', '2.7', '3.6', '4.5'})
y_chl_plt = (5:10:35);
yticks(y_chl_plt);
yticklabels(compose("%.0f", y_chl_plt));
% yticklabels({'0', '5', '10', '15', '20', '25', '30'})

xlabel('CaCl$_{2}$ (mol/L)','interpreter','latex','FontSize', 32);
ylabel('R$_2^*$ ($s^{-1}$)','interpreter','latex','FontSize', 32);

ax = gca; % current axes
ax.FontSizeMode = 'manual';
ax.FontSize = 26;

saveas(gcf,fullfile(path_to_data,strcat(param,'_CaCl2_scatter.png')));

end

%% CALCIUM CARBONATE

y3_crb_mean = Data_FSR.CRB(:,1);
y3_crb_SD = DataSD_FSR.CRB(:,1);
y7_crb_mean = Data_FSR.CRB(:,2);
y7_crb_SD = DataSD_FSR.CRB(:,2);

y3_crb_mdl = fitlm(x.crb,y3_crb_mean);
y7_crb_mdl = fitlm(x.crb,y7_crb_mean);
y3_crb_line = y3_crb_mdl.Coefficients{2,1}.*x.crb_plt + y3_crb_mdl.Coefficients{1,1};
y7_crb_line = y7_crb_mdl.Coefficients{2,1}.*x.crb_plt + y7_crb_mdl.Coefficients{1,1};
f = fittype('a*x+b');
c_algo7 = fit(transpose(x.crb),(y3_crb_mean),f);
algo7_PI95 = predint(c_algo7,x.crb); 
c_algo8 = fit(transpose(x.crb),(y7_crb_mean),f);
algo8_PI95 = predint(c_algo8,x.crb);

if ~hdr.NoScatter

s = get(0, 'ScreenSize');
figure('Position', [0 0 s(3) s(4)]);

err1 = errorbar(x.crb,y3_crb_mean,y3_crb_SD,y3_crb_SD,'o');
err1.Color = "b";
err1.CapSize = 30;
hold on

err2 = errorbar(x.crb,y7_crb_mean,y7_crb_SD,y7_crb_SD,'o');
err2.Color = "r";
err2.CapSize = 30;
hold on

p_main = plot(x.crb,y3_crb_mean,x.crb,y7_crb_mean);
p_main(1).Marker = '.';
p_main(1).MarkerSize = 30;
p_main(2).Marker = '.';
p_main(2).MarkerSize = 30;
p_main(1).MarkerEdgeColor = 'b';
p_main(2).MarkerEdgeColor = 'r';
p_main(1).MarkerFaceColor = 'b';
p_main(2).MarkerFaceColor = 'r';
p_main(1).LineStyle = 'none';
p_main(2).LineStyle = 'none';
hold on

p_regression = plot(x.crb_plt,y3_crb_line,x.crb_plt,y7_crb_line);
p_regression(1).LineStyle = '--';
p_regression(1).Color = "b";
p_regression(2).LineStyle = '--';
p_regression(2).Color = "r";
pbaspect([1 1 1])
hold on

p_CI = plot(x.crb,algo7_PI95,x.crb,algo8_PI95);
p_CI(1,1).Color = "b";
p_CI(2,1).Color = "b";
p_CI(3,1).Color = "r";
p_CI(4,1).Color = "r";

legend(labels,'Location','northwest','FontSize', 32,'interpreter','latex');
xlim([0 6]);
ylim([-50 550]);

xticks([0 1 2 3 4 5])
xticklabels({'0', '1', '2', '3', '4', '5'})
yticks([0 100 200 300 400 500])
yticklabels({'0', '100', '200', '300', '400', '500'});

xlabel('CaCO$_{3}$ (mol/L)','interpreter','latex','FontSize', 32);
ylabel('R$_2^*$ ($s^{-1}$)','interpreter','latex','FontSize', 32);

ax = gca; % current axes
ax.FontSizeMode = 'manual';
ax.FontSize = 26;

% Save data
saveas(gcf,fullfile(path_to_data,strcat(param,'_CaCO3_scatter.png')));

end