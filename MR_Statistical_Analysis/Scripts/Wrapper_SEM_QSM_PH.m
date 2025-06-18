%% Wrapper_SEM_QSM_PH
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
CL_SD=[];
CB_SD=[];

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

    usp_SD   = zeros(1,5);
    ftn_SD   = zeros(1,5);
    chl_SD   = zeros(1,5);
    crb_SD   = zeros(1,5);
    
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
        [usp_SD(:,i), usp_Mean(:,i)]=std(qsm(roi==i)); % Q1
        [ftn_SD(:,i), ftn_Mean(:,i)]=std(qsm(roi==i+5)); % Q2
        [chl_SD(:,i), chl_Mean(:,i)]=std(qsm(roi==i+10)); % Q3
        [crb_SD(:,i), crb_Mean(:,i)]=std(qsm(roi==i+15)); % Q4
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
        tmp4_1 = crb_Mean(:,4);% 24mth ROIs were swapped for CBB
        tmp4_4 = crb_Mean(:,1);
        tmp4_2 = crb_Mean(:,5);
        tmp4_5 = crb_Mean(:,2);
        tmp4_3 = crb_Mean(:,3);
        crb_Mean = [tmp4_1 tmp4_2 tmp4_3 tmp4_4 tmp4_5];

        % Repeat the same process but for standard deviation
        tmp5=usp_SD;
        tmp6=ftn_SD;
        tmp7=chl_SD;
        usp_SD=flip(tmp7);
        ftn_SD=flip(tmp5);
        chl_SD=tmp6;
        tmp8_1=crb_SD(:,4);
        tmp8_4=crb_SD(:,1);
        tmp8_2=crb_SD(:,5);
        tmp8_5=crb_SD(:,2);
        tmp8_3=crb_SD(:,3);
        crb_SD=[tmp8_1 tmp8_2 tmp8_3 tmp8_4 tmp8_5];
    end

    usp_matr = [usp_matr; usp_Mean];
    ftn_matr = [ftn_matr; ftn_Mean];
    chl_matr = [chl_matr; chl_Mean];
    crb_matr = [crb_matr; crb_Mean];

    US_SD=[US_SD; 1e3.*usp_SD];
    FT_SD=[FT_SD; 1e3.*ftn_SD];
    CL_SD=[CL_SD; 1e3.*chl_SD];
    CB_SD=[CB_SD; 1e3.*crb_SD];
    fprintf('Processed Dataset %s \n', dataset{1});    
end
matfile=fullfile(output_dir, 'Vars.mat');
save(matfile, 'usp_matr', 'ftn_matr', 'chl_matr', 'crb_matr', 'US_SD', 'FT_SD', 'CL_SD', 'CB_SD');

%% TRR ("Test-retest replicability") pairs
clc
clearvars
close all
output_dir = 'C:\Users\rosly\Documents\QSM_PH\Replicability';
matfile=fullfile(output_dir, 'Vars.mat');
load(matfile, 'usp_matr', 'ftn_matr', 'chl_matr', 'crb_matr', 'US_SD', 'FT_SD', 'CL_SD', 'CB_SD');

US_SD=[mean(US_SD(1:5,:), 1); mean(US_SD(6:10,:), 1)];
FT_SD=[mean(FT_SD(1:5,:), 1); mean(FT_SD(6:10,:), 1)];
CL_SD=[mean(CL_SD(1:3,:), 1); mean(CL_SD(6:8,:), 1)];
CB_SD=[mean(CB_SD(3:5,:), 1); mean(CB_SD(8:10,:), 1)];

[icc.u_1, ~] = ICC([usp_matr(1,:); usp_matr(2,:)]');
[icc.u_2, ~] = ICC([usp_matr(6,:); usp_matr(7,:)]');
[icc.f_1, ~] = ICC([ftn_matr(1,:); ftn_matr(2,:)]');
[icc.f_2, ~] = ICC([ftn_matr(6,:); ftn_matr(7,:)]');
[icc.cl_1, ~]=ICC([chl_matr(1,:); chl_matr(2,:)]');
[icc.cl_2, ~]=ICC([chl_matr(6,:); chl_matr(7,:)]');
[icc.cb_1, ~]=ICC([crb_matr(4,:); crb_matr(5,:)]');
[icc.cb_2, ~]=ICC([crb_matr(9,:); crb_matr(10,:)]');

% SEM from ICC and SD_ROI
[u_1] = US_SD(1,:).*sqrt(1-icc.u_1);
[u_2] = US_SD(2,:).*sqrt(1-icc.u_2);
[f_1] = FT_SD(1,:).*sqrt(1-icc.f_1);
[f_2] = FT_SD(2,:).*sqrt(1-icc.f_2);
[cl_1]= CL_SD(1,:).*sqrt(1-icc.cl_1);
[cl_2]= CL_SD(2,:).*sqrt(1-icc.cl_2);
[cb_1]= CB_SD(1,:).*sqrt(1-icc.cb_1);
[cb_2]= CB_SD(2,:).*sqrt(1-icc.cb_2);

x_labels = {'1', '2', '3', '4', '5'}; 
% x_labels = {'3T', '7T'};  % These are now the x-axis categories
legend_labels = {'USPIO', 'Ferritin', 'CaCl_2', 'CaCO_3'};  % These will be the legend entries

sem_1 = [u_1;  % USPIO
    f_1;  % Ferritin
    cl_1;  % CaCl2
    cb_1]; % CaCO3

sem_2 = [u_2; 
    f_2; 
    cl_2; 
    cb_2];

% Transpose matrices: Now rows = '3T', '7T', etc., columns = USPIO, Ferritin, etc.
%sem_1 = sem_1'; sem_2 = sem_2';

% Find the average for all 5 concentrations
% sem = mean(sem, 2);
% sem_1 = mean(sem_1, 2); sem_2 = mean(sem_2, 2);

figure, hold on

% Create grouped bar chart
bh = bar(categorical(x_labels), sem_2, 'grouped');
colororder("glow");

% Set axis and legend
xlabel('Concentration');
ylabel('SEM (ppb)');
ylim("auto");
pbaspect([1 1 1]);
legend(bh, legend_labels, 'Location', 'bestoutside');

saveas(gcf, fullfile(output_dir, 'SEM_TRR.png'));

% figure, hold on
% 
% % Create grouped bar chart
% bh = bar(categorical(x_labels), sem_2, 'grouped');
% colororder("glow");
% 
% % Set axis and legend
% xlabel('Concentration');
% ylabel('SEM (ppb)');
% ylim("auto");
% pbaspect([1 1 1]);
% legend(bh, legend_labels, 'Location', 'bestoutside');
% 
% hold off
% saveas(gcf, fullfile(output_dir, 'SEM_TRR_2.png'));


%% LDR ("Longitudinal replicability") pairs
clc
clearvars
close all
output_dir = 'C:\Users\rosly\Documents\QSM_PH\Replicability';
matfile=fullfile(output_dir, 'Vars.mat');
load(matfile, 'usp_matr', 'ftn_matr', 'chl_matr', 'crb_matr', 'US_SD', 'FT_SD', 'CL_SD', 'CB_SD');

US_SD=[mean(US_SD(1:5,:), 1); mean(US_SD(6:10,:), 1)];
FT_SD=[mean(FT_SD(1:5,:), 1); mean(FT_SD(6:10,:), 1)];
CL_SD=[mean(CL_SD(1:3,:), 1); mean(CL_SD(6:8,:), 1)];
CB_SD=[mean(CB_SD(3:5,:), 1); mean(CB_SD(8:10,:), 1)];

[icc.u_1, ~] = ICC([mean( [usp_matr(1,:); usp_matr(2,:)], 1); mean( [usp_matr(3,:); usp_matr(4,:); usp_matr(5,:)], 1 )]');
[icc.u_2, ~] = ICC([mean( [usp_matr(6,:); usp_matr(7,:)], 1); mean( [usp_matr(8,:); usp_matr(9,:); usp_matr(10,:)], 1 )]');
[icc.f_1, ~] = ICC([mean( [ftn_matr(1,:); ftn_matr(2,:)], 1); mean( [ftn_matr(3,:); ftn_matr(4,:); ftn_matr(5,:)], 1)]');
[icc.f_2, ~] = ICC([mean( [ftn_matr(6,:); ftn_matr(7,:)], 1); mean( [ftn_matr(8,:); ftn_matr(9,:); ftn_matr(10,:)], 1)]');
[icc.cl_1, ~]=ICC([mean([chl_matr(1,:); chl_matr(2,:)], 1); chl_matr(3,:)]');
[icc.cl_2, ~]=ICC([mean([chl_matr(6,:); chl_matr(7,:)], 1); chl_matr(8,:)]');
[icc.cb_1, ~]=ICC([crb_matr(3,:); mean( [ crb_matr(4,:); crb_matr(5,:)], 1 )]');
[icc.cb_2, ~]=ICC([crb_matr(8,:); mean( [ crb_matr(9,:); crb_matr(10,:)], 1 )]');

x_labels = {'1', '2', '3', '4', '5'};  % These are now the x-axis categories
legend_labels = {'USPIO', 'Ferritin', 'CaCl_2', 'CaCO_3'};  % These will be the legend entries

% SEM from ICC and SD_ROI
[u_1] = US_SD(1,:).*sqrt(1-icc.u_1);
[u_2] = US_SD(2,:).*sqrt(1-icc.u_2);
[f_1] = FT_SD(1,:).*sqrt(1-icc.f_1);
[f_2] = FT_SD(2,:).*sqrt(1-icc.f_2);
[cl_1]= CL_SD(1,:).*sqrt(1-icc.cl_1);
[cl_2]= CL_SD(2,:).*sqrt(1-icc.cl_2);
[cb_1]= CB_SD(1,:).*sqrt(1-icc.cb_1);
[cb_2]= CB_SD(2,:).*sqrt(1-icc.cb_2);

sem_1 = [u_1;  % USPIO
    f_1;  % Ferritin
    cl_1;  % CaCl2
    cb_1]; % CaCO3

sem_2 = [u_2; 
    f_2; 
    cl_2; 
    cb_2];

% Transpose matrices: Now rows = 3T and 7T, columns = USPIO, Ferritin, etc.
sem_1 = sem_1'; sem_2 = sem_2';

figure, hold on

% Create grouped bar chart
bh = bar(categorical(x_labels), sem_1, 'grouped');
colororder("glow");

% Set axis and legend
xlabel('Concentration');
ylabel('SEM (ppb)');
ylim("auto");
pbaspect([1 1 1]);
legend(bh, legend_labels, 'Location', 'bestoutside');

saveas(gcf, fullfile(output_dir, 'SEM_LDR_1.png'));


figure, hold on

% Create grouped bar chart
bh = bar(categorical(x_labels), sem_2, 'grouped');
colororder("glow");

% Set axis and legend
xlabel('Concentration');
ylabel('SEM (ppb)');
ylim("auto");
pbaspect([1 1 1]);
legend(bh, legend_labels, 'Location', 'bestoutside');

hold off
saveas(gcf, fullfile(output_dir, 'SEM_LDR_2.png'));


%% FSR ("Field-strength replicability") pairs
clc
clearvars
close all
output_dir = 'C:\Users\rosly\Documents\QSM_PH\Replicability';
matfile=fullfile(output_dir, 'Vars.mat');
load(matfile, 'usp_matr', 'ftn_matr', 'chl_matr', 'crb_matr', 'US_SD', 'FT_SD', 'CL_SD', 'CB_SD');

[u, u.lb, u.ub] = ICC([mean(usp_matr(1:5,:), 1); mean(usp_matr(6:10, :), 1)]');
[f, f.lb, f.ub] = ICC([mean(ftn_matr(1:5,:), 1); mean(ftn_matr(6:10, :), 1)]');
[cl, cl.lb, cl.ub]=ICC([mean(chl_matr(1:3, :), 1); mean(chl_matr(6:8, :), 1)]');
[cb, cb.lb, cb.ub]=ICC([mean(crb_matr(3:5, :), 1); mean(crb_matr(8:10, :), 1)]');

x_labels = {'3 T versus 7 T'};  % These are now the x-axis categories
legend_labels = {'USPIO', 'Ferritin', 'CaCl_2', 'CaCO_3'};  % These will be the legend entries

sem_1 = [u; % USPIO
     f;  % Ferritin
     cl;  % CaCl2
     cb]; % CaCO3

er_low = sem_1 - [u.lb;
              f.lb;
              cl.lb;
              cb.lb];

er_hi = sem_1 - [u.ub;
             f.ub;
             cl.ub;
             cb.ub];

% Transpose matrices: Now rows = 3T and 7T, columns = USPIO, Ferritin, etc.
sem_1 = sem_1'; er_low = er_low'; er_hi = er_hi';

figure, hold on

% Create grouped bar chart
bh = bar(categorical(x_labels), sem_1, 'grouped');
colororder("glow");

% Remove USPIO from analysis (but keep the same "colororder")
delete(bh(1)); 
sem_1=sem_1(:,2:4);
er_low=er_low(:,2:4);
er_hi=er_hi(:,2:4);

% Add error bars
[ngroups, nbars] = size(sem_1);
groupwidth = min(0.8, nbars / (nbars + 1.5));

for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);  % x positions
    errorbar(x, sem_1(:,i), er_low(:,i), er_hi(:,i), ...
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