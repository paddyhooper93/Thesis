function [RDF, hdr] = BackgroundFieldCorrection(iFreq, hdr)
% Argin1: RDF "relative difference field", i.e. field map after BFC
% Argin2: "hdr" structure, used to parse variables
% Argout1: iFreq "frequency map", i.e. field map before BFC
% Argout2: "hdr" structure, variables parsed
% Step 1: Erode mask before background field correction
% Step 2: Background field correction and mask erosion (if SHARP-based BFC)
% Step 3: Multiply mask by relative residual mask (when not using MEDI-SMV)
% Step 4: Refine B1 transmit fields (for 7 T data)
% Step 5: Export infinite cylinder approximation

matrix_size = hdr.matrix_size;
voxel_size = hdr.voxel_size;
Mask_Use = hdr.Mask_Use;

%% Step 1: Erode mask before background field correction

if hdr.erode_before_radius > 0
    e_vox=round(hdr.erode_before_radius/min(voxel_size));
    fprintf(['Eroding ', num2str(e_vox), ' vox from edges before background field correction... \n'])
    Mask_Use = imerode(Mask_Use, strel('sphere', e_vox));
end

% mosaic( single(Mask_Use), 12, 12, 16, 'Mask before BFC')

%% Step 2: Background field correction: RESHARP or V-SHARP are most reliable.

fprintf('Background field correction: %s \n', hdr.BFCMethod)

if contains(hdr.BFCMethod, 'LBV')
    
    tol = 1e-4;
    depth = 4;
    peel = 1;
    RDF = LBV(iFreq, Mask_Use, matrix_size, voxel_size, tol, depth, peel);
    
end


if contains(hdr.BFCMethod, 'V-SHARP') && contains(hdr.BFCMethod, 'STI')
    %% STI-Suite implementation: closed source.
    radiusMax_str = regexp(hdr.BFCMethod, 'V-SHARP (\d+)SMV', 'tokens');
    radiusMax_mm = str2double(radiusMax_str{1});
    [RDF, Mask_Use] = V_SHARP(iFreq, Mask_Use, 'voxelsize', voxel_size, 'smvsize', radiusMax_mm);
end

if contains(hdr.BFCMethod, 'V-SHARP') && contains(hdr.BFCMethod, 'SEPIA')
    
    %% SEPIA implementation: similar to Bilgic, but no high-pass filter.
    % According to Ozbay et al., 2017, set radiusMax to 8 mm.
    % SMV radius defined in vox for BKGRemovalVSHARP function.
    
    radiusMax_str = regexp(hdr.BFCMethod, 'V-SHARP (\d+)SMV', 'tokens');
    radiusMax_mm = str2double(radiusMax_str{1});
    radiusMax_vox = ceil(radiusMax_mm/min(voxel_size));
    radiusMin = 1; radiusStep = 1; % vox
    fprintf('radius min: %d, radius step: %d, radius max: %d (vox) \n', radiusMin, radiusStep, radiusMax_vox);
    % Execute Background field removal
    radiusArray = radiusMax_vox:-radiusStep:radiusMin;
    [RDF, Mask_Use] = BKGRemovalVSHARP(iFreq, Mask_Use, matrix_size, 'radius', radiusArray);
    
end

if matches(hdr.BFCMethod, 'PDF')

    iFreq(isnan(iFreq)) = 0;
    iFreq(isinf(iFreq)) = 0;
    N_std = hdr.fieldMapSD;
    B0_dir = [0 0 1];
    n_CG = 30;
    tol = 0.1;
    space = 'imagespace';
    n_pad = 40;
    RDF = PDF(iFreq, N_std, Mask_Use, matrix_size, voxel_size, B0_dir, tol, ...
        n_CG, space, n_pad);
    
elseif matches(hdr.BFCMethod, 'RESHARP')
    
    radius          = 4; % fixed SMV radius in mm.
    alpha           = 0.01; % Tikhonov regularization parameter
    RDF             = RESHARP(iFreq, Mask_Use, matrix_size, voxel_size, radius, alpha);
    fprintf('Eroding by RESHARP radius: %d (mm) \n', radius)
    Mask_Use        = single(SMV(Mask_Use, matrix_size, voxel_size, radius)>0.999);
end

% mosaic( Mask_Use, 12, 12, 17, 'Mask after BFC')

RDF = RDF .* Mask_Use;
hdr.Mask_Use = Mask_Use;

%% Step 3: Refine B1 transmit fields (B1+) -> only necessary at 7 T.
%% Produces a flatter tissue field when using surface coils.

if hdr.FS == 7
    [~, RDF, ~]     = PolyFit(RDF, hdr.Mask_Use, hdr.poly_order);
    fprintf(['Fitting and subtracting a polynomial of order', num2str(hdr.poly_order), ' ... \n'])
end

mosaic( RDF, 12, 12, 15, 'Local/Tissue Field (Hz)', [-50 50] )

%% Step 4: Export susceptibility map by infinite cylinder model or Delta

if isfield(hdr, 'saveInfCyl') && hdr.saveInfCyl
    %% Infinite Cylinder Model -> useful for assessing error propagation during dipole inversion.
    %% This is a benefit of the cylindrical phantom.
    [Chi_prl] = CalculateChiMapfromLF(RDF, hdr.FS);
    if hdr.CorrectNaCl
        Chi_prl = Chi_prl + (-0.1106 .* Mask_Use); % Bulk medium correction
        disp('Correcting for susceptibility of bulk medium.')
    end
    
    if ~isfield(hdr, 'j')
        export_nii(Chi_prl, fullfile(hdr.output_dir, [hdr.dataset, '_InfCyl']), hdr.voxel_size);
    elseif hdr.j == 1
        export_nii(Chi_prl, fullfile(hdr.output_dir, [hdr.dataset, '_quad1_InfCyl']), hdr.voxel_size);
    elseif hdr.j == 2
        export_nii(Chi_prl, fullfile(hdr.output_dir, [hdr.dataset, '_quad2_InfCyl']), hdr.voxel_size);
    elseif hdr.j == 3
        export_nii(Chi_prl, fullfile(hdr.output_dir, [hdr.dataset, '_quad3_InfCyl']), hdr.voxel_size);
    elseif hdr.j == 4
        export_nii(Chi_prl, fullfile(hdr.output_dir, [hdr.dataset, '_quad4_InfCyl']), hdr.voxel_size);
    end
    
end

if isfield(hdr, 'saveDelta') && hdr.saveDelta
    %% Export "Delta" : the local field converted from "Hz" to "ppm".
    %% After exporting, Delta must be co-registered to the neutral frame for COSMOS processing.
    [~, Delta] = CalculateChiMapfromLF(RDF, hdr.FS);
    export_nii(pad_or_crop_target_size(Delta, hdr.voxel_size), fullfile(hdr.output_dir, [hdr.dataset, '_Delta']), hdr.voxel_size);
end