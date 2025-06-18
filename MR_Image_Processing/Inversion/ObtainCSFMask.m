function [CSF_Mask] = ObtainCSFMask(hdr)
    CSF_Mask_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\CSF_Mask'; 
    if contains(hdr.dataset, 'Neutral')
        % R2s = pad_or_crop_target_size(hdr.R2s, hdr.voxel_size);
        % Mask_Use = pad_or_crop_target_size(hdr.Mask_Use, hdr.voxel_size);
        %[CSF_Mask] = Automatic_CSF_Referencing(R2s, Mask_Use, hdr.voxel_size);
        nii_fn = [hdr.dataset,'_CSF_Mask.nii.gz'];
    else
        nii_fn = [hdr.dataset(1:2), '_Neutral_to', hdr.dataset(3:7),'_CSF_Mask.nii.gz'];               
    end
    nii = load_untouch_nii(fullfile(CSF_Mask_dir, nii_fn));    
    CSF_Mask = pad_or_crop_target_size(nii.img, hdr.voxel_size);
end