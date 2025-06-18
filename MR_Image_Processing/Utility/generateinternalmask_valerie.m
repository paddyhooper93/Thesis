function [mask_analysis] = generateinternalmask_valerie(hdr)

    % e_mm = 15;
    % e_vox = round(e_mm / mean(voxel_size));
    % betmask = pad_or_crop_target_size(hdr.BET_Mask,voxel_size,FOV);
    % betmask_erode = imerode(betmask, strel('sphere', e_vox));
    % export_nii(betmask_erode, fullfile(hdr.output_dir, [hdr.dataset, '_bet_mask_erode']), voxel_size);    
    % [CSF_Mask] = ObtainCSFMask(hdr);
    % export_nii(CSF_Mask, fullfile(hdr.output_dir, [hdr.dataset, '_CSF_mask']), voxel_size);    
    % [mask_analysis] = imcomplement(CSF_Mask) .* Mask_Use .* betmask_erode;
    % o_mm = 4;
    % o_vox = round(o_mm / mean(voxel_size));
    % [mask_analysis] = imopen(mask_analysis, strel('sphere', o_vox));

    if hdr.FS == 3
        fn = '3T_Rot5_internal_field_mask.nii.gz';
    else
        fn = '7T_Rot5_internal_field_mask.nii.gz'
    end

    nii = load_untouch_nii(fullfile(hdr.output_dir, fn));
    mask_analysis = pad_or_crop_target_size(nii.img, hdr.voxel_size, hdr.FOV);