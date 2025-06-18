function [R_tot] = Get_Rotation_Matrices(FS_str)

matrix_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\FLIRT\';

if matches(FS_str, '3T')
    Ref_str = 'Rot5';
    Unreg_str = {'Rot1', 'Rot3', 'Neutral', 'Rot2', 'Rot4', 'Rot6'};
elseif matches(FS_str, '7T')
    Ref_str = 'Rot1';
    Unreg_str = {'Rot3', 'Rot5', 'Neutral', 'Rot2', 'Rot4', 'Rot6'};
end

% Mask_fn = [reference_dir, FS_str, '_', Ref_str, '_Mask_Use.nii.gz'];
% Mask_nii = load_untouch_nii(Mask_fn);
% Mask_Use = Mask_nii.img;
% weights_fn = fullfile(reference_dir, [FS_str, '_', Ref_str, '_weights.nii.gz']);
% weights_nii = load_untouch_nii(weights_fn);
% weights = weights_nii.img;

% deltaB_fn = fullfile(reference_dir, [FS_str, '_', Ref_str, '_Delta.nii.gz']);
% deltaB_nii = load_untouch_nii(deltaB_fn);
% deltaB = deltaB_nii.img;
R_tot = eye(3);

for i = Unreg_str
    % deltaB_fn = fullfile(flirt_dir, [FS_str, '_', Ref_str, '_to_', i{1}, '_Delta_FLIRT.nii.gz']);
    % deltaB_nii = load_untouch_nii(deltaB_fn);
    % deltaB_img = deltaB_nii.img;
    % deltaB = cat(4, deltaB, deltaB_img);
    matrix_fn = fullfile(matrix_dir, [FS_str, '_', Ref_str, '_to_', i{1}, '_ITK.mat']);
    load(matrix_fn, "MatrixOffsetTransformBase_double_3_3");
    matrix = reshape(MatrixOffsetTransformBase_double_3_3(1:9), [3,3])';
    R_tot = single(cat(3, R_tot, matrix));
end

% savefile = fullfile(output_dir, [FS_str, '_COSMOS_inputVars.mat']);
% save(savefile, "Mask_Use", "weights", "deltaB", "R_tot");

end