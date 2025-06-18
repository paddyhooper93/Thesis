function Wrapper_QSM_Main_Short(hdr)

% %% clear cmd window, wkspace, figures window
% clc
% clear
% close all

%% Set directory for data input
hdr.path_to_data = 'C:\Users\rosly\Documents\QSM_PH\Data\NC\';
eval(strcat('cd', 32, hdr.path_to_data));

%% Set and write directory for processing & output
% hdr.output_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\VSH12_SEPIA\tmp\';
if 7~=exist(hdr.output_dir, 'dir')
    eval(strcat('mkdir', 32, hdr.output_dir));
end

%% Loop through QSM_Main

%    '7T_BL', '7T_BL_Rep', '7T_9mth', '7T_24mth', ...
i = {'TE1to3_9mth'};

% i   = {'7T_24mth_Rep', ...
%     '3T_BL', '3T_BL_Rep', '3T_9mth', '3T_24mth', '3T_24mth_Rep', ...
%     'TE1to3_9mth', 'TE1to3_24mth', 'TE1to3_24mth_Rep', ...
%     'TE1to7_9mth', 'TE1to7_24mth', 'TE1to7_24mth_Rep'};

for dataset = i
    QSM_Main(dataset{1}, hdr);
    fprintf('Processed Dataset %s \n', dataset{1});
end