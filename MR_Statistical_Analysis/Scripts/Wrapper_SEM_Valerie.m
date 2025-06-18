%% Wrapper_SEM_Valerie

clc
clearvars
close all
output_dir = 'C:\Users\rosly\Documents\Valerie_PH\field_to_chi\analysis';
ref_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\COSMOS_SNRwAVG_PDF\deGibbs';
% qsm_dir='C:\Users\rosly\Documents\Valerie_PH\field_to_chi\Registered';
qsm_dir='C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\SNRwAVG_PDF';
roi_dir = 'C:\Users\rosly\Documents\Valerie_PH\ROIs';
mask_dir =  'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\SDC';

i={'3T_Neutral', '3T_Rot1', '3T_Rot2', '3T_Rot3', '3T_Rot5', '3T_Rot6',...
    '7T_Neutral', '7T_Rot1', '7T_Rot2', '7T_Rot3', '7T_Rot4', '7T_Rot5'};
% , '3T_Rot1', '3T_Rot2' , '7T_Rot1', '7T_Rot2', '7T_Rot3'
%'3T_Rot3', '3T_Rot5', '3T_Rot6', , '7T_Rot4', '7T_Rot5'
qsm_SD_matr=[];
qsm_Mean_matr=[];
ref_SD_matr=[];
ref_Mean_matr=[];
for dataset = i
    if contains(dataset{1}, '7T')
        n_orient=4;
        vsz=[.75 .75 .75];
    else
        n_orient=5;
        vsz=[1 1 1];
    end
    % Load in `ref' (ie COSMOS)
    ref_fn = fullfile(ref_dir, [dataset{1}(1:2), '_chi_CF_', num2str(n_orient), '_Orient.nii.gz']);
    ref=load_untouch_nii(ref_fn);
    ref=ref.img;
    
    % Load in `qsm' (ie MEDI)
    if ~contains(dataset{1}, 'Neutral')
        str = [dataset{1}(1:2), '_Neutral_to_', dataset{1}(4:end)];
    else
        str = dataset{1};
    end
    qsm=load_untouch_nii(fullfile(qsm_dir, [str, '_QSM_FLIRT.nii.gz'])); % '_QSM_SMV3_FLIRT.nii.gz'
    qsm=qsm.img;
    
    % Load in `roi' (ie segmentation)
    fs_str=dataset{1}(1:2);
    roi=load_untouch_nii(fullfile(roi_dir, [fs_str, '_ROIs_Use.nii.gz']));
    roi=single(roi.img);
    
    % dilate_vox= round(5/min(vsz)); % 5 mm
    % roi_dilate = imdilate(roi, strel('sphere',dilate_vox));
    
    % Load in 'mask'
    mask=load_untouch_nii(fullfile(mask_dir, [fs_str, '_Neutral_mask_FLIRT.nii.gz']));
    mask=single(mask.img);
    
    nSamples=6;
    qsm_SD=zeros(1,6);
    qsm_Mean=zeros(1,6);
    ref_SD=zeros(1,6);
    ref_Mean=zeros(1,6);
    
    for i = 1:nSamples
        [qsm_SD(:,i), qsm_Mean(:,i)] = std(qsm(roi==i));
        [ref_SD(:,i), ref_Mean(:,i)] = std(ref(roi==i));
    end
    
    qsm_SD_matr=[qsm_SD_matr; 1e3.*qsm_SD];
    qsm_Mean_matr=[qsm_Mean_matr; qsm_Mean];
    ref_SD_matr=[ref_SD_matr; 1e3.*ref_SD];
    ref_Mean_matr=[ref_Mean_matr; ref_Mean];
    fprintf('Processed Dataset %s \n', dataset{1});
end
matfile=fullfile(output_dir, 'Vars_Replicability.mat');
save(matfile, 'qsm_SD_matr', 'qsm_Mean_matr', 'ref_SD_matr', 'ref_Mean_matr');

%% ICC

clc
clearvars
close all
output_dir = 'C:\Users\rosly\Documents\Valerie_PH\field_to_chi\analysis';
matfile=fullfile(output_dir, 'Vars_Replicability.mat');
% load(matfile, 'qsm_SD_matr', 'qsm_Mean_matr', 'ref_SD_matr', 'ref_Mean_matr');
load(matfile, 'qsm_SD_matr', 'qsm_Mean_matr');

[r2, lb2, ub2] = ICC([qsm_Mean_matr(1,:); qsm_Mean_matr(2,:)]');
[r3, lb3, ub3] = ICC([qsm_Mean_matr(1,:); qsm_Mean_matr(3,:)]');
[r4, lb4, ub4] = ICC([qsm_Mean_matr(1,:); qsm_Mean_matr(4,:)]');
[r5, lb5, ub5] = ICC([qsm_Mean_matr(1,:); qsm_Mean_matr(5,:)]');
[r6, lb6, ub6] = ICC([qsm_Mean_matr(1,:); qsm_Mean_matr(6,:)]');
[r8, lb8, ub8] = ICC([qsm_Mean_matr(7,:); qsm_Mean_matr(8,:)]');
[r9, lb9, ub9] = ICC([qsm_Mean_matr(7,:); qsm_Mean_matr(9,:)]');
[r10, lb10, ub10] = ICC([qsm_Mean_matr(7,:); qsm_Mean_matr(10,:)]');
[r11, lb11, ub11] = ICC([qsm_Mean_matr(7,:); qsm_Mean_matr(11,:)]');
[r12, lb12, ub12] = ICC([qsm_Mean_matr(7,:); qsm_Mean_matr(12,:)]');

r = [r2 r3 r4 r5 r6; r8 r9 r10 r11 r12];
lb = r-[lb2 lb3 lb4 lb5 lb6; lb8 lb9 lb10 lb11 lb12];
ub = r-[ub2 ub3 ub4 ub5 ub6; ub8 ub9 ub10 ub11 ub12];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x_labels = {'3T', '7T'};

figure, hold on
bh = bar(categorical(x_labels), r, 0.8, 'grouped');
colororder('gem');

% Add error bars
[ngroups, nbars] = size(r);
groupwidth = min(0.8, nbars / (nbars + 1.5));

for idx = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*idx-1) * groupwidth / (2*nbars); % x positions
    errorbar(x, r(:,idx), lb(:,idx), ub(:,idx), ...
        'k', 'LineStyle', 'none', 'LineWidth', 1, 'HandleVisibility', 'off');
end

% Set axis and legend
ylabel('ICC (0-1)');
ylim([0 1]);
pbaspect([1 1 1]);
% legend_labels={'1', '2', '3'};
legend_labels={'2', '3', '4', '5', '6'};
legend(bh, legend_labels, 'Location', 'bestoutside');

hold off
saveas(gcf, fullfile(output_dir, 'ICC_Ch7.png'));

%% SEM

sem2 = mean([qsm_SD_matr(1,:); qsm_SD_matr(2,:)]).*sqrt(1-r2);
sem3 = mean([qsm_SD_matr(1,:); qsm_SD_matr(3,:)]).*sqrt(1-r3);
sem4 = mean([qsm_SD_matr(1,:); qsm_SD_matr(4,:)]).*sqrt(1-r4);
sem5 = mean([qsm_SD_matr(1,:); qsm_SD_matr(5,:)]).*sqrt(1-r5);
sem6 = mean([qsm_SD_matr(1,:); qsm_SD_matr(6,:)]).*sqrt(1-r6);

sem8 = mean([qsm_SD_matr(7,:); qsm_SD_matr(8,:)]).*sqrt(1-r8);
sem9 = mean([qsm_SD_matr(7,:); qsm_SD_matr(9,:)]).*sqrt(1-r9);
sem10 = mean([qsm_SD_matr(7,:); qsm_SD_matr(10,:)]).*sqrt(1-r10);
sem11 = mean([qsm_SD_matr(7,:); qsm_SD_matr(11,:)]).*sqrt(1-r11);
sem12 = mean([qsm_SD_matr(7,:); qsm_SD_matr(12,:)]).*sqrt(1-r12);

sem = [mean([sem2; sem3; sem4; sem5; sem6],1); ...
    mean([sem8; sem9; sem10; sem11; sem12],1)];
% sem = [mean([sem2; sem3], 1); mean([sem8; sem9; sem10], 1)];

figure, hold on
bar(categorical(x_labels), sem, 0.8, 'grouped');
colororder('glow');
hold on
ylabel('SEM (ppb)');
yticks('auto')
pbaspect([1 1 1]);
legend_labels={['Straw, ', char(0x2225)], 'Straw, \perp', 'Ellipsoid, Low Fe', ...
    'Ellipsoid, High Fe', 'Ellipsoid, Low Ca', 'Ellipsoid, High Ca'};
legend(legend_labels, 'Location', 'bestoutside');
hold off
saveas(gcf, fullfile(output_dir, 'SEM_Ch7.png'));
