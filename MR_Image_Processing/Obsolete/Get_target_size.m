function Get_target_size()

input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\N4-ITK';
output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\N4-ITK';
mask_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Masking';
% '3T_Rot2', '3T_Rot4', '3T_Rot6', ...
        % '7T_Neutral', '7T_Rot2', '7T_Rot4', '7T_Rot6'
% 
for dataset = {'3T_Rot2', '3T_Rot4', '3T_Rot6', '7T_Neutral', '7T_Rot2', '7T_Rot4', '7T_Rot6'}
    N4_fn = fullfile(input_dir, [dataset{1}, '_Magn_N4.nii.gz']);
    N4_nii = load_untouch_nii(N4_fn);
    N4 = single(N4_nii.img);
    Mask_fn = fullfile(mask_dir, [dataset{1}, '_mask.nii.gz']);
    Mask_nii = load_untouch_nii(Mask_fn);
    Mask = single(Mask_nii.img);

    if contains(dataset{1}, "7T")
        voxel_size = [.75 .75 .75];
    elseif contains(dataset{1}, "3T")
        voxel_size = [1 1 1];
    end

    [N4_padded] = pad_or_crop_target_size(N4, voxel_size);
    [Mask_padded] = pad_or_crop_target_size(Mask, voxel_size);

    N4_padded_fn = fullfile(output_dir, [dataset{1}, '_Magn_N4_Padded']);
    export_nii(N4_padded, N4_padded_fn, voxel_size);
    Mask_padded_fn = fullfile(output_dir, [dataset{1}, '_Mask_Padded']);
    export_nii(Mask_padded, Mask_padded_fn, voxel_size);
end