function Run_commands_upsample


in_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\SDC';
out_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Upsample';
if 7~=exist("out_dir", "dir")
    mkdir(out_dir);
    cd(out_dir);
end

    for dataset = {'3T_Neutral'} % , '3T_Rot1', '3T_Rot2', '3T_Rot3', '3T_Rot5', '3T_Rot6'
        matFile = fullfile(in_dir, [dataset{1}, '_forQSM']);
        load(matFile, "Magn", "Phs", "Mask_Use", "R2s");
        iField = Magn .* exp( 1i * Phs);
        RealVol = real(iField);
        ImagVol = real(iField);
        old_voxel_size = [1 1 1];
        new_voxel_size = [.75 .75 .75];
        voxel_size = new_voxel_size;
        interpMethod_binary = 'nearest';
        [ Mask_Use ] = resample_volumes(Mask_Use, old_voxel_size, voxel_size, interpMethod_binary);
        interpMethod_scalar = 'spline';
        [ RealVol ] = resample_volumes(RealVol, old_voxel_size, voxel_size, interpMethod_scalar) .* Mask_Use;
        [ ImagVol ] = resample_volumes(ImagVol, old_voxel_size, voxel_size, interpMethod_scalar) .* Mask_Use;
        [ R2s ] = resample_volumes(R2s, old_voxel_size, voxel_size, interpMethod_scalar) .* Mask_Use;

        % FOV = [210, 240, 192]; % in millimeters
        % [ Mask_Use ] = single(pad_or_crop_target_size(Mask_Use, voxel_size, FOV));
        % [ RealVol ] = single(pad_or_crop_target_size(RealVol, voxel_size, FOV));
        % [ ImagVol ] = single(pad_or_crop_target_size(ImagVol, voxel_size, FOV));
        % [ R2s ] = single(pad_or_crop_target_size(R2s, voxel_size, FOV));

        Magn = sqrt(RealVol.^2 + ImagVol.^2);
        Phs = atan2(ImagVol, RealVol);

        export_nii(Magn, fullfile(out_dir, [dataset{1}, '_Magn_Upsampled']), voxel_size);
        export_nii(Phs, fullfile(out_dir, [dataset{1}, '_Phs_Upsampled']), voxel_size);
        export_nii(Mask_Use, fullfile(out_dir, [dataset{1}, '_Mask_Use_Upsampled']), voxel_size);
        export_nii(R2s, fullfile(out_dir, [dataset{1}, '_R2s_Upsampled']), voxel_size);

        matFile = fullfile(out_dir, [dataset{1}, '_forQSM']);
        save(matFile, "Magn", "Phs", "Mask_Use", "R2s");


    end


