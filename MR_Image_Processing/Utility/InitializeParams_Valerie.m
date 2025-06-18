function [hdr] = InitializeParams_Valerie(dataset, hdr)

TE                      = (3:3:(7*3))./1000;

if contains(dataset, "3T")
    hdr.FS              = 3;
    voxel_size      = [1 1 1];
elseif contains(dataset, "7T")
    hdr.FS              = 7;
    voxel_size      = [0.75 0.75 0.75];
end

%% Use parallel computing
if ~isfield(hdr, 'isParallel')
    hdr.isParallel = false;
end

if hdr.isParallel
    InitiateParallelComputing();
end

%% Phase offset correction

if ~isfield(hdr, 'Bipolar_MCPC')
    hdr.Bipolar_MCPC = false;
end

%% Unwrapping and echo combination (FieldMapping)

if ~isfield(hdr, 'Skip_FieldMapping')
    hdr.Skip_FieldMapping = false;
end

if ~isfield(hdr, 'unwrapMethod')
    hdr.unwrapMethod = 'ROMEO'; % Spatial unwrapping only
end

if matches(hdr.unwrapMethod, 'GraphCuts')
    hdr.subsampling = 2; % 1: Unwrapping with full matrix, 2: Unwrapping with subsampling to speed up
end

if ~isfield(hdr, 'EchoCombineMethod')
    hdr.EchoCombineMethod = 'SNRwAVG';
end

if ~isfield(hdr, 'temporalUnwrapping')
    hdr.temporalUnwrapping = 'ROMEO'; % Spatial & temporal unwrapping
end

%% Background field correction (BFC)
if ~isfield(hdr, 'erode_before_radius')
    hdr.erode_before_radius = 0; % vox
end

if ~isfield(hdr, 'BFCMethod')
    hdr.BFCMethod = 'PDF';
end

%% Single-step TGV

if ~isfield(hdr, 'SingleStep')
    hdr.SingleStep = false;
end

%% Dipole inversion

if ~isfield(hdr, 'isRTS')
    hdr.isRTS = false;
end

if ~isfield(hdr, 'RelativeResidualMasking')
    hdr.RelativeResidualMasking = true;
end

if ~isfield(hdr, 'RelativeResidualWeighting')
    hdr.RelativeResidualWeighting = false;
end

if ~isfield(hdr, 'ApplyWeightingFieldMapSD')
    hdr.ApplyWeightingFieldMapSD = false;
end


%% MEDI dipole inversion

if ~isfield(hdr, 'optimizeMEDI')
    hdr.optimizeMEDI = false;
end

if ~isfield(hdr, 'isCSF')
    hdr.isCSF = true;
end

if ~isfield(hdr, 'isSMV')
    hdr.isSMV = false;
end

if ~isfield(hdr, 'lambda')
    hdr.lambda = 1000;
end

if ~isfield(hdr, 'lam_CSF')
    hdr.lam_CSF = 100;
end

if ~isfield(hdr, 'percentage')
    hdr.percentage = 0.45;
end

if ~isfield(hdr, 'radius')
    hdr.radius = 3;
end

if ~isfield(hdr, 'isMerit')
    hdr.isMerit = 1;
end

if ~isfield(hdr, 'wData')
    hdr.wData = 1;
end

if ~isfield(hdr, 'wGrad')
    hdr.wGrad = 1;
end

if ~isfield(hdr, 'pad')
    hdr.pad = 0;
end

%% Correcting for NaCl bulk medium

if ~isfield(hdr, 'CorrectNaCl')
    hdr.CorrectNaCl = true;
end

%% Analysing earlier steps

if ~isfield(hdr, 'noDipoleInversion')
    hdr.noDipoleInversion = false; % Exit at dipole inversion
end

if ~isfield(hdr, 'saveWorkspace')
    hdr.saveWorkspace = false; % Exports workspace variables as MAT file
end

if ~isfield(hdr, 'saveDelta')
    hdr.saveDelta = false; % Exports NIfTI file of local field map for COSMOS (in ppm)
end

if ~isfield(hdr, 'saveFieldMap')
    hdr.saveFieldMap = false;  % Exports NIfTI file of field map (in Hz)
end


%% Exporting masks

if ~isfield(hdr, 'saveMaskUse')
    hdr.saveMaskUse = false; % Exports NIfTI file of Mask_Use
end

if ~isfield(hdr, 'saveQSMMask')
    hdr.saveQSMMask = false; % Exports NIfTI file of QSM_Mask
end

if ~isfield(hdr, 'saveComplementMask')
    hdr.saveComplementMask = true; % Exports NIfTI file of CSF_Mask (not eroded)
end

if ~isfield(hdr, 'saveErodedComplementMask')
    hdr.saveErodedComplementMask = false; % Exports NIfTI file of CSF_Mask (eroded by 10 mm)
end

if ~isfield(hdr, 'useQualityMask')
    hdr.useQualityMask = true;
end

if ~isfield(hdr, 'saveQualityMask')
    hdr.saveQualityMasks = true; % Exports RR mask and NLFit_noise_mask
end

%% Import data

matfile = fullfile(hdr.path_to_data, [dataset, '_forQSM.mat']);
fileInfo = who('-file', matfile);
if any(matches(fileInfo, 'Magn')) && any(matches(fileInfo, 'Phs')) && ...
        any(matches(fileInfo, 'Mask_Use')) && any(matches(fileInfo, 'R2s'))
    load(matfile, fileInfo{:}, 'Phs', 'R2s'); % 'Magn'
else
    error('Missing required fields in mat file')
end

if ~matches(dataset, '7T_Neutral')
    % if contains(dataset, '3T')
    %     magn_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\N4-ITK_deGibbs';
    % else
    magn_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\N4-ITK';
    % end
    magn_nii = load_untouch_nii(fullfile(magn_dir, [dataset, '_Magn.nii.gz']) );
    Magn = magn_nii.img;
    Mask_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\SDC';
    Mask_nii = load_untouch_nii(fullfile(Mask_dir, [dataset, '_mask.nii.gz']));
    Mask_Use = Mask_nii.img;
end

if contains(dataset, '7T')
    TE_Idx              = 1:4;
    TE                  = TE(TE_Idx);
    Magn                = Magn(:, :, :, TE_Idx);
    Phs                 = Phs(:, :, :, TE_Idx);
end

hdr.FOV = [400 400 400].*min(voxel_size); % vox^3
Mask_Use = pad_or_crop_target_size(Mask_Use, voxel_size, hdr.FOV);
Magn = pad_or_crop_target_size(Magn, voxel_size, hdr.FOV) .* Mask_Use;
Phs = pad_or_crop_target_size(Phs, voxel_size, hdr.FOV) .* Mask_Use;
R2s = pad_or_crop_target_size(R2s, voxel_size, hdr.FOV) .* Mask_Use;

% end

%% TE selection specified by output_dir

if contains(hdr.output_dir, 'TE') && contains(hdr.output_dir, 'to')
    pos = strfind(hdr.output_dir, 'to');
    TEi = str2double(hdr.output_dir(pos-1));
    TEf = str2double(hdr.output_dir(pos+2));
    Magn = Magn(:, :, :, TEi:TEf);
    Phs = Phs(:, :, :, TEi:TEf);
    TE  = TE(TEi:TEf);
elseif contains(hdr.output_dir, 'OddTEs')
    oddIdx = 1:2:length(TE);
    TE = TE(oddIdx);
    Magn = Magn(:, :, :, oddIdx);
    Phs = Phs(:, :, :, oddIdx);
elseif contains(hdr.output_dir, 'EvenTEs')
    evenIdx = 2:2:length(TE);
    TE = TE(evenIdx);
    Magn = Magn(:, :, :, evenIdx);
    Phs = Phs(:, :, :, evenIdx);
end

%% Scale phase to range [-pi,pi) and magn to range [0, 4095]
if ~isfield(hdr, 'invertPhase')
    hdr.invertPhase = false;
end
if hdr.invertPhase
    Phs = -Phs;
end

[Phs] = DICOM2Radians(Phs);
[Magn] = Magn_Rescaling(Magn);

%% Calculate expected noise level
% hdr.noise_level = calfieldnoise(Magn.*exp(Phs), Mask_Use);
% fprintf('Expected noise level: %f.1', hdr.noise_level);

%% Package outputs into 'hdr' struct
hdr.TE = TE;
hdr.dataset = dataset;
hdr.Mask_Use = Mask_Use;
hdr.Magn = Magn;
hdr.Phs = Phs;
hdr.R2s = R2s;
hdr.iMag                = sqrt(sum(abs(Magn).^2,4));
hdr.matrix_size         = size(Mask_Use);
hdr.voxel_size = voxel_size;
% export_nii(single(hdr.iMag), fullfile(hdr.output_dir, [dataset, '_iMag']), hdr.voxel_size)


end