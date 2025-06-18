function MAT_to_NIfTI()
dir='C:\Users\rosly\Documents\Valerie_PH\Data\R2s\';
eval('cd ',dir)
for dataset = {'3T_Rot1', '3T_Rot3', '3T_Rot5', '7T_Rot1', '7T_Rot3', '7T_Rot5'}
r2s_fn=[ dataset{1}, '_R2s'];
m0_fn=[ dataset{1}, '_M0'];
load(r2s_fn, "M0", "R2s");
export_nii(M0, m0_fn);
export_nii(R2s, r2s_fn);
end