function Wrapper_ZeroPadVolumes(dataset, input_dir, output_dir)

mask_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Masking\';
% R2s_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\R2s\';

if 7~=exist(output_dir, 'dir')
    eval(strcat('mkdir', 32, output_dir));
end


%% Load data and intialize params

magn_fn = [input_dir, dataset, '_Magn_SDC.nii.gz'];
phs_fn = [input_dir, dataset, '_Phs_SDC.nii.gz'];
mask_fn = [mask_dir, dataset, '_mask.nii.gz'];
Magn_nii = load_untouch_nii(magn_fn);
Phs_nii = load_untouch_nii(phs_fn);
Mask_nii = load_untouch_nii(mask_fn);
% R2s_fn = [R2s_dir, dataset, '_R2s.mat'];
% load(R2s_fn, "R2s");
%% Zero-padding / Cropping

if contains(dataset, '3T')
    voxel_size = [1 1 1];
elseif contains(dataset, '7T')
    voxel_size = [.75 .75 .75];
end

matrixSize_o = size(Mask_nii.img);

Mask = zeropad_odd_dimension(single(Mask_nii.img),'pre',matrixSize_o);
Magn = zeropad_odd_dimension(single(Magn_nii.img),'pre',matrixSize_o);
Phs = zeropad_odd_dimension(single(Phs_nii.img),'pre',matrixSize_o);
% R2s = zeropad_odd_dimension(single(R2s),'pre',matrixSize_o);
Mask = pad_or_crop_target_size(Mask, voxel_size);
Magn = pad_or_crop_target_size(Magn, voxel_size);
Phs = pad_or_crop_target_size(Phs, voxel_size);
% R2s = pad_or_crop_target_size(R2s, voxel_size);

% Verify the matrix size
% assert(isequal(actual_matrix_size, target_matrix_size), ...
%     sprintf('Matrix size is incorrect. Expected: [%d, %d, %d, %d], Got: %s', ...
%     target_matrix_size, actual_matrix_size));
% disp('Matrix size is correct.');


%% Exporting
Magn_fn = [output_dir, dataset, '_Magn_Padded'];
export_nii(single(Magn), Magn_fn, voxel_size);
Phs_fn = [output_dir, dataset, '_Phs_Padded'];
export_nii(single(Phs), Phs_fn, voxel_size);
Mask_fn = [output_dir, dataset, '_mask'];
export_nii(single(Mask), Mask_fn, voxel_size);
% R2s_fn = [output_dir, dataset, 'R2s_Padded'];
% export_nii(single(R2s), R2s_fn, voxel_size);

end
