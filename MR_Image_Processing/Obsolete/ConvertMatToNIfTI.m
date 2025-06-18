%% ConvertMatToNIfTI

i = { '3T_BL', '3T_BL_Rep', '3T_9mth', '3T_24mth', '3T_24mth_Rep' };

for dataset = i
    load(dataset{1});
    Magn_fn = strcat(dataset{1}, '_Magn_SDC');
    Phs_fn = strcat(dataset{1}, '_Phs_SDC');
    export_nii(Magn, Magn_fn)
    export_nii(Phs, Phs_fn)
end