function NIfTI_to_MAT_degibbs(dataset)



magn_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\degibbs3D\';
phs_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\NC\';
mask_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Masking\';
output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\degibbs3D';
r2s_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\R2s\';

% if 2==exist([dataset, '_forQSM.mat'], 'file')
%     return
% end

% if contains(dataset, '7T')
%     v_size = [.75 .75 .75];
% elseif contains(dataset, '3T')
%     v_size = [1 1 1];
% end

eval(['cd', 32, output_dir]);

    Magn_fn = fullfile( magn_dir, [dataset, '_Magn_Degibbs3D.nii.gz'] );
    Template_nii = load_untouch_nii(Magn_fn);
    Magn = pad_or_crop(double(Template_nii.img), dataset);

    Phs_fn = fullfile( phs_dir, [dataset, '_Phs_MCPC.nii.gz'] );
    Phs_nii = load_untouch_nii(Phs_fn);
    Phs = pad_or_crop(double(Phs_nii.img), dataset);

    Mask_fn = fullfile( mask_dir, [dataset, '_mask.nii.gz'] );
    Mask_nii = load_untouch_nii(Mask_fn);
    Mask_Use = pad_or_crop(double(Mask_nii.img), dataset);

    R2s_fn = fullfile( r2s_dir, [dataset, '_R2s.nii.gz'] );
    R2s_nii = load_untouch_nii(R2s_fn);
    R2s = pad_or_crop(double(R2s_nii.img), dataset);

    savefile = fullfile( output_dir, [dataset, '_forQSM.mat'] );
    save(savefile, "Magn", "Phs", "Mask_Use", "R2s");  

end

