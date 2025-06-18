%% Wrapper_StatisticalAnalysis_QSM_PH
% ** Bug Fix ** Use "clear All" when "readtable.m" function gives error.
close all
clear 
clc

qsm_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\VSH8_SEPIA\SNRwAVG_MEDI+0';
roi_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis';
output_dir = 'C:\Users\rosly\Documents\QSM_PH\Replicability';

i = { '3T_BL', '3T_BL_Rep', '3T_9mth', '3T_24mth', '3T_24mth_Rep', ...
     '7T_BL', '7T_BL_Rep', '7T_9mth', '7T_24mth', '7T_24mth_Rep'}; 
x=0;

usp_matr = [];
ftn_matr = [];
chl_matr = [];
crb_matr = [];

US_SD=[];
FT_SD=[];
CH_SD=[];
CR_SD=[];

for dataset = i
    x=x+1;

    if contains(dataset{1}, '7T')
        vsz= [.7 .7 .7];
    else
        vsz=[1 1 1];
    end

    usp_Mean = zeros(1,5);
    ftn_Mean = zeros(1,5);
    chl_Mean = zeros(1,5);
    crb_Mean = zeros(1,5);

    qsm=load_untouch_nii(fullfile(qsm_dir, [dataset{1}, '_QSM.nii.gz']));
    roi=load_untouch_nii(fullfile(roi_dir, [dataset{1}(1:2), '_segmentation.nii.gz']));
    if contains(dataset{1}, '7T')
        qsm.img(:,:,1:70)=0;
        roi.img(:,:,1:70)=0;
    end
    qsm = single(qsm.img);

    % Erode ROI
    e_mm = 2;
    e_vox = round(e_mm / min(vsz));
    roi = single(imerode(roi.img, strel('sphere', e_mm)));

    nSamples = 5;
    for i = 1:nSamples
        [~, usp_Mean(:,i)]=std(rmoutliers(qsm(roi==i))); % Q1
        [~, ftn_Mean(:,i)]=std(rmoutliers(qsm(roi==i+5))); % Q2
        [~, chl_Mean(:,i)]=std(rmoutliers(qsm(roi==i+10))); % Q3
        [~, crb_Mean(:,i)]=std(rmoutliers(qsm(roi==i+15))); % Q4
    end

    if contains(dataset{1}, '24mth')
        % Quad1->Quad2
        % Quad2->Quad3
        % Quad3->Quad1
        % Quad4->Quad4
        tmp1=usp_Mean;
        tmp2=ftn_Mean;
        tmp3=chl_Mean;
        usp_Mean=flip(tmp3); % 24mth ROIs were flipped for USP & FER
        ftn_Mean=flip(tmp1);
        chl_Mean=tmp2; 
        tmp4_1 = crb_Mean(:,4);% 24mth ROIs were swapped for CRB
        tmp4_4 = crb_Mean(:,1);
        tmp4_2 = crb_Mean(:,5);
        tmp4_5 = crb_Mean(:,2);
        tmp4_3 = crb_Mean(:,3);
        crb_Mean = [tmp4_1 tmp4_2 tmp4_3 tmp4_4 tmp4_5];
    end

    usp_matr = [usp_matr; usp_Mean];
    ftn_matr = [ftn_matr; ftn_Mean];
    chl_matr = [chl_matr; chl_Mean];
    crb_matr = [crb_matr; crb_Mean];

    fprintf('Processed Dataset %s \n', dataset{1});    
end
matfile=fullfile(output_dir, 'Vars.mat');
save(matfile, 'usp_matr', 'ftn_matr', 'chl_matr', 'crb_matr');

%% TRR ("Test-retest replicability") pairs
clc
clearvars
close all
output_dir = 'C:\Users\rosly\Documents\QSM_PH\Replicability';
matfile=fullfile(output_dir, 'Vars.mat');
load(matfile, 'usp_matr', 'ftn_matr', 'chl_matr', 'crb_matr');

[u_trr_1.r, u_trr_1.lb, u_trr_1.ub] = ICC([usp_matr(4,:); usp_matr(5,:)]');
[u_trr_2.r, u_trr_2.lb, u_trr_2.ub] = ICC([usp_matr(9,:); usp_matr(10,:)]');
[f_trr_1.r, f_trr_1.lb, f_trr_1.ub] = ICC([ftn_matr(4,:); ftn_matr(5,:)]');
[f_trr_2.r, f_trr_2.lb, f_trr_2.ub] = ICC([ftn_matr(9,:); ftn_matr(10,:)]');
[cl_trr_1.r, cl_trr_1.lb, cl_trr_1.ub]=ICC([chl_matr(1,:); chl_matr(2,:)]');
[cl_trr_2.r, cl_trr_2.lb, cl_trr_2.ub]=ICC([chl_matr(6,:); chl_matr(7,:)]');
[cb_trr_1.r, cb_trr_1.lb, cb_trr_1.ub]=ICC([crb_matr(4,:); crb_matr(5,:)]');
[cb_trr_2.r, cb_trr_2.lb, cb_trr_2.ub]=ICC([crb_matr(9,:); crb_matr(10,:)]');

x_labels = {'3T', '7T'};  % These are now the x-axis categories
legend_labels = {'USPIO', 'Ferritin', 'CaCl_2', 'CaCO_3'};  % These will be the legend entries

r = [u_trr_1.r, u_trr_2.r;  % USPIO
     f_trr_1.r, f_trr_2.r;  % Ferritin
     cl_trr_1.r, cl_trr_2.r;  % CaCl2
     cb_trr_1.r, cb_trr_2.r]; % CaCO3

er_low = r - [u_trr_1.lb, u_trr_2.lb;
              f_trr_1.lb, f_trr_2.lb;
              cl_trr_1.lb, cl_trr_2.lb;
              cb_trr_1.lb, cb_trr_2.lb];

er_hi = r - [u_trr_1.ub, u_trr_2.ub;
             f_trr_1.ub, f_trr_2.ub;
             cl_trr_1.ub, cl_trr_2.ub;
             cb_trr_1.ub, cb_trr_2.ub];

% Transpose matrices: Now rows = 3T and 7T, columns = USPIO, Ferritin, etc.
r = r'; er_low = er_low'; er_hi = er_hi';

figure, hold on

% Create grouped bar chart
bh = bar(categorical(x_labels), r, 'grouped');
colororder("glow");

% Add error bars
[ngroups, nbars] = size(r);
groupwidth = min(0.8, nbars / (nbars + 1.5));

for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);  % x positions
    errorbar(x, r(:,i), er_low(:,i), er_hi(:,i), ...
        'k', 'linestyle', 'none', 'LineWidth', 1, 'HandleVisibility', 'off');
end

% Set axis and legend
ylabel('ICC (0-1)');
ylim([0 1]);
pbaspect([1 1 1]);
legend(bh, legend_labels, 'Location', 'bestoutside');

hold off
saveas(gcf, fullfile(output_dir, 'TRR.png'));


%% LDR ("Longitudinal replicability") pairs
clc
clearvars
close all
output_dir = 'C:\Users\rosly\Documents\QSM_PH\Replicability';
matfile=fullfile(output_dir, 'Vars.mat');
load(matfile, 'usp_matr', 'ftn_matr', 'chl_matr', 'crb_matr');

[u_ldr_1.r, u_ldr_1.lb, u_ldr_1.ub] = ICC([mean( [usp_matr(1,:); usp_matr(2,:)], 1); mean( [usp_matr(3,:); usp_matr(4,:); usp_matr(5,:)], 1 )]');
[u_ldr_2.r, u_ldr_2.lb, u_ldr_2.ub] = ICC([mean( [usp_matr(6,:); usp_matr(7,:)], 1); mean( [usp_matr(8,:); usp_matr(9,:); usp_matr(10,:)], 1 )]');
[f_ldr_1.r, f_ldr_1.lb, f_ldr_1.ub] = ICC([mean( [ftn_matr(1,:); ftn_matr(2,:)], 1); mean( [ftn_matr(3,:); ftn_matr(4,:); ftn_matr(5,:)], 1)]');
[f_ldr_2.r, f_ldr_2.lb, f_ldr_2.ub] = ICC([mean( [ftn_matr(6,:); ftn_matr(7,:)], 1); mean( [ftn_matr(8,:); ftn_matr(9,:); ftn_matr(10,:)], 1)]');
[cl_ldr_1.r, cl_ldr_1.lb, cl_ldr_1.ub]=ICC([mean([chl_matr(1,:); chl_matr(2,:)], 1); chl_matr(3,:)]');
[cl_ldr_2.r, cl_ldr_2.lb, cl_ldr_2.ub]=ICC([mean([chl_matr(6,:); chl_matr(7,:)], 1); chl_matr(8,:)]');
[cb_ldr_1.r, cb_ldr_1.lb, cb_ldr_1.ub]=ICC([crb_matr(3,:); mean( [ crb_matr(4,:); crb_matr(5,:)], 1 )]');
[cb_ldr_2.r, cb_ldr_2.lb, cb_ldr_2.ub]=ICC([crb_matr(8,:); mean( [ crb_matr(9,:); crb_matr(10,:)], 1 )]');

x_labels = {'3T', '7T'};  % These are now the x-axis categories
legend_labels = {'USPIO', 'Ferritin', 'CaCl_2', 'CaCO_3'};  % These will be the legend entries

r = [u_ldr_1.r, u_ldr_2.r;  % USPIO
     f_ldr_1.r, f_ldr_2.r;  % Ferritin
     cl_ldr_1.r, cl_ldr_2.r;  % CaCl2
     cb_ldr_1.r, cb_ldr_2.r]; % CaCO3

er_low = r - [u_ldr_1.lb, u_ldr_2.lb;
              f_ldr_1.lb, f_ldr_2.lb;
              cl_ldr_1.lb, cl_ldr_2.lb;
              cb_ldr_1.lb, cb_ldr_2.lb];

er_hi = r - [u_ldr_1.ub, u_ldr_2.ub;
             f_ldr_1.ub, f_ldr_2.ub;
             cl_ldr_1.ub, cl_ldr_2.ub;
             cb_ldr_1.ub, cb_ldr_2.ub];

% Transpose matrices: Now rows = 3T and 7T, columns = USPIO, Ferritin, etc.
r = r'; er_low = er_low'; er_hi = er_hi';

figure, hold on

% Create grouped bar chart
bh = bar(categorical(x_labels), r, 'grouped');
colororder("glow");

% Add error bars
[ngroups, nbars] = size(r);
groupwidth = min(0.8, nbars / (nbars + 1.5));

for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);  % x positions
    errorbar(x, r(:,i), er_low(:,i), er_hi(:,i), ...
        'k', 'linestyle', 'none', 'LineWidth', 1, 'HandleVisibility', 'off');
end

% Set axis and legend
ylabel('ICC (0-1)');
ylim([0 1]);
pbaspect([1 1 1]);
legend(bh, legend_labels, 'Location', 'bestoutside');

hold off
saveas(gcf, fullfile(output_dir, 'LDR.png'));


%% FSR ("Field-strength replicability") pairs
clc
clearvars
close all
output_dir = 'C:\Users\rosly\Documents\QSM_PH\Replicability';
matfile=fullfile(output_dir, 'Vars.mat');
load(matfile, 'usp_matr', 'ftn_matr', 'chl_matr', 'crb_matr');

[u_fsr.r, u_fsr.lb, u_fsr.ub] = ICC([mean(usp_matr(1:5,:), 1); mean(usp_matr(6:10, :), 1)]');
[f_fsr.r, f_fsr.lb, f_fsr.ub] = ICC([mean(ftn_matr(1:5,:), 1); mean(ftn_matr(6:10, :), 1)]');
[cl_fsr.r, cl_fsr.lb, cl_fsr.ub]=ICC([mean(chl_matr(1:3, :), 1); mean(chl_matr(6:8, :), 1)]');
[cb_fsr.r, cb_fsr.lb, cb_fsr.ub]=ICC([mean(crb_matr(3:5, :), 1); mean(crb_matr(8:10, :), 1)]');

x_labels = {'3 T versus 7 T'};  % These are now the x-axis categories
legend_labels = {'USPIO', 'Ferritin', 'CaCl_2', 'CaCO_3'};  % These will be the legend entries

r = [u_fsr.r; % USPIO
     f_fsr.r;  % Ferritin
     cl_fsr.r;  % CaCl2
     cb_fsr.r]; % CaCO3

er_low = r - [u_fsr.lb;
              f_fsr.lb;
              cl_fsr.lb;
              cb_fsr.lb];

er_hi = r - [u_fsr.ub;
             f_fsr.ub;
             cl_fsr.ub;
             cb_fsr.ub];

% Transpose matrices: Now rows = 3T and 7T, columns = USPIO, Ferritin, etc.
r = r'; er_low = er_low'; er_hi = er_hi';

figure, hold on

% Create grouped bar chart
bh = bar(categorical(x_labels), r, 'grouped');
colororder("glow");

% Remove USPIO from analysis (but keep the same "colororder")
delete(bh(1)); 
r=r(:,2:4);
er_low=er_low(:,2:4);
er_hi=er_hi(:,2:4);

% Add error bars
[ngroups, nbars] = size(r);
groupwidth = min(0.8, nbars / (nbars + 1.5));

for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);  % x positions
    errorbar(x, r(:,i), er_low(:,i), er_hi(:,i), ...
        'k', 'linestyle', 'none', 'LineWidth', 1, 'HandleVisibility', 'off');
end

% Set axis and legend
ylabel('ICC (0-1)');
ylim([0 1]);
pbaspect([1 1 1]);
legend(bh(2:end), legend_labels(2:end), 'Location', 'bestoutside');
% legend(bh, legend_labels, 'Location', 'bestoutside');

hold off
saveas(gcf, fullfile(output_dir, 'FSR.png'));



% [Data] = DataRead(param, qsm_dir, roi_dir);
% [DataTRR] = ExtractPairsforTRR(Data);
% [DataLDR] = ExtractPairsforLDR(Data);
% [DataFSR] = ExtractPairsforFSR(Data);
% [TRR_ICC, LDR_ICC, FSR_ICC, TV_ICC] = Wrapper_ICC(DataTRR, DataLDR, DataFSR);