function NIfTI_to_MAT_COSMOS(dataset)

magn_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\FermiFilt_SDC\';
phs_dir = magn_dir;
mask_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Masking\';
r2s_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\R2s\';
output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\FermiFilt_SDC\';

% if 2==exist([dataset, '_forQSM.mat'], 'file')
%     return
% end

if contains(dataset, '7T')
    v_size = [.75 .75 .75];
elseif contains(dataset, '3T')
    v_size = [1 1 1];
end

eval(['cd', 32, output_dir]);

    Magn_fn = fullfile( magn_dir, [dataset, '_Magn_SDC.nii.gz'] );
    Template_nii = load_untouch_nii(Magn_fn);
    Magn = pad_or_crop(double(Template_nii.img), dataset);
    Magn_save_fn = fullfile( output_dir, [dataset, '_Magn_Padded.nii.gz']);
    export_nii(Magn, Magn_save_fn, v_size);

    Phs_fn = fullfile( phs_dir, [dataset, '_Phs_SDC.nii.gz'] );
    Phs_nii = load_untouch_nii(Phs_fn);
    Phs = pad_or_crop(double(Phs_nii.img), dataset);
    Phs_save_fn = fullfile( output_dir, [dataset, '_Phs_Padded.nii.gz']);
    export_nii(Phs, Phs_save_fn, v_size);

    Mask_fn = fullfile( output_dir, [dataset, '_mask.nii.gz'] );
    Mask_nii = load_untouch_nii(Mask_fn);
    Mask_Use = pad_or_crop(double(Mask_nii.img), dataset);
    % Mask_save_fn = fullfile( output_dir, [dataset, '_Mask_Padded.nii.gz']);
    % export_nii(Mask_Use, Mask_save_fn, v_size);    

    R2s_fn = fullfile( r2s_dir, [dataset, '_R2s.nii.gz'] );
    R2s_nii = load_untouch_nii(R2s_fn);
    R2s = pad_or_crop(double(R2s_nii.img), dataset);
    % R2s_save_fn = fullfile( output_dir, [dataset, '_R2s_Padded.nii.gz'] );
    % export_nii(R2s, R2s_save_fn, v_size);

    savefile = fullfile( output_dir, [dataset, '_forQSM.mat'] );
    save(savefile, "Magn", "Phs", "Mask_Use", "R2s");  

end

