clearvars; close all
% '3T_Neutral', '3T_Rot1', '3T_Rot2', '3T_Rot3', '3T_Rot5', '3T_Rot6',
% '7T_Neutral', '7T_Rot1', '7T_Rot2', '7T_Rot3', '7T_Rot4', '7T_Rot5'
for dataset = {'7T_Rot1', '7T_Rot2', '7T_Rot3', '7T_Rot4', '7T_Rot5'}

    input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\SNRwAVG_PDF';
    workspace_fn = fullfile(input_dir, [dataset{1}, '_workspace.mat']);
    load(workspace_fn, "weights", "RDF", "hdr" )
    hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\MEDI_Opt\Pc05';
    mask_dir='C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\Brain_ROI_Mask';
    if contains(dataset{1}, '3T')
    if contains(dataset{1}, 'Neutral')
        mask_fn = fullfile(mask_dir, [dataset{1}, '_Bet_Mask_Erode.nii.gz']);
    else
        mask_fn = fullfile(mask_dir, [dataset{1}(1:2), '_Neutral_to_', dataset{1}(4:end), '_Bet_Mask_Erode.nii.gz']);
    end
    mask_nii = load_untouch_nii(mask_fn);
    Mask = pad_or_crop_target_size(mask_nii.img, hdr.voxel_size);
    else
        Mask = pad_or_crop_target_size(hdr.Mask_Use, hdr.voxel_size);
    end
    
    % Mask = pad_or_crop_target_size(hdr.BET_Mask, hdr.voxel_size);
    if contains(dataset{1}, '3T')
        magn_dir='C:\Users\rosly\Documents\Valerie_PH\Data\Padded\N4_deGibbs';
        magn_fn = fullfile(magn_dir, [dataset{1}, '_Magn.nii.gz']);
        magn_nii = load_untouch_nii(magn_fn);
        magn = pad_or_crop_target_size(magn_nii.img, hdr.voxel_size);
        iMag = sqrt(sum(abs(magn).^2,4)) .* Mask;
    else
        iMag = pad_or_crop_target_size(hdr.iMag, hdr.voxel_size) .* Mask;
        % Mask = pad_or_crop_target_size(hdr.Mask_Use, hdr.voxel_size);
        % if ~contains(dataset{1}, 'Rot2')
            % Mask = imerode(Mask, strel('sphere', 3./min(hdr.voxel_size)));
        % end
    end

    
    if contains(dataset{1}, '3T')
        SD_air = 22.72;
    else
        % magn = magn(:,:,:,1:4);
        SD_air = 11.03;
    end
    grad = @fgrad;
    grad_thresh = SD_air*5;
    wG = abs(grad(iMag.*(Mask>0), hdr.voxel_size));
    numerator = sum(wG(:)>grad_thresh);
    denominator = nnz(Mask(:)==1);     
    percentage = numerator / denominator;
    fprintf('\n Numerator: %d, Denominator: %d, gradient threshold :%2.0f \n', numerator, denominator, percentage * 100)

    
    
    % expected_noise_level = denominator * (1/(hdr.FS*42.6*2*pi*hdr.delta_TE))^2;
    % fprintf('\n Expected noise level: %.2f \n', expected_noise_level);

    % export_nii(Mask, fullfile(input_dir, [dataset{1}, '_Bet_Mask']), hdr.voxel_size);
    % export_nii(Mask_Erode, fullfile(input_dir, [dataset{1}, '_Bet_Mask_Erode']), hdr.voxel_size);
        % hdr.QSM_Prefix = 'QSM_SMV3'; 
        % hdr.noDipoleInversion = false; 
        % hdr.lam_CSF = 100; hdr.isSMV = true; hdr.radius = 3; hdr.useQualityMask = false; hdr.percentage = 0.5; hdr.lambda = 1000;
        % DipoleInversion(weights, RDF, hdr);

end