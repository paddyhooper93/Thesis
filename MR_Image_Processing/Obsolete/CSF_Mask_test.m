function CSF_Mask_test(dataset, output_dir)
    R2s_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\R2s';
    Msk_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\FermiFilt_SDC';

    R2s_fn = fullfile(R2s_dir, [dataset, '_R2s']);
    load(R2s_fn, "R2s");
    
    Msk_fn = fullfile(Msk_dir, [dataset, '_mask.nii.gz']);
    Msk_nii = load_untouch_nii(Msk_fn);
    Mask_Use = single(Msk_nii.img);

    if contains(dataset, "3T")
        voxel_size=[1 1 1];
    elseif contains(dataset,"7T")
        voxel_size=[.75 .75 .75];
    end

    [ CSF_Mask ] = extract_CSF(R2s, Mask_Use, voxel_size);
    export_nii(single(CSF_Mask), fullfile(output_dir, [dataset, '_CSF_Mask']), voxel_size);
    % % Morphological erosion    
    erode_radius_voxel   = min(round(2 ./ voxel_size)); % 2 mm
    CSF_Mask = imerode(CSF_Mask, strel('sphere', double(erode_radius_voxel)));
    % Morphological opening
    open_radius_voxel   = min(round(2 ./ voxel_size)); % 2 mm
    CSF_Mask = imopen(CSF_Mask, strel('sphere', double(open_radius_voxel)));
    export_nii(single(CSF_Mask), fullfile(output_dir, [dataset, '_CSF_Mask_MO']), voxel_size);
    % Use SEPIA function to get largest object
    connectivity = 6;
    [ CSF_Mask ] = getLargestObject(CSF_Mask, connectivity);        
    export_nii(single(CSF_Mask), fullfile(output_dir, [dataset, '_CSF_Mask_MO_GLO']), voxel_size);

end
    