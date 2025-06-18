function [c_d_m, c_r_m, sd_csf, mean_csf, metrics, hdr] = DipoleInversion(weights, RDF, hdr)
% Function that parses dipole inversion parameters
% Output args: 
% c_d_m = cost_data_medi
% c_r_m = cost_reg_medi
% sd_csf = standard deviation in csf mask (streaking artifact metric)
% mean_csf = mean value in csf mask

% Obtain header information and pad to FOV [210, 240, 192]
voxel_size = hdr.voxel_size;
% FOV = [400 400 400].*voxel_size;
% FOV = [210, 240, 192];
FOV = hdr.FOV;
RDF = pad_or_crop_target_size(RDF, voxel_size, FOV);
weights = pad_or_crop_target_size(weights, voxel_size, FOV);
hdr.matrix_size = size(RDF);
hdr.iMag = pad_or_crop_target_size(hdr.iMag, voxel_size, FOV);
hdr.qualityMask = pad_or_crop_target_size(hdr.qualityMask, voxel_size, FOV);

% Obtain boolean and numeric parameters from header
useQualityMask = hdr.useQualityMask;
isCSF = hdr.isCSF;
noDipoleInversion = hdr.noDipoleInversion;
FS = hdr.FS;

if useQualityMask
    roi_mask_fn = 'Mask_Use'; 
else
    roi_mask_fn = 'Bet_Mask_Erode';    
end

if contains(hdr.path_to_data, 'Valerie_PH')
    [Mask_Use] = ObtainROIMask(hdr, roi_mask_fn);
else
    [Mask_Use] = hdr.Mask_Use;
end
if isfield(hdr, 'ROI_Mask')
    [Mask_Use] = hdr.ROI_Mask;
end

Mask_Use = pad_or_crop_target_size(Mask_Use, voxel_size, FOV);
RDF = RDF .* Mask_Use;

N_std = Mask_Use ./ weights;
N_std(isnan(N_std)) = 0;
N_std(isinf(N_std)) = 0;

if isCSF
    if contains(hdr.path_to_data, 'Valerie_PH')
        [CSF_Mask] = ObtainCSFMask(hdr);
        CSF_Mask = imerode(CSF_Mask, strel('sphere', 1));
    else
        if hdr.FS == 3
            CSF_Mask = imdilate(hdr.CSF_Mask, strel('sphere', 1));
        else
            CSF_Mask = imerode(hdr.CSF_Mask, strel('sphere', 1));  
        end
    end
    CSF_Mask = pad_or_crop_target_size(CSF_Mask, voxel_size, FOV);
else
    CSF_Mask = [];
end

if FS == 3
    B0 = 2.89;
elseif FS == 7
    B0 = 7;
end
gyro = 42.6;
CF  = B0*gyro*10^6;

% Exit script early if true
if noDipoleInversion
    return
end 

%% MEDI dipole inversion
[QSM, c_d_m, c_r_m]  = MEDIL1_Wrapper(RDF, ...
    N_std, Mask_Use, CSF_Mask, CF, hdr);

if isfield(hdr, 'param_opt') && hdr.param_opt
    return
end

% QSM = zeros(size(RDF));
% c_d_m = 0;
% c_r_m = 0;


%% Referencing to CSF_Mask
% Generate CSF_Mask for referencing chi-map
if contains(hdr.path_to_data, 'Valerie_PH')
    [CSF_Mask] = ObtainCSFMask(hdr);
else
        if hdr.FS == 3
            CSF_Mask = imdilate(hdr.CSF_Mask, strel('sphere', 1));
        else
            CSF_Mask = imerode(hdr.CSF_Mask, strel('sphere', 1));  
        end
end
CSF_Mask = pad_or_crop_target_size(CSF_Mask, voxel_size, FOV);
% Referencing
QSM = QSM - mean(QSM(CSF_Mask>0));

%% Voxel-wise metrics

% Generate internal field mask for computing voxel-wise metrics:
if contains(hdr.path_to_data, 'Valerie_PH')
    [mask_analysis] = generateinternalmask_valerie(hdr);
else
    [mask_analysis] = generateinternalfieldmask(hdr);
end
% export_nii(mask_analysis, fullfile(hdr.output_dir, [hdr.dataset, '_internal_field_mask']), voxel_size);   

if contains(hdr.path_to_data, 'QSM_PH')
    % Generate analytical chi map for cylindrical internal fields
    [chi_reference] = CalculateChiMapfromLF( RDF, FS );
else
    % Load COSMOS chi map for anthropomorphic phantom
    dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\COSMOS_Reference';
    if hdr.FS == 3
        fn = '3T_Neutral_to_Rot5_chi_CF_6_Orient_FLIRT.nii.gz';
    else
        fn = '7T_Neutral_to_Rot5_chi_CF_5_Orient_FLIRT.nii.gz';
    end
    nii = load_untouch_nii(fullfile(dir, fn));
    chi_reference = pad_or_crop_target_size(nii.img, voxel_size, FOV);
end

% Use function in FANSI_Toolbox (RMSE, HFEN, XSIM)
[ metrics ] = compute_metrics( QSM, chi_reference, mask_analysis );
% Streaking artifact metric
[sd_csf, mean_csf] = std(QSM(CSF_Mask>0), "omitnan");    




%% Referencing to water protons
% Center susceptibility to water protons using known susceptibility of NaCl-doped $\chi$
QSM_referenced = QSM + (-0.1106 .* Mask_Use);
if contains(hdr.path_to_data, 'Valerie_PH')
    QSM_referenced = pad_or_crop_target_size(QSM_referenced, hdr.voxel_size);
end

%% Export QSM as a NIfTI file
if ~isfield(hdr, 'QSM_Prefix')
    hdr.QSM_Prefix = 'QSM';
end

if ~isfield(hdr, 'j')
    export_nii(QSM_referenced, fullfile(hdr.output_dir, [hdr.dataset, '_', hdr.QSM_Prefix]), hdr.voxel_size);
elseif hdr.j == 1
    export_nii(QSM_referenced, fullfile(hdr.output_dir, [hdr.dataset, '_quad1_QSM']));
elseif hdr.j == 2
    export_nii(QSM_referenced, fullfile(hdr.output_dir, [hdr.dataset, '_quad2_QSM']));
elseif hdr.j == 3
    export_nii(QSM_referenced, fullfile(hdr.output_dir, [hdr.dataset, '_quad3_QSM']));
elseif hdr.j == 4
    export_nii(QSM_referenced, fullfile(hdr.output_dir, [hdr.dataset, '_quad4_QSM']));
end

% mosaic( QSM_referenced, 12, 12, 13, 'QSM-map', [-0.5 0.5] )

