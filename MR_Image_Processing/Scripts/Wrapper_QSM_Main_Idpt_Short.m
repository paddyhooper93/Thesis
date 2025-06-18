%% Wrapper_QSM_Main_Idpt_Short
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set directory for data input
hdr.path_to_data = 'C:\Users\rosly\Documents\QSM_PH\Data\Quad-AfterCplx\';
eval(strcat('cd', 32, hdr.path_to_data));

%% Set and write directory for processing & output
% hdr = struct();
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