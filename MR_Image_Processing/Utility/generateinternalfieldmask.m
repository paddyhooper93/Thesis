function [internal_field_mask] = generateinternalfieldmask(Mask_Use, CSF_Mask, voxel_size, e_mm, o_mm)
% Mask_Use, CSF_Mask, voxel_size, e_mm, o_mm
if nargin < 5
    o_mm = 2;
end
if nargin < 4
    e_mm = 4;
end

    % Step (1): Generate eroded BET mask
    eroded_BET_mask = imerode(single(Mask_Use), strel('sphere', 5));
    % Step (2): Multiply by complement CSF mask
    CSF_Mask_Complement = imcomplement(CSF_Mask) .* eroded_BET_mask;
    % Step (3): Erode
    e_vox = round(e_mm / mean(voxel_size));
    CSF_Mask_Complement_erode = imerode(CSF_Mask_Complement, strel('sphere', e_vox));
    internal_field_mask = CSF_Mask_Complement_erode;
    % Step (4): Open
    % o_vox = round(o_mm / mean(voxel_size));
    % internal_field_mask = imopen(CSF_Mask_Complement_erode, strel('sphere', o_vox));
    % if hdr.FS == 3
    %     fn = '3T_9mth_internal_field_mask.nii.gz';
    % else
    %     fn = '7T_9mth_internal_field_mask.nii.gz';
    % end
    % nii = load_untouch_nii(fullfile(hdr.output_dir, fn));
    % internal_field_mask = pad_or_crop_target_size(nii.img, hdr.voxel_size, hdr.FOV);