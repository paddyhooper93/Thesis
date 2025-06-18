function Wrapper_resample_volumes(dataset, dir, new_vsz)


% Load data and intialize params

magn_fn = [dir, dataset, '_Magn_SDC_068.nii.gz'];
phs_fn = [dir, dataset, '_Phs_SDC_068.nii.gz'];
mask_fn = [dir, dataset, '_Mask_Use_068.nii.gz'];
magn_nii = load_untouch_nii(magn_fn);
phs_nii = load_untouch_nii(phs_fn);
mask_nii = load_untouch_nii(mask_fn);
old_vsz = phs_nii.hdr.dime.pixdim(2:4);
Mask = single(mask_nii.img);
Magn = single(magn_nii.img);
Phs = single(phs_nii.img);
clear magn_nii phs_nii
% Convert to complex space
Cplx = Magn.*exp(1i*Phs); 
clear Magn Phs
% Complex linear interpolation
Real_resampled = resample_volumes(real(Cplx), old_vsz, new_vsz);
Imag_resampled = resample_volumes(imag(Cplx), old_vsz, new_vsz);
Mask_resampled = resample_volumes(Mask, old_vsz, new_vsz);
clear Cplx
Magn_resampled = single(sqrt(Real_resampled.^2 + Imag_resampled.^2));
Phs_resampled = single(atan2(Imag_resampled, Real_resampled));
Magn_resampled = zeropad_odd_dimension(Magn_resampled, 'pre', size(Magn_resampled));
Phs_resampled = zeropad_odd_dimension(Phs_resampled, 'pre', size(Phs_resampled));
Mask_resampled = zeropad_odd_dimension(Mask_resampled, 'pre', size(Mask_resampled));
clear Real_resampled Imag_resampled

Magn_padded = padarray(Magn_resampled, [22 37 0], 0, 'both');
Phs_padded = padarray(Phs_resampled, [22 37 0], 0, 'both');
Mask_padded = padarray(Mask_resampled, [22 37 0], 0, 'both');

export_nii(Magn_padded, [dir, dataset, '_Magn_SDC'], new_vsz);
export_nii(Phs_padded, [dir, dataset, '_Phs_SDC'], new_vsz);
export_nii(Mask_padded, [dir, dataset, '_Mask_Use'], new_vsz);


% export_nii(Magn_resampled, [dir, dataset, '_Magn_SDC'], new_vsz);
% export_nii(Phs_resampled, [dir, dataset, '_Phs_SDC'], new_vsz);
% export_nii(Mask_resampled, [dir, dataset, '_Mask_Use'], new_vsz);

% Magn_padded = pad_neutral_7T(Magn_resampled);
% Phs_padded = pad_neutral_7T(Phs_resampled);
% Mask_padded = pad_neutral_7T(Mask_resampled);

% old_matrix_size = [264 352 208]; % vsz = 0.68
% new_matrix_size = [239 319 189]; % vsz = 0.75
% or [240 320 190] after correcting for
% odd dimension
%
%
% Target_matrix_size_vsz0-68 = [309 353 282];
% Target_matrix_size_vsz0-75 = [280 320 256];
% Zero-Padding: x=20 (both), y=1 (start), z=67 (end)

% function padded_image = pad_neutral_7T(resampled_image)
% 
% matrixSize_o = size(resampled_image);
% padded_image = zeropad_odd_dimension(resampled_image, 'pre', matrixSize_o);
% 
% % padsize_x = [20 0 0]; % 'both' (40 in total)
% % % padsize_y = [0 1 0]; % 'pre'
% % padsize_z = [0 0 66]; % 'post'
% 
% padsize_x_both = [22 0 0]; % 'both' (44 in total)
% % padsize_z_post = [0 0 60]; % 'post'
% % padsize_z_pre = [0 0 14];
% padsize_z_both = [0 37 0]; 
% 
% padded_image = padarray(padded_image, padsize_x_both, 0, 'both');
% % padded_image = padarray(padded_image, padsize_z_post, 0, 'post');
% % padded_image = padarray(padded_image, padsize_z_pre, 0, 'pre');
% 
% end