function CSF_Mask_Generation()
% '3T_Rot3' '3T_Rot1', '3T_Rot5'
input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\';
output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\CSF_Mask\';
% '7T_Rot1', '7T_Rot3', '7T_Rot5'
for dataset = {'3T_Rot1'}
    Mask_fn = [input_dir, dataset{1}, '_Mask_Padded.nii.gz'];
    Mask_nii = load_untouch_nii(Mask_fn);
    Mask = single(Mask_nii.img);
    R2s_fn = [input_dir, dataset{1}, '_R2s_Padded.nii.gz'];
    R2s_nii = load_untouch_nii(R2s_fn);
    R2s = single(R2s_nii.img);
    e_vox = 2;
    Mask = imerode(Mask, strel('sphere', e_vox));
    matrix_size = size(Mask);
    if contains(dataset{1}, '3T')
        voxel_size = [1 1 1];
    elseif contains(dataset{1}, '7T')
        voxel_size = [.75 .75 .75];
    end
    radius = 4;    
    Mask = single(SMV(Mask, matrix_size, voxel_size, radius)>0.999);
    [ CSF_Mask ] = extract_CSF(R2s, Mask, voxel_size);
    % [CSF_Mask] = CSFmaskThresh(R2s, 5, Mask, voxel_size);
    CSF_Mask_fn = [output_dir, dataset{1}, '_CSF_Mask'];
    export_nii(CSF_Mask, CSF_Mask_fn, voxel_size);
    % Morphological erosion    
    erode_radius_voxel   = min(round(1 ./ voxel_size)); % 2 mm
    CSF_Mask = imerode(CSF_Mask, strel('sphere', double(erode_radius_voxel)));
    CSF_Mask_fn = [output_dir, dataset{1}, '_CSF_Mask_Erode'];
    export_nii(CSF_Mask, CSF_Mask_fn, voxel_size);
    % Morphological opening
    open_radius_voxel   = min(round(2 ./ voxel_size)); % 2 mm
    CSF_Mask = imopen(CSF_Mask, strel('sphere', double(open_radius_voxel)));
    CSF_Mask_fn = [output_dir, dataset{1}, '_CSF_Mask_Erode_Open'];
    export_nii(CSF_Mask, CSF_Mask_fn, voxel_size);    
    % Use SEPIA function to get largest object
    CSF_Mask = getLargestObject(CSF_Mask, 6);    
    CSF_Mask_fn = [output_dir, dataset{1}, '_CSF_Mask_Erode_Open_getLargestObject'];
    export_nii(CSF_Mask, CSF_Mask_fn, voxel_size);        
end
