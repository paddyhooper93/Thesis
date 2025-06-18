function ZeroPad_N4_ITK(dataset)

magn_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\N4-ITK';
mask_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Masking';
output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\N4-ITK';

if contains(dataset, '7T')
    v_size = [.75 .75 .75];
elseif contains(dataset, '3T')
    v_size = [1 1 1];
end

if 7~=exist(output_dir, 'dir')
    eval(['mkdir', 32, output_dir]);
end

eval(['cd', 32, output_dir]);

Magn_fn = fullfile( magn_dir, [dataset, '_Magn_N4.nii.gz'] );
Magn_nii = load_untouch_nii(Magn_fn);
Magn = pad_or_crop(double(Magn_nii.img), dataset);
Magn_save_fn = fullfile( output_dir, [dataset, '_Magn_N4_Padded.nii.gz']);
export_nii(Magn, Magn_save_fn, v_size);

Mask_fn = fullfile( mask_dir, [dataset, '_mask.nii.gz'] );
Mask_nii = load_untouch_nii(Mask_fn);
Mask_Use = pad_or_crop(double(Mask_nii.img), dataset);
Mask_save_fn = fullfile( output_dir, [dataset, '_Mask_Padded.nii.gz']);
export_nii(Mask_Use, Mask_save_fn, v_size);    