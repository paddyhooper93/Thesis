%% MultiOrientROIs.m

for FS_str = {'7T'}

if matches(FS_str, '3T')
    Registered = {'Rot1', 'Rot2', 'Rot3', 'Rot5', 'Rot6'}; 
    vsz = [1 1 1];
elseif matches(FS_str, '7T')
    Registered = {'Rot1', 'Rot2', 'Rot3', 'Rot4', 'Rot5'};
    vsz = [.75 .75 .75];
end

dir = 'C:\Users\rosly\Documents\Valerie_PH\ROIs';
rois_load_fn = fullfile(dir, [FS_str{1}, '_ROIs_Old.nii.gz']);
rois_load_nii = load_untouch_nii(rois_load_fn);
rois_load = single(rois_load_nii.img);
M_fn = fullfile(dir, [FS_str{1}, '_Neutral_Mask_Use_FLIRT.nii.gz']);
M_nii = load_untouch_nii(M_fn);
rois_old = pad_or_crop_target_size(M_nii.img, vsz) .* rois_load;


tmp = ones(size(rois_old));
for i = Registered
    M_fn = fullfile(dir, [FS_str{1}, '_Neutral_to_', i{1}, '_Mask_Use.nii.gz']);
    M_nii = load_untouch_nii(M_fn);
    tmp = M_nii.img .* tmp;
end

rois_new = tmp .* rois_old;

rois_export_fn = fullfile(dir, [FS_str{1}, '_ROIs_Use.nii.gz']);
export_nii(single(rois_new), rois_export_fn, vsz);

end