%% function preprocessing(dataset, dir_in, dir_sdc, dir_r2s)
dir_in = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\';
dir_mask = dir_in;
dir_sdc = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\SDC\';
dir_r2s = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\R2s\';

for dataset = {'7T_Rot6'}

%% SDC
hdr.path_to_data = dir_in;
hdr.output_dir = dir_sdc;
hdr.isInvert = false;
Wrapper_FermiFilt_SDC(  hdr, dataset{1} );

% R2star mapping w/ parallel computing

InitiateParallelComputing();
% %
% %
magn_nii = load_untouch_nii(fullfile(dir_sdc, [dataset{1}, '_Magn.nii.gz']));
mask_nii = load_untouch_nii(fullfile(dir_mask, [dataset{1}, '_Mask_Use.nii.gz']));
magn = single(magn_nii.img);
mask = single(mask_nii.img);
if contains(dataset,'3T')
    voxel_size = [1 1 1];
else
    voxel_size = [.75 .75 .75];
end
TE=(3:3:21)./1000;
NUM_MAGN = length(TE);
isParallel = 0;
[R2s, ~, ~] = R2star_NLLS(magn, TE, mask, isParallel, NUM_MAGN);
R2s = R2s .* mask;
export_nii(R2s, fullfile(dir_r2s, [dataset{1}, '_R2s.nii.gz']), voxel_size);

end