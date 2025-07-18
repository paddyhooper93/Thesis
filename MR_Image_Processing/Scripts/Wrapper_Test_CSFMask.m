input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\PDF';
test_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\CSF_Mask_Test';

if 7~=exist("test_dir", "dir")
    mkdir(test_dir);
end
% '3T_Neutral', '3T_Rot1', '3T_Rot2', '3T_Rot3', '3T_Rot5', '3T_Rot6', ...

for dataset = {
        '7T_Neutral'} 
    
    workspace_fn = fullfile(input_dir, [dataset{1}, '_workspace.mat']);
    load(workspace_fn, "hdr" )  
    Mask_Use = hdr.Mask_Use > 0;
    voxel_size = hdr.voxel_size;
    R2s = hdr.R2s;
    Mask_Use             = hdr.qualityMask .* Mask_Use;
    Mask_Use             = hdr.relativeResidualMask .* Mask_Use;
    % Automatic CSF referencing
    [ CSF_Mask ] = extract_CSF(R2s, Mask_Use, voxel_size, 0, 10);

    % Morphological opening: remove disconnected voxels
    open_radius_voxel   = min(round(2 ./ voxel_size)); % 2 mm
    CSF_Mask = imopen(CSF_Mask, strel('sphere', double(open_radius_voxel)));
    
    % Use SEPIA function: set the 3D-connectivity to 'edges & corners' = 26
    connectivity = 6;
    CSF_Mask = getLargestObject(CSF_Mask, connectivity) > 0;

    export_nii(single(CSF_Mask), fullfile(test_dir, [dataset{1}, '_CSF_Mask']), hdr.voxel_size);

end
