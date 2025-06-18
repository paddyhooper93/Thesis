function Wrapper_QSM_Main_All(hdr)

% %% clear cmd window, wkspace, figures window
% clc
% clear
% close all

%% Set directory for data input
hdr.path_to_data = 'C:\Users\rosly\Documents\QSM_PH\Data\SDC-Cplx';
% cd(hdr.path_to_data);

%% Set and write directory for processing & output
if 7~=exist(hdr.output_dir, 'dir')
    mkdir(hdr.output_dir);
end
cd(hdr.output_dir);

%% Loop through QSM_Main

%
i   = {'3T_9mth', '7T_9mth', ... 
    'TE1to3_9mth', 'TE1to7_9mth'};  
%, '3T_BL', '3T_BL_Rep' ,  '3T_9mth', '3T_24mth_Rep'% , 'TE1to7_24mth_Rep'
%, '7T_BL_Rep' , '7T_24mth_Rep'% , 'TE1to3_24mth_Rep' %
for dataset = i
    QSM_Main(dataset{1}, hdr);
    fprintf('Processed Dataset %s \n', dataset{1});
end