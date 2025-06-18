function Wrapper_QSM_Main(hdr)

%% clear cmd window, wkspace, figures window
% clc
% clear
% close all

%% Set directory for data input
hdr.path_to_data = 'C:\Users\rosly\Documents\QSM_PH\Data\NC\';
eval(strcat('cd', 32, hdr.path_to_data));

%% Set and write directory for processing & output
% hdr.output_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\VSH8_SEPIA\tmp\';
if 7~=exist(hdr.output_dir, 'dir')
    eval(strcat('mkdir', 32, hdr.output_dir));
end

%% Write header file to adjust parameters
% (See CreateHeader.m)


%% Loop through QSM_Main

i   = {'7T_BL', '7T_BL_Rep', '7T_9mth', '7T_24mth', '7T_24mth_Rep', ...
    '3T_BL', '3T_BL_Rep', '3T_9mth', '3T_24mth', '3T_24mth_Rep'...
    'TE1to7_9mth', 'TE1to7_24mth', 'TE1to7_24mth_Rep', ...
    'TE1to3_9mth', 'TE1to3_24mth', 'TE1to3_24mth_Rep'};

for dataset = i
    QSM_Main(dataset{1}, hdr);
    fprintf('Processed Dataset %s \n', dataset{1});
end


%% unix("bash Run_antsApplyTransforms.sh")

% Since I'm using Windows, I added a breakpoint to the next line of code.
% bourne-again shell script ("Run_antsApplyTransforms.sh") through a terminal in a WSL environment.

% After running the Shell script, the registered volumes will be exported to
% the following directory, relative to hdr.output_dir: "..\rgst\".


%% Combine together into a single volume.
hdr.input_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\VSH9_SEPIA\rgst_SNRwAVG_MEDI0\';
output_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\VSH9_SEPIA\SNRwAVG_MEDI0\';
if 7~=exist(output_dir, 'dir')
    eval(strcat('mkdir', 32, output_dir));
end

i =      {'7T_BL', '7T_BL_Rep', '7T_9mth', '7T_24mth', '7T_24mth_Rep', ...
    '3T_BL', '3T_BL_Rep', '3T_9mth', '3T_24mth', '3T_24mth_Rep'};
% i = {'7T_9mth', '3T_9mth'};
j = {'QSM'};

for param = j
    
    for dataset = i
        [CombinedVol] = CombineProcessedVols_New(dataset{1}, param{1}, hdr);
        CombinedFn = fullfile(output_dir, strcat(dataset{1}, '_', param{1}));
        export_nii(CombinedVol, CombinedFn);
        fprintf('Exported globally processed %s maps for Dataset %s \n', param{1}, dataset{1})
    end
    
end


%% clear cmd window, wkspace, figures window
clc
clear
close all

%% Set directory for data input
hdr.path_to_data = 'C:\Users\rosly\Documents\QSM_PH\Data\Quad-AfterCplx\';
eval(strcat('cd', 32, hdr.path_to_data));

%% Set and write directory for processing & output
hdr.output_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\VSH8_SEPIA+LBV\tmp_Idpt\';
if 7~=exist(hdr.output_dir, 'dir')
    eval(strcat('mkdir', 32, hdr.output_dir));
end

i =      {'7T_BL', '7T_BL_Rep', '7T_9mth', '7T_24mth', '7T_24mth_Rep', ...
    '3T_BL', '3T_BL_Rep', '3T_9mth', '3T_24mth', '3T_24mth_Rep'};

for dataset = i
    for j = 1:3
        hdr.j = j;
        QSM_Main(dataset{1}, hdr);
        fprintf('Processed Quad %d in Dataset %s \n', j, dataset{1})
    end
end

i = {'TE1to7_9mth', 'TE1to7_24mth', 'TE1to7_24mth_Rep', ...
    'TE1to3_9mth', 'TE1to3_24mth', 'TE1to3_24mth_Rep'};

for dataset = i
    hdr.j = 4;
    QSM_Main(dataset{1}, hdr);
    fprintf('Processed Quad %d in Dataset %s \n', hdr.j, dataset{1})
end



%% Loop through QSM_Main
% i = {'7T_BL_Rep', '7T_BL', '7T_9mth', '7T_24mth_Rep', '7T_24mth', ...
%     'TE1to3_24mth', 'TE1to3_24mth_Rep', 'TE1to3_9mth'};
%
% % Done =    {
% %, ...
% for dataset = i
%
%     QSM_Main(dataset{1}, hdr);
%     fprintf('Processed Dataset %s \n', dataset{1});
% end

%Done = {};
% i = {'3T_BL', '3T_BL_Rep', '3T_9mth', '3T_24mth', '3T_24mth_Rep', ...
%      'TE1to7_9mth', 'TE1to7_24mth', 'TE1to7_24mth_Rep', ...
%      '7T_BL_Rep', '7T_BL', '7T_9mth', '7T_24mth_Rep', '7T_24mth', ...
%      'TE1to3_24mth', 'TE1to3_24mth_Rep', 'TE1to3_9mth'};
%
% for dataset = i
%     QSM_Main(dataset{1}, hdr);
%     fprintf('Processed Dataset %s \n', dataset{1});
% end


%% TODO Combine together into a single volume.

% hdr.input_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\L1L2_R2s5_Eddy_GraphCut_NC_RR05\rgst\';
% output_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\L1L2_R2s5_Eddy_GraphCut_NC_RR05\';
%
% i =    {'3T_BL', '3T_BL_Rep', '3T_9mth', '3T_24mth', '3T_24mth_Rep', ...
%         '7T_9mth', '7T_24mth_Rep', '7T_BL', '7T_BL_Rep', '7T_24mth'};
% param = 'L1L2';
% for dataset = i
%     [CombinedVol] = CombineProcessedVols(dataset{1}, param, hdr);
%     CombinedFn = fullfile(output_dir, strcat(dataset{1}, '_', param));
%     export_nii(CombinedVol, CombinedFn);
%     fprintf('Exported globally processed NifTI volumes for Dataset %s \n', dataset{1})
% end



% for dataset = i
%     Phs_nii = load_untouch_nii(strcat(dataset{1},'_Phs_Quad.nii.gz'));
%     Phs = Phs_nii.img;
%     Magn_nii = load_untouch_nii(strcat(dataset{1},'_Magn_Quad.nii.gz'));
%     Magn = Magn_nii.img;
%     save(fullfile(hdr.output_dir, dataset{1}), "Magn", "Phs", '-mat');
% end




%%

% ROIs_nii = load_untouch_nii('7T_ROIs.nii.gz');
% ROIs = double(ROIs_nii.img);
%
% i = {'7T_9mth', '7T_BL', '7T_BL_Rep', 'TE1to3_9mth', '7T_24mth'};
%
% for dataset = i
%     Vol_nii = load_untouch_nii(strcat(dataset{1},'_QSMMask.nii.gz'));
%     Vol = Vol_nii.img;
%     ROIs = ROIs .* Vol;
% end
%
% export_nii(ROIs,'7T_ROIs_RR.nii.gz')

% TODO = {
% TODO = {}
%
% i =    {'7T_9mth', '7T_24mth_Rep', '7T_BL', '7T_BL_Rep', 'TE1to3_9mth', '7T_24mth',  ...
%         'TE1to3_24mth', 'TE1to3_24mth_Rep'};
% input_dir = 'C:\Users\rosly\Documents\QSM_PH\Data\NC\';
%
% % Done = '3T_BL', '3T_BL_Rep', '3T_9mth', '3T_24mth', '3T_24mth_Rep' ...
%         % 'TE1to7_9mth', 'TE1to7_24mth', 'TE1to7_24mth_Rep'
% for dataset = i
%     R2s_nii = load_untouch_nii(strcat(dataset{1}, '_SDC_R2s.nii.gz'));
%     R2s = R2s_nii.img;
%     save(fullfile(input_dir, dataset{1}), 'R2s', '-append');
% end



% for dataset = i
%     for j = 1:3
%         hdr.j = j;
%         QSM_Main(dataset{1}, hdr);
%         fprintf('Processed Quad %d in Dataset %s \n', j, dataset{1})
%     end
% end
%         %%
%
% i = {'TE1to7_9mth', 'TE1to7_24mth', 'TE1to7_24mth_Rep', ...
% 'TE1to3_9mth', 'TE1to3_24mth', 'TE1to3_24mth_Rep'};
%
% for dataset = i
%     hdr.j = 4;
%     QSM_Main(dataset{1}, hdr);
%     fprintf('Processed Quad %d in Dataset %s \n', hdr.j, dataset{1})
% end