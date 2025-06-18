function [iFreq_uw] = UnwrapSingleTE_ROMEO(iFreq_raw, hdr)

    parameters.output_dir = fullfile(hdr.output_dir, 'NLF_romeo_tmp');
    parameters.TE = false;
    parameters.mag = hdr.Magn(:,:,:,1);
    parameters.mask = hdr.Mask_Use;
    parameters.no_unwrapped_output = false;
    parameters.calculate_B0 = false;
    parameters.phase_offset_correction = 'off';
    parameters.voxel_size = hdr.voxel_size;

    mkdir(parameters.output_dir);
    [iFreq_uw, ~] = ROMEO(iFreq_raw, parameters);
    rmdir(parameters.output_dir, 's')

end

