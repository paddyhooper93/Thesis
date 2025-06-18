function SDCMAT_for_QSM()
i = {'7T_Rot1', '7T_Rot2', '7T_Rot3', '7T_Rot4', '7T_Rot5', ...
     '3T_Rot1', '3T_Rot2', '3T_Rot3', '3T_Rot4', '3T_Rot5', '3T_Rot6' };
% i = {'3T_Neutral', '7T_Neutral'};

hdr.SDC_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\SDC\';
hdr.R2s_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\R2s\';
hdr.Mask_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Mask_Use\';

for dataset = i

    Mask_fn = fullfile(hdr.Mask_dir, strcat(dataset{1}, '_Mask_Use.nii.gz'));
    Mask_nii = load_untouch_nii(Mask_fn);
    Mask_Use = double(Mask_nii.img);
    Phs_fn = fullfile(hdr.SDC_dir, strcat(dataset{1}, '_Phs_SDC.nii.gz'));
    Phs_nii = load_untouch_nii(Phs_fn);
    Phs = double(Phs_nii.img) .* Mask_Use;
    Magn_fn = fullfile(hdr.SDC_dir, strcat(dataset{1}, '_Magn_SDC.nii.gz'));
    Magn_nii = load_untouch_nii(Magn_fn);
    Magn = double(Magn_nii.img) .* Mask_Use;
    R2s_fn = fullfile(hdr.R2s_dir, strcat(dataset{1}, '_R2s.nii.gz'));
    R2s_nii = load_untouch_nii(R2s_fn);
    R2s = double(R2s_nii.img)  .* Mask_Use;

    savefile = fullfile(hdr.SDC_dir, strcat(dataset{1}, '_SDC.mat'));
    save(savefile, "Phs", "Magn", "Mask_Use", "R2s");
    
end