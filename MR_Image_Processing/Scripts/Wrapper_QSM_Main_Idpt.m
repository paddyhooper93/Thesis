%% Wrapper_QSM_Main_Idpt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% clear cmd window, wkspace, figures window
clc
clear
close all

%% Set directory for data input
hdr.path_to_data = 'C:\Users\rosly\Documents\QSM_PH\Data\Quad-AfterCplx\';
eval(strcat('cd', 32, hdr.path_to_data));

%% Set and write directory for processing & output
hdr = struct();
% hdr.output_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\Quad-AfterCplx\tmp_idpt\';
if 7~=exist(hdr.output_dir, 'dir')
    eval(strcat('mkdir', 32, hdr.output_dir));
end

%% Invert sign of the phase 
hdr.isInvert = true; % The phase is inverted in path: "\Data\Quad-AfterCplx\"

%% Loop through QSM_Main

i =  {'3T_BL', '3T_BL_Rep', '3T_9mth', '3T_24mth', '3T_24mth_Rep', ...
      '7T_BL', '7T_BL_Rep', '7T_9mth', '7T_24mth', '7T_24mth_Rep'};
for dataset = i
    for j = 1:3
        hdr.j = j;
        QSM_Main(dataset{1}, hdr);
        fprintf('Processed Quad %d in Dataset %s \n', j, dataset{1})
    end
end

i = {'TE1to3_9mth', 'TE1to3_24mth', 'TE1to3_24mth_Rep', ...
    'TE1to7_9mth', 'TE1to7_24mth', 'TE1to7_24mth_Rep' };
%TODO: Calculate the ICC for NLF-MEDI0 versus NLF-MEDI-SMV, then decide
%which to use

for dataset = i
    j = 4;
        hdr.j = j;
        QSM_Main(dataset{1}, hdr);
        fprintf('Processed Quad %d in Dataset %s \n', j, dataset{1})
end


%% Combine quad 1:4 into a single volume. 
hdr.input_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\VSH8_SEPIA_Idpt\tmp_SNRwAVG_MEDI+0\';
output_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\VSH8_SEPIA_Idpt\SNRwAVG_MEDI+0\';
if 7~=exist(output_dir, 'dir')
    eval(strcat('mkdir', 32, output_dir));
end

j = {'QSM'};

i = {'3T_BL', '3T_BL_Rep', '3T_9mth', '3T_24mth', '3T_24mth_Rep', ...
    '7T_BL', '7T_BL_Rep', '7T_9mth', '7T_24mth', '7T_24mth_Rep'};

for param = j
    
    for dataset = i
        [CombinedVol] = CombineIdptProcessedVols(dataset{1}, param{1}, hdr);
        CombinedFn = fullfile(output_dir, strcat(dataset{1}, '_', param{1}, '_Idpt'));
        export_nii(CombinedVol, CombinedFn);
        fprintf('Exported locally-processed NifTI volumes for Dataset %s \n', dataset{1})
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %% clear cmd window, wkspace, figures window
% clc
% clear
% close all
% 
% %% Set directory for data input
% path_to_data = 'C:\Users\rosly\Documents\QSM_PH\Data\NC\';
% eval(strcat('cd', 32, path_to_data));
% 
% %% Set and write directory for processing & output
% hdr = struct();
% hdr.output_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\R2s5_Eddy_GraphCut_NC_RR05\tmp\';
% if 7~=exist(hdr.output_dir, 'dir')
%     eval(strcat('mkdir', 32, hdr.output_dir));
% end
% 
% %% Write header file for parametric input 
% % (See CreateHeader.m)
% 
% %% Loop through QSM_Main
% 
% i = {'TE1to3_9mth', 'TE1to3_24mth', 'TE1to3_24mth_Rep', ...
%     'TE1to7_9mth', 'TE1to7_24mth', 'TE1to7_24mth_Rep', ... 
%     '7T_9mth', '7T_24mth_Rep', '7T_24mth', ...
%     '3T_9mth', '3T_24mth', '3T_24mth_Rep', ...
%      '3T_BL', '3T_BL_Rep', '7T_BL', '7T_BL_Rep'}; 
% 
% for dataset = i
%     QSM_Main(dataset{1}, hdr);
%     fprintf('Processed Dataset %s \n', dataset{1});
% end
% % Done = 'TE1to7_9mth', 'TE1to7_24mth', 'TE1to7_24mth_Rep', ... 
% 
% 
% %% Combine 3 quads from full TE datasets and 1 quad from restricted TE datasets.
% % i.e. 7T_9mth (contains 3 quads) combined with TE1to3_9mth (contains 1 quad), etc.
% 
% hdr.input_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\Quad-AfterCplx\tmp\';
% output_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\Quad-AfterCplx\InfCyl\';
% if 7~=exist(output_dir, 'dir')
%     eval(strcat('mkdir', 32, output_dir));
% end
% 
% i =    {'3T_BL', '3T_BL_Rep', '7T_9mth', '7T_24mth_Rep', '7T_24mth', ...
%         '7T_BL', '7T_BL_Rep', '3T_9mth', '3T_24mth', '3T_24mth_Rep'}; 
% 
% param = 'QSM';
% for dataset = i
%     [CombinedVol] = CombineProcessedVols(dataset{1}, param, hdr);
%     CombinedFn = fullfile(output_dir, strcat(dataset{1}, '_', param));
%     export_nii(CombinedVol, CombinedFn);
%     fprintf('Exported globally processed NifTI volumes for Dataset %s \n', dataset{1})
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
