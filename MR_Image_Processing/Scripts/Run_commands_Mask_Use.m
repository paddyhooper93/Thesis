function Run_commands_Mask_Use
clearvars
close all
hdr = struct();
hdr.path_to_data = 'C:\Users\rosly\Documents\QSM_PH\Data\Quad-AfterCplx\';
hdr.output_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\VSH8_SEPIA\rgst_SMV\';
hdr.write_dir = fullfile(hdr.output_dir, 'after_CorrectNaCl\');
if 7~=exist(hdr.output_dir, 'dir')
    eval(strcat('mkdir', 32, hdr.output_dir));
end
hdr.saveMaskUse = true;
% Done = '7T_BL', '7T_BL_Rep', '7T_9mth', '7T_24mth', '7T_24mth_Rep', ...
       % '3T_BL', '3T_9mth', '3T_24mth', '3T_24mth_Rep', 
i   = {'3T_BL_Rep'};
for dataset = i
    [hdr] = InitializeParams(dataset{1}, hdr);
    [hdr] = Wrapper_MaskUse(hdr);
    erode_radius = 4;
    SE = strel('sphere', erode_radius);
    QSM_Mask = imerode(hdr.Mask_Use, SE);
    mosaic( QSM_Mask, 12, 12, 16, 'QSM\_Mask')
    QSM_load_fn = strcat(hdr.output_dir, dataset{1}, '_QSM_Quad.nii.gz');
    QSM_nii = load_untouch_nii(QSM_load_fn);
    QSM_cor = QSM_Mask.*(QSM_nii.img - 0.1106);
    QSM_write_fn = strcat(hdr.write_dir, dataset{1}, '_QSM_Quad');
    export_nii(QSM_cor, QSM_write_fn);
    fprintf('Processed Dataset %s \n', dataset{1});
end