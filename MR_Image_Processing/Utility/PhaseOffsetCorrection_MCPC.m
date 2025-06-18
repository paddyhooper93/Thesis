function [corrected_phase, quality, robustmask] = PhaseOffsetCorrection_MCPC(hdr)

parameters.output_dir = fullfile(hdr.output_dir, 'romeo_tmp');
parameters.TE = hdr.TE.*1000; % 1ms = 1000s
parameters.mag = hdr.Magn;
parameters.mask = 'robustmask';
parameters.no_unwrapped_output = true;
parameters.calculate_B0 = false;
parameters.phase_offset_correction = 'bipolar';
parameters.voxel_size = hdr.voxel_size;
parameters.additional_flags = '-u -q';

% Create the temp directory
mkdir(parameters.output_dir);

% Call ROMEO function
ROMEO(hdr.Phs, parameters);

% Load the corrected phase data
phs_fn = fullfile(parameters.output_dir, 'corrected_phase.nii');
corrected_phase_nii = load_untouch_nii(phs_fn);
corrected_phase = double(corrected_phase_nii.img);
% Load the quality map
quality_fn = fullfile(parameters.output_dir, 'quality.nii');
quality_nii = load_untouch_nii(quality_fn);
quality = double(quality_nii.img);
% Load the robustmask
mask_fn = fullfile(parameters.output_dir, 'Mask.nii');
mask_nii = load_untouch_nii(mask_fn);
robustmask = double(mask_nii.img);

% Remove all files in the temp directory
temp_files = dir(parameters.output_dir);
for k = 1:length(temp_files)
    if ~temp_files(k).isdir
        file_to_delete = fullfile(parameters.output_dir, temp_files(k).name);
        try
            delete(file_to_delete);
        catch ME
            warning('Failed to delete file: %s. Error: %s', file_to_delete, ME.message);
            % Attempt to reset permissions and delete again
            if ispc
                system(['attrib -r "' file_to_delete '"']); % Remove read-only attribute (Windows)
            elseif isunix
                system(['chmod +w "' file_to_delete '"']); % Add write permissions (Linux/Mac)
            end
            try
                delete(file_to_delete); % Attempt to delete again
            catch innerME
                warning('Second attempt to delete file failed: %s. Error: %s', file_to_delete, innerME.message);
            end
        end
    end
end

% Remove the temp directory
try
    rmdir(parameters.output_dir, 's');
catch ME
    warning('Failed to remove directory: %s. Error: %s', parameters.output_dir, ME.message);
end