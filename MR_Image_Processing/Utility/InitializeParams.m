function [hdr] = InitializeParams(dataset, hdr)

if contains(hdr.path_to_data, 'QSM_PH')

if contains(dataset, "3T") || contains(dataset, "TE1to7") || contains(dataset, "TE1to6") || contains(dataset, "TE1to5") % || contains(dataset, "10")
    FS = 3; FS_str = '3T_'; n_TE = 12; 
elseif contains(dataset, "7T") || contains(dataset, "TE1to3") || contains(dataset, "TE1to2") || contains(dataset, "TE1to1") %|| contains(dataset, "05") || contains(dataset, "06")
    FS = 7; FS_str = '7T_'; n_TE = 4;
end

elseif contains(hdr.path_to_data, 'Valerie_PH')
    if contains(dataset, "3T")
        FS = 3; FS_str = '3T_'; n_TE = 7; 
    elseif contains(dataset, "7T")
        FS = 7; FS_str = '7T_'; n_TE = 7;
    end
end

%% Unwrapping and echo combination

if FS == 3
    hdr.EchoCombineMethod = 'SNRwAVG';
    hdr.unwrapMethod = 'ROMEO'; % Spatial & temporal unwrapping  
else
    hdr.EchoCombineMethod = 'NLFit';
    hdr.unwrapMethod = 'GraphCuts'; % Spatial unwrapping only
    hdr.subsampling = 2; % Unwrapping with subsampling for speed up      
end

if ~contains(dataset, 'TE')
    hdr.EchoCombineMethod = 'SNRwAVG';
    hdr.unwrapMethod = 'ROMEO'; % Spatial & temporal unwrapping  
end

%% Background field correction (BFC)
if ~isfield(hdr, 'erode_before_radius')
    hdr.erode_before_radius = 2; % mm
end

if ~isfield(hdr, 'BFCMethod')
    hdr.BFCMethod = 'V-SHARP 8SMV SEPIA';
    % hdr.BFCMethod = 'PDF';
end

if ~isfield(hdr, 'poly_order')
    hdr.poly_order      = 4;
end

%% Single-step TGV

if ~isfield(hdr, 'SingleStep')
    hdr.SingleStep = false; 
end

%% Dipole inversion

if ~isfield(hdr, 'isRTS')
    hdr.isRTS = false;
end

if ~isfield(hdr, 'ApplyWeightingFieldMapSD')
    hdr.ApplyWeightingFieldMapSD = false;
end

if ~isfield(hdr, 'RelativeResidualWeighting')
    hdr.RelativeResidualWeighting = false;
end

if ~isfield(hdr, 'RelativeResidualMasking')
    hdr.RelativeResidualMasking = true;
end

if ~isfield(hdr, 'NLFitWeighting')
    hdr.NLFitWeighting = false;
end

%% MEDI dipole inversion

if ~isfield(hdr, 'isCSF')
    hdr.isCSF = true;
end

if ~isfield(hdr, 'lambda')
    hdr.lambda = 1000;
end

if ~isfield(hdr, 'lam_CSF')
    hdr.lam_CSF = 10;
end

if ~isfield(hdr, 'radius')    
    hdr.radius = 5;
end

if ~isfield(hdr, 'isMerit')    
    hdr.isMerit = 0;
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

if ~isfield(hdr, 'percentage')    
    hdr.percentage = 0.3;
end

if contains(dataset, "TE1to")
    hdr.isSMV = false;
end

if ~isfield(hdr, 'isSMV')
    hdr.isSMV = false; 
    hdr.RelativeResidualMasking = true;
else
    hdr.RelativeResidualMasking = false;
end



%% Correcting for NaCl bulk medium

if ~isfield(hdr, 'CorrectNaCl')
    hdr.CorrectNaCl = true;
end

%% Analysing earlier steps

if ~isfield(hdr, 'noDipoleInversion')
    hdr.noDipoleInversion = false; % Saves recon time - analyse precursor steps
end

if ~isfield(hdr, 'saveInfCyl')
    hdr.saveInfCyl = true; % Exports NIfTI file of susceptibility map (in ppm), calculated by infinite cylinder model
end

if ~isfield(hdr, 'saveFieldMap')
    hdr.saveFieldMap = true;  % Exports NIfTI file of field map (in Hz)
end


%% Exporting masks

if ~isfield(hdr, 'useQualityMask')
    hdr.useQualityMask = true;
end

if ~isfield(hdr, 'ROMEO_qualityMask')
    hdr.ROMEO_qualityMask = false;
end

if ~isfield(hdr, 'saveMaskUse')
    hdr.saveMaskUse = true; % Exports NIfTI file of Mask_Use
end

if ~isfield(hdr, 'saveQSMMask')
    hdr.saveQSMMask = true; % Exports NIfTI file of QSM_Mask
end

if ~isfield(hdr, 'saveComplementMask')
    hdr.saveComplementMask = false; % Exports NIfTI file of CSF_Mask (not eroded)
end

if ~isfield(hdr, 'saveErodedComplementMask')
    hdr.saveErodedComplementMask = false; % Exports NIfTI file of CSF_Mask (eroded by 10 mm)
end

%% Save workspace to run a for loop of Dipole Inversion
if ~isfield(hdr, 'saveWorkspace')
    hdr.saveWorkspace = true;
end

%% Import data: Exclude later TEs 
% (1) Include "TE1to#" at the beginning of the dataset string, and
% (2) Include "_3T" or "_7T" at the end of the dataset string.
if contains(dataset, 'TE')
    pos = strfind(dataset, '_');
    dataset_fn = [FS_str, dataset(pos+1:end)];
else
    dataset_fn = dataset;
end

matfile = fullfile(hdr.path_to_data, [dataset_fn, '.mat']);
fileInfo = who('-file', matfile);
if any(matches(fileInfo, 'Magn')) && any(matches(fileInfo, 'Phs')) && ...
        any(matches(fileInfo, 'R2s')) % any(matches(fileInfo, 'Mask_Use')) && 
    load(matfile, 'Magn', 'Phs', 'R2s');
else
    error('Missing required fields in mat file')
end


%% TE selection

if contains(dataset, 'TE') && contains(dataset, 'to')
    pos = strfind(dataset, 'to');
    TEi = str2double(dataset(pos-1));
    TEf = str2double(dataset(pos+2));
    Magn = Magn(:, :, :, TEi:TEf); %#ok<*NODEF>
    Phs = Phs(:, :, :, TEi:TEf);
    n_TE = TEf - TEi + 1;
    % TE  = TE(TEi:TEf);
% elseif contains(hdr.output_dir, 'OddTEs')
%     oddIdx = 1:2:length(TE);
%     TE = TE(oddIdx);
%     Magn = Magn(:, :, :, oddIdx);
%     Phs = Phs(:, :, :, oddIdx);
% elseif contains(hdr.output_dir, 'EvenTEs')
%     evenIdx = 2:2:length(TE);
%     TE = TE(evenIdx);
%     Magn = Magn(:, :, :, evenIdx);
%     Phs = Phs(:, :, :, evenIdx);    
end

%% Ensure phase is within a 2pi range (-pi to pi).
Phs = DICOM2Radians(Phs);
%% In some cases, Invert sign of the phase.
% if ~isfield(hdr, 'isInvert')
if FS == 7
    hdr.isInvert = true; 
end

if isfield(hdr, 'isInvert') && hdr.isInvert
    Phs = -Phs;
end

%% Run quadrants independently -> in cases of overlapping SMV kernels during V-SHARP
% this slightly improves the 3rd concentration of each quadrant
matrix_size0 = size(Magn, [1,2,3]); 
if isfield(hdr, 'j')
    [Magn, Phs, R2s] = ProcessQuadIdpt(dataset, Magn, Phs, R2s, hdr);
end

%% Exclude distal slices, and setup restricted TE datasets (if applicable)
if ~isfield(hdr, 'excludeDistal')
    hdr.excludeDistal = false; % Excludes erroneous voxels at distal slices.
end

if FS == 3
    TE                  = (1.87:1.87:n_TE*1.87)./1000;
    voxel_size          = [1 1 1];
    if hdr.excludeDistal
        z_full = 1:matrix_size0(3);
        z_keep = 21:94;
    end
elseif FS == 7
    TE                  = (3.15:3.15:n_TE*3.15)./1000;
    voxel_size          = [0.7 0.7 0.7];
    if hdr.excludeDistal
        z_full = 1:matrix_size0(3);
        z_keep = 41:150;
    end
end

% Zero-Padding
FOV = round(1.5.*[192 192 112]); % [288 x 288 x 168] vox^3
Magn = pad_or_crop_target_size(Magn, voxel_size, FOV);
Phs = pad_or_crop_target_size(Phs, voxel_size, FOV);
R2s = pad_or_crop_target_size(R2s, voxel_size, FOV);
matrix_size         = size(Magn, [1,2,3]); %#ok<*NODEF>


%% Error handling
Phs(isnan(Phs))=0;
Phs(isinf(Phs))=0;

% Exclude distal slices which might aliasing.
if hdr.excludeDistal
    Phs(:, :, setdiff(z_full, z_keep), :) = 0;
    Magn(:, :, setdiff(z_full, z_keep), :) = 0;
end

iMag                = sqrt(sum(abs(Magn).^2,4));
MagnFinalTE         = Magn(:,:,:,end);

%% Package outputs into 'hdr' struct
hdr.FOV = FOV;
hdr.Magn = Magn;
hdr.Phs = Phs;
hdr.R2s = R2s;
hdr.MagnFinalTE = MagnFinalTE;
hdr.TE = TE;
hdr.iMag = iMag;
hdr.voxel_size = voxel_size;
hdr.matrix_size = matrix_size;
hdr.FS = FS;
hdr.dataset = dataset;
end