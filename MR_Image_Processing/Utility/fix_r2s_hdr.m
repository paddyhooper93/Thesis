in_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\SDC';
cd(in_dir);

for dataset = {'3T_Neutral', '3T_Rot1', '3T_Rot2', '3T_Rot3', '3T_Rot5', '3T_Rot6'}
vsz=[1 1 1];
fn=[dataset{1}, '_R2s.nii.gz'];
nii = load_untouch_nii(fn);
img = pad_or_crop_target_size(nii.img,vsz);
out_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\R2s';
fn=fullfile(out_dir, [dataset{1}, '_R2s.nii.gz']);
export_nii(img, fn, vsz);
end
cd(out_dir);
