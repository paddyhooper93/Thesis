

sti_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\COSMOS_SNRwAVG_PDF\STI';
num_orient_STI = 6;

for FS_str = {'3T', '7T'}


    input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\COSMOS_SNRwAVG_PDF\Num_Orient_6';
    matfile = fullfile(input_dir, [FS_str{1}, '_COSMOS_6_inputVars.mat'] );
    load(matfile, "M", "voxel_size");
    FOV = [400 400 400] .* min(voxel_size); % 400 400 400 at 3 T, and 300 300 300 at 7 T
    M = pad_or_crop_target_size(M, voxel_size, FOV);

    STI_res_fn = fullfile(sti_dir, [FS_str{1}, '_chi_res_STI6_Orient.nii.gz']);
    STI_res_nii = load_untouch_nii(STI_res_fn);
    STI_res = pad_or_crop_target_size(STI_res_nii.img, voxel_size, FOV);    

    [chi_STI] = get_scalar_STI_from_tensor(STI_res, M, voxel_size);

    chi_STI = (chi_STI + -0.1106) .* M;
    chi_STI = pad_or_crop_target_size(chi_STI, voxel_size);

    export_nii(chi_STI, fullfile(sti_dir, [FS_str{1}, '_chi_STI', num2str(num_orient_STI), '_Orient']), voxel_size);

end