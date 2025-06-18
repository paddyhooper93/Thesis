% '3T_Neutral', '3T_Rot1', '3T_Rot2', '3T_Rot3', '3T_Rot5', '3T_Rot6'
% '7T_Neutral', '7T_Rot1', '7T_Rot2', '7T_Rot3', '7T_Rot4', '7T_Rot5'
clearvars
for dataset = {'7T_Rot4', '7T_Rot5', '3T_Rot3', '3T_Rot5', '3T_Rot6'}
    if contains(dataset{1}, '3T')
        vsz = [1 1 1];
        if contains(dataset{1}, 'Neutral')
            fov = [180 240 120];
        elseif contains(dataset{1}, '1') || contains(dataset{1}, '2')
            fov = [240 240 160];
        elseif contains(dataset{1}, '3') || contains(dataset{1}, '5') || contains(dataset{1}, '6')
            fov = [180 240 160];
        else
            fov = [180 240 144];
        end
        TEf = 7;
    else
        
         if contains(dataset{1}, 'Neutral')
             vsz = [0.6818 0.6818 0.6800];
             fov = [264 352 208].*min(vsz);
         else
             vsz = [.75 .75 .75];
             fov = [280 320 192].*min(vsz);
         end
         TEf = 4;
    end

    % Compute expected noise level
    dir_nl = 'C:\Users\rosly\Documents\Valerie_PH\Data\Noise_Level';
    magn_fn = fullfile(dir_nl, [dataset{1}, '_Magn.nii.gz']);
    mask_air_fn = fullfile(dir_nl, [dataset{1}, '_mask_air.nii.gz']);
    magn_nii = load_untouch_nii(magn_fn);
    mask_air_nii = load_untouch_nii(mask_air_fn);
    Magn = single(magn_nii.img);
    Magn_E1 = Magn(:,:,:,1);
    Mask_Air = mask_air_nii.img;
    epsilon = std(real(Magn_E1(Mask_Air==1)))/0.66;


    fprintf('\n Expected noise_level: %.2f \n', epsilon);    

    

    % Gradient mask
    grad = @fgrad;
    % dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\SDC';
    % load(fullfile(dir, [dataset{1}, '_forQSM.mat']), "Mask_Use");
    hdr.voxel_size = vsz;
    hdr.dataset = dataset{1};
    roi_mask_fn = 'BET_Mask_Erode';
    [Mask_Use] = ObtainROIMask(hdr, roi_mask_fn);
    Mask_Use = pad_or_crop_target_size(Mask_Use, vsz, fov);
    magn_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\N4_deGibbs';
    magn_fn = fullfile(magn_dir, [dataset{1}, '_Magn.nii.gz']);
    magn_nii = load_untouch_nii(magn_fn);
    magn = pad_or_crop_target_size(magn_nii.img, vsz, fov);
    iMag = magn(:,:,:,1);
    field_noise_level = epsilon;
    % field_noise_level = 0.01*max(iMag(:));
    wG = abs(grad(iMag.*(Mask_Use>0), vsz)).*(Mask_Use==1);
    wG_mean = mean(wG, 4);
    numerator = nnz(wG_mean(:)>field_noise_level*5/3); % 5/3 ("5 times the noise level in magnitude images", divide by number of gradient volumes (3))
    denominator = nnz(Mask_Use(:)>0);
    percentage = numerator / denominator;
    fprintf('\n Percentage : %.2f \n', percentage * 100);
end

%%
for dataset = {'3T_Neutral', '3T_Rot1', '3T_Rot2', '7T_Rot4', '7T_Rot5'}
    
    
    if contains(dataset{1}, '3T')
        B0 = 2.89;
        vsz = [1 1 1];
    else
        B0 = 7;
        vsz = [.75 .75 .75];
    end
    gamma = 42.6*2*pi; % [rad/s/T]
    CF = gamma * B0; % [rad/s]

    input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\SNRwAVG_PDF';
    input_fn = fullfile(input_dir, [dataset{1}, '_workspace.mat']);
    load(input_fn, "hdr", "weights");
    dir='C:\Users\rosly\Documents\Valerie_PH\Data\Padded\N4_deGibbs';
    load(fullfile(dir, 'iMag.mat'), "iMag")
    noise_std = pad_or_crop_target_size(hdr.fieldMapSD,vsz) ;
    Mask = pad_or_crop_target_size(hdr.Mask_Use,vsz) ;
    weights = pad_or_crop_target_size(weights, vsz);
    iMag = iMag.([dataset{1}(4:end), '_', dataset{1}(1:2)]);
    
    % Compute expected discrepancy
    expected_discrepancy = disc_principle(noise_std, weights, CF, Mask);
    fprintf('\n Expected discrepancy: %.2f \n', expected_discrepancy);    
    % Gradient mask
    grad = @fgrad;
    wG = abs(grad(iMag.*(Mask>0), vsz));
    numerator = sum(wG(:)>noise_level_cplx);
    denominator = nnz(Mask(:)==1);
    percentage = numerator / denominator;
    fprintf('\n Percentage : %2f \n', percentage * 100);
    % [wG1]=gradient_mask_fansi(iMag, Mask, grad, vsz, noise_level);
    % export_nii(single(wG1), [dataset{1}, '_wG'], vsz);
end
