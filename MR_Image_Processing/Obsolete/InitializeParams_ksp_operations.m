function [hdr, data] = InitializeParams_ksp_operations(dataset, hdr)

%% Import data
% mask_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Masking\';
% Mask_fn = fullfile(mask_dir, [dataset, '_mask.nii.gz']);
Mask_fn = fullfile(hdr.path_to_data, [dataset, '_Mask_Use.nii.gz']);
Mask_nii = load_untouch_nii(Mask_fn);
data.Mask_Use = single(Mask_nii.img);
Magn_fn = fullfile(hdr.path_to_data, [dataset, '_Magn.nii.gz']);
Magn_nii = load_untouch_nii(Magn_fn);
data.Magn = single(Magn_nii.img) .* data.Mask_Use;
Phs_fn = fullfile(hdr.path_to_data, [dataset, '_Phs_MCPC.nii.gz']);
Phs_nii = load_untouch_nii(Phs_fn);
data.Phs = single(Phs_nii.img) .* data.Mask_Use;


% eval(['cd', 32, hdr.path_to_data]);
% matfile = [dataset, '_NC.mat'];
% fileInfo = who('-file', matfile);
% 
% requiredFields = {'Magn', 'Phs', 'Mask_Use'};
% if all(ismember(requiredFields, fileInfo))
%     % Load directly into hdr structure
%     data = load(matfile, requiredFields{:});
%     data.Mask_Use = single(data.Mask_Use);
%     data.Magn = single(data.Magn) .* data.Mask_Use;
%     data.Phs = single(data.Phs) .* data.Mask_Use;
% else
%     error('Missing required fields in mat file')
% end

if ~isfield(hdr, 'isParallel')
    hdr.isParallel = false;
end

if hdr.isParallel
    InitiateParallelComputing();
end
    

[data.Phs] = DICOM2Radians(data.Phs);
[data.Magn] = Magn_Rescaling(data.Magn);

if hdr.isInvert
    data.Phs = -data.Phs;
end


if contains(dataset, "3T")
    hdr.voxel_size      = [1 1 1];
elseif contains(dataset, "7T")
    hdr.voxel_size      = [0.75 0.75 0.75];
end

hdr.TE                      = (3:3:(7*3))./1000;


if ~isfield(hdr, 'unwrapMethod')
    % hdr.unwrapMethod = 'GraphCuts'; % Spatial unwrapping only
    % hdr.subsampling = 2; % 1: Unwrapping with full matrix, 2: Unwrapping with subsampling to speed up
    hdr.unwrapMethod = 'ROMEO';
end

if ~isfield(hdr, 'EchoCombineMethod')
    hdr.EchoCombineMethod = 'NLFit';
end

hdr.matrix_size         = size(data.Mask_Use);