function [unwrapped, iFreq] = UnwrapAllTEs_ROMEO(hdr)

parameters.output_dir = fullfile(hdr.output_dir, 'romeo_tmp');
parameters.TE = hdr.TE.*1000; 
parameters.mag = hdr.Magn;
parameters.mask = 'robustmask';
% parameters.mask = hdr.qualityMask;
parameters.no_unwrapped_output = false;
parameters.calculate_B0 = true;
parameters.phase_offset_correction = 'off';
parameters.voxel_size = hdr.voxel_size;
parameters.additional_flags = '-g';

% Create the temp directory
mkdir(parameters.output_dir);

% Call ROMEO function
[unwrapped, iFreq] = ROMEO(hdr.Phs, parameters);

% Remove the temp directory
try
    rmdir(parameters.output_dir, 's');
catch ME
    warning('Failed to remove directory: %s. Error: %s', parameters.output_dir, ME.message);
end
