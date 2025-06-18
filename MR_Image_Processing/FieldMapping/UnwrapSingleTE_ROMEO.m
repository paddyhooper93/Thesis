function [iFreq_uw] = UnwrapSingleTE_ROMEO(iFreq_raw, qualityMap, Mask_Use, voxel_size, output_dir)

parameters.output_dir = fullfile(output_dir, 'NLF_romeo_tmp');
parameters.TE = false;
parameters.mag = qualityMap;
parameters.mask =  Mask_Use;
parameters.no_unwrapped_output = false;
parameters.calculate_B0 = false;
parameters.phase_offset_correction = 'off';
parameters.voxel_size = voxel_size;
parameters.additional_flags = '-g';

% Create the temp directory
if ~exist("parameters.output_dir", "dir")
    mkdir(parameters.output_dir);
end

% Call ROMEO function, parsing the first output parameter
[iFreq_uw, ~] = ROMEO(iFreq_raw, parameters);

% Load the quality map and threshold
% quality_fn = fullfile(parameters.output_dir, 'quality.nii');
% qualityMap = load_untouch_nii(quality_fn);
% qualityMask = qualityMap.img>0.5;

% Remove the temp directory
try
    rmdir(parameters.output_dir, 's');
catch ME
    warning('Could not remove directory: %s\n%s', parameters.output_dir, ME.message);
end

end

