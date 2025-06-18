function [iFreq, qualityMask] = UnwrapAllTEs_ROMEO_nohdr(Phs, Magn, output_dir, TE, vsz)

parameters.output_dir = fullfile(output_dir, 'romeo_tmp');
parameters.TE = TE.*1000;
parameters.mag = Magn;
parameters.mask = 'robustmask';
parameters.no_unwrapped_output = true;
parameters.calculate_B0 = true;
parameters.phase_offset_correction = 'off';
parameters.voxel_size = vsz;
parameters.additional_flags = '-g -q';

% Create the temp directory
mkdir(parameters.output_dir);

% Call ROMEO function
[~, iFreq] = ROMEO(Phs, parameters);

% Load the quality map and threshold
quality_fn = fullfile(parameters.output_dir, 'quality.nii');
qualityMap = load_untouch_nii(quality_fn);
qualityMask = qualityMap.img<0.5;

% Remove the temp directory
try
    rmdir(parameters.output_dir, 's');
catch ME
    warning('Failed to remove directory: %s. Error: %s', parameters.output_dir, ME.message);
end
