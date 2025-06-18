function [CSF_Mask] = Automatic_CSF_Referencing(R2s, Mask_Use, voxel_size)

    % Automatic CSF referencing
    [ CSF_Mask ] = extract_CSF(R2s, Mask_Use, voxel_size, 0, 10);

    % Multiplication by brain ROI mask
    CSF_Mask = CSF_Mask .* Mask_Use;
    
    % Morphological opening: remove disconnected voxels
    open_radius_voxel   = min(round(2 ./ voxel_size)); % 2 mm
    CSF_Mask = imopen(CSF_Mask, strel('sphere', double(open_radius_voxel)));
    
    % Use SEPIA function: set the 3D-connectivity to 'edges only' = 6
    connectivity = 6;
    CSF_Mask = getLargestObject(CSF_Mask, connectivity) > 0;

end