function apply_MCPC(dataset)

hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\NC\';
hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\NC\';
hdr.TE=(3:3:21) ./ 1000;
Mask_fn = fullfile(hdr.path_to_data, [dataset, '_Mask_Use.nii.gz']);
Mask_nii = load_untouch_nii(Mask_fn);
hdr.Mask_Use = single(Mask_nii.img);
Magn_fn = fullfile(hdr.path_to_data, [dataset, '_Magn.nii.gz']);
Magn_nii = load_untouch_nii(Magn_fn);
hdr.voxel_size = Magn_nii.hdr.dime.pixdim(2:4);
hdr.Magn = single(Magn_nii.img) .* hdr.Mask_Use;
Phs_fn = fullfile(hdr.path_to_data, [dataset, '_Phs.nii.gz']);
Phs_nii = load_untouch_nii(Phs_fn);
hdr.Phs = single(Phs_nii.img) .* hdr.Mask_Use;
[corrected_phase] = PhaseOffsetCorrection_MCPC(hdr);
Phs_fn_save = fullfile(hdr.output_dir, [dataset, '_Phs_MCPC.nii.gz']);
export_nii(corrected_phase, Phs_fn_save, hdr.voxel_size)