clc 
clear 
close all

%% Combine together into a single volume.
hdr.input_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\R2s_SDC\rgst\';
output_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\R2s_SDC\';

i =    {'7T_9mth', '7T_24mth_Rep', '7T_BL', '7T_BL_Rep', '7T_24mth', ...
        '3T_BL', '3T_BL_Rep', '3T_9mth', '3T_24mth', '3T_24mth_Rep'}; 
        %Done = {''};
j = {'R2s'};


for param = j

    for dataset = i
        if contains(dataset{1}, '7T')
            params = strcat('SDC_', param{1});
        else
            params = param{1};
        end
        [CombinedVol] = CombineProcessedVols(dataset{1}, params, hdr);
        CombinedFn = fullfile(output_dir, strcat(dataset{1}, '_', params));
        export_nii(CombinedVol, CombinedFn);
        fprintf('Exported globally processed NifTI volumes for Dataset %s \n', dataset{1})
    end

end


%% Wrapper_CombineProcessedVols

param = 'L1L2';
ext = '_14mm_SDC_Data';
path_to = 'C:\Users\rosly\Documents\QSM_PH\Analysis\';
path_to_data = strcat(path_to, param, ext); %,'_Data\'
eval(strcat('cd',32,path_to_data));

i = {'3T_9mth', '3T_24mth', '3T_24mth_Rep', '7T_9mth_SDC', '7T_24mth_SDC', '7T_24mth_Rep_SDC'};

for dataset = i
    [Combined] = CombineProcessedVols(dataset{1}, param);
    CombinedFn = strcat(dataset{1}, '_', param, '_QuadCombined');
    export_nii(Combined, CombinedFn);
end