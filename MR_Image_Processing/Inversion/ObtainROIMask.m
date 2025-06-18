function [Mask_Use] = ObtainROIMask(hdr, roi_mask_fn)
    ROI_Mask_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\Brain_ROI_Mask'; 
    if contains(hdr.dataset, 'Neutral')
        nii_fn = [hdr.dataset,'_', roi_mask_fn, '.nii.gz'];
    else
        nii_fn = [hdr.dataset(1:2), '_Neutral_to', hdr.dataset(3:7), '_', roi_mask_fn, '.nii.gz'];               
    end
    nii = load_untouch_nii(fullfile(ROI_Mask_dir, nii_fn));    
    Mask_Use = pad_or_crop_target_size(nii.img, hdr.voxel_size);
    Mask_Use = smooth3(Mask_Use, 'gaussian', 3, 2);
    Mask_Use = Mask_Use > 0.5; % Binarize
    Mask_Use = imfill(Mask_Use, 6, 'holes');
end