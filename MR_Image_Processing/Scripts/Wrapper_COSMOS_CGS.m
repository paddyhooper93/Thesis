   %% Weighted least-squares formulation (tol 5e-1) (CGS)
    tol = 0.5;
    % convert from ppm to rad
    delta_TE = 3./1000;
    if matches(FS_str{1}, '3T')
        ppm_to_rad = 2*pi*42.6*2.89*delta_TE;
    else
        ppm_to_rad = 2*pi*42.6*7.00*delta_TE;
    end
    deltaB_fft_rad = fftn( deltaB .* ppm_to_rad );

    [ chi_CGS ] = COSMOS_cgs(deltaB_fft_rad, D, weights, Mask_Use, 'tol', tol, 'x0', chi_CF);
    chi_CGS_rs = (chi_CGS + -0.1106)./ppm_to_rad .* Mask_Use;
    [ chi_CGS_rs ] = pad_or_crop_target_size(chi_CGS_rs, voxel_size);
    export_nii(chi_CGS_rs, fullfile(output_dir, [FS_str{1}, '_chi_CGS_tol-1e-1']), voxel_size);

    mosaic(imrotate(chi_CGS_rs(15:end-15,:,60:5:end), -90), 2, 5, 200, 'COSMOS\_GGS\_tol-1e-1', [-.5, .5])
