%% Wrapper_CombineIdptProcessedVols

% path_to = 'C:\Users\rosly\Documents\QSM_PH\Data\Idpt_Working\';
% eval(strcat('cd',32,path_to));
hdr.output_dir = 'C:\Users\rosly\Documents\QSM_PH\Data\Idpt_Working\';
eval(strcat('cd', 32, hdr.output_dir));
output_dir = 'C:\Users\rosly\Documents\QSM_PH\Data\Idpt_Done\';
if 7~=exist(output_dir, 'dir')
    eval(strcat('mkdir', 32, output_dir));
end

i = {'3T_BL', '3T_BL_Rep', '3T_9mth', '3T_24mth', '3T_24mth_Rep', ...
    '7T_BL', '7T_BL_Rep', '7T_9mth', '7T_24mth', '7T_24mth_Rep'};

for dataset = i
   [CombinedVol] = CombineIdptProcessedVols(dataset{1}, hdr);
   CombinedFn = fullfile(output_dir, strcat(dataset{1}, '_L1L2_Quad'));
   export_nii(CombinedVol, CombinedFn);
end