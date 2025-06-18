function NII_to_MAT_for_R2s(dataset, input_dir, output_dir)
%i = {'7T_Rot4'};
% i = {'7T_Neutral', '7T_Rot1', '7T_Rot2', '7T_Rot3', '7T_Rot4', '7T_Rot5', ...
%      '3T_Neutral', '3T_Rot1', '3T_Rot2', '3T_Rot3', '3T_Rot4', '3T_Rot5', '3T_Rot6' };

%dr.SDC_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\SDC\';
%hdr.R2s_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\R2s\';
%hdr.Mask_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Mask_Use\';

%for dataset = i

Magn_fn = fullfile(input_dir, strcat(dataset, '_Magn_Padded.nii.gz'));
Magn_nii = load_untouch_nii(Magn_fn);
Magn = double(Magn_nii.img);
Mask_fn = fullfile(input_dir, strcat(dataset, '_mask.nii.gz'));
Mask_nii = load_untouch_nii(Mask_fn);
Mask_Use = double(Mask_nii.img);
savefile = fullfile(output_dir, strcat(dataset, '_forNLLS.mat'));
n_TE                = 7;
TE                  = (3:3:n_TE*3)./1000;
save(savefile, "Magn", "Mask_Use", "TE");

%end