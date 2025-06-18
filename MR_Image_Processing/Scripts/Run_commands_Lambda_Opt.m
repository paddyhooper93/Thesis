clearvars; close all

lam_range = 10^3:10^3:5*10^3;
for dataset = {'3T_Neutral', '7T_Neutral'}
    input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\SNRwAVG_PDF';
    workspace_fn = fullfile(input_dir, [dataset{1}, '_workspace.mat']);
    load(workspace_fn, "weights", "RDF", "hdr" )
    hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\DiscPrinc';
    magn_dir='C:\Users\rosly\Documents\Valerie_PH\Data\Padded\N4_deGibbs';
    magn_fn = fullfile(magn_dir, [dataset{1}, '_Magn.nii.gz']);
    magn_nii = load_untouch_nii(magn_fn);
    magn = pad_or_crop_target_size(magn_nii.img, hdr.voxel_size);
    hdr.Mask_Use = pad_or_crop_target_size(hdr.BET_Mask, hdr.voxel_size);
    if contains(dataset{1}, '3T')
        hdr.Mask_Use = imerode(hdr.Mask_Use, strel('sphere', 2));
    end
    hdr.iMag = sqrt(sum(abs(magn).^2,4)) .* hdr.Mask_Use;
    
    for idx = 1:length(lam_range)
        hdr.lambda = lam_range(idx);
        hdr.QSM_Prefix = ['QSM_SMV3_Lambda', num2str(hdr.lambda)]; 
        hdr.noDipoleInversion = false; 
        hdr.lam_CSF = 100; hdr.isSMV = true; hdr.radius = 3; hdr.useQualityMask = false; hdr.percentage = 0.5;
        DipoleInversion(weights, RDF, hdr);
    end

    if contains(dataset{1}, '3T')
        epsilon_target = 110.0;
    else
        epsilon_target = 94.6;
    end

    % use linear interpolation to obtain the optimal parameter
    interp = 'linear';
    paramInterp = linspace(min(pc_range),max(pc_range),1000);
    paramCostInterp = interp1(gather(pc_range),gather(epsilon_f),gather(paramInterp),interp);
end