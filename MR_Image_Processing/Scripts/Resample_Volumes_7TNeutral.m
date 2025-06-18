    input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\SDC';
    magn_fn = fullfile(input_dir, [dataset{1}, '_Magn_Padded_068.nii.gz']);
    magn_nii = load_untouch_nii(magn_fn);
    magn = single(magn_nii.img);
    phs_fn = fullfile(input_dir, [dataset{1}, '_Phs_Padded_068.nii.gz']);
    phs_nii = load_untouch_nii(phs_fn);
    phs = single(phs_nii.img);
    cplx = magn .* exp(1i * phs);
    
    old_voxel_size = [.68 .68 .68];
    new_voxel_size = [.75 .75 .75];
    real_vol = resample_volumes(real(cplx), old_voxel_size, new_voxel_size);
    imag_vol = resample_volumes(imag(cplx), old_voxel_size, new_voxel_size);

    phs = atan2(imag_vol, real_vol);
    magn = sqrt(imag_vol.^2 + real_vol.^2);

    export_nii(magn, fullfile(input_dir, [dataset{1}, '_Magn_Padded']), new_voxel_size);
    export_nii(phs, fullfile(input_dir, [dataset{1}, '_Phs_Padded']), new_voxel_size);