%% Gaussian Filter Test

input_dir='C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\PDF_deGibbs';
output_dir='C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\PDF_deGibbs_Gaussian';
SD = 1.2/2.355; % FHWM = 1.2 voxels (SD = FWHM/2.355) 

for i = {'Rot1', 'Rot2', 'Rot3', 'Rot5', 'Rot6'}
    in_fn = fullfile(input_dir,['3T_Neutral_to_',i{1},'_Delta_FLIRT.nii.gz']);
    img_nii=load_untouch_nii(in_fn);
    img = single(img_nii.img);
    img_out=smooth3(img,'gaussian',3,SD);
    out_fn = fullfile(output_dir,['3T_Neutral_to_',i{1},'_Delta_FLIRT_Gaussian']);
    export_nii(img_out,out_fn);
end