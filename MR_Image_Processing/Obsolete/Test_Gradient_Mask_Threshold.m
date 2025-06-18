clearvars; close all
% '3T_Neutral', '3T_Rot1', '3T_Rot2', '3T_Rot3', '3T_Rot5', '3T_Rot6',
% '7T_Neutral', '7T_Rot1', '7T_Rot2', '7T_Rot3', '7T_Rot4', '7T_Rot5'
for dataset = {'3T_Neutral', '3T_Rot1', '3T_Rot2', '3T_Rot3', '3T_Rot5', '3T_Rot6', ...
        '7T_Rot1', '7T_Rot2', '7T_Rot3', '7T_Rot4', '7T_Rot5'}

    input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\SNRwAVG_PDF';
    workspace_fn = fullfile(input_dir, [dataset{1}, '_workspace.mat']);
    load(workspace_fn, "weights", "RDF", "hdr" )
    hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\MEDI_Opt\Pc05';
    % mask_dir='C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\Brain_ROI_Mask';
    % if contains(dataset{1}, 'Neutral')
    %     mask_fn = fullfile(mask_dir, [dataset{1}, '_Mask_Use.nii.gz']);
    % else
    %     mask_fn = fullfile(mask_dir, [dataset{1}(1:2), '_Neutral_to_', dataset{1}(4:end), '_Mask_Use.nii.gz']);
    % end
    % mask_nii = load_untouch_nii(mask_fn);
    % Mask = mask_nii.img;
    magn_dir='C:\Users\rosly\Documents\Valerie_PH\Data\Padded\N4_deGibbs';
    magn_fn = fullfile(magn_dir, [dataset{1}, '_Magn.nii.gz']);
    magn_nii = load_untouch_nii(magn_fn);
    magn = pad_or_crop_target_size(magn_nii.img, hdr.voxel_size);
    % hdr.Mask_Use = pad_or_crop_target_size(hdr.BET_Mask, hdr.voxel_size);
    Mask = hdr.Mask_Use;
    Mask = hdr.fieldMapSD < (mean(hdr.fieldMapSD(Mask == 1), "all"));
    iMag = pad_or_crop_target_size(hdr.iMag, hdr.voxel_size);
    Mask = pad_or_crop_target_size(Mask, hdr.voxel_size);
    if contains(dataset{1}, '3T')
        SD_air = 0.77;
    elseif contains(dataset{1}, '7T')
        SD_air = 1.28;
        magn = magn(:,:,:,1:4);
    end
    grad = @fgrad;
    grad_thresh = SD_air*5;
    wG = abs(grad(iMag.*(Mask>0), hdr.voxel_size));
    numerator = sum(wG(:)>grad_thresh);
    denominator = nnz(Mask(:)==1);     
    percentage = numerator / denominator;
    fprintf('\n Numerator: %d, Denominator: %d, gradient threshold :%2.0f \n', numerator, denominator, percentage * 100)
end        