function Wrapper_R2starNLLS(dataset, input_dir, output_dir)

InitiateParallelComputing();
isParallel = 0;
% dir='C:\Users\rosly\Documents\Valerie_PH\Data\MatrixSizeCorrect\';

% for dataset = {'3T_Rot1', '3T_Rot3', '3T_Rot5', '7T_Rot1', '7T_Rot3', '7T_Rot5'}
if contains(dataset, '3T')
    vsz=[1 1 1];
elseif contains(dataset,'7T')
    vsz=[.75 .75 .75];
end
Magn_fn = fullfile( input_dir, [dataset,'_Magn.nii.gz'] );
Mask_fn = fullfile( input_dir, [dataset,'_mask.nii.gz'] );
Magn = load_untouch_nii(Magn_fn);
Mask_Use = load_untouch_nii(Mask_fn);
Magn = single(Magn.img);
Mask_Use = single(Mask_Use.img);
TE=(3:3:21)./1000;
% oddIdx = 1:2:length(TE);
% TE = TE(oddIdx);
% Magn = Magn(:, :, :, oddIdx);
NUM_MAGN = length(TE);
% **NB** Altered line 104 of R2star_NLLS.m as follows:
% options = optimoptions('lsqnonlin', 'Algorithm','levenberg-marquardt');
[R2s, ~, M0] = R2star_NLLS(Magn, TE, Mask_Use, isParallel, NUM_MAGN);
R2s = R2s .* Mask_Use;
M0 = M0 .* Mask_Use;
export_nii(R2s, fullfile( output_dir, [dataset, '_R2s'] ), vsz);
export_nii(M0, fullfile( output_dir, [dataset, '_M0'] ), vsz);
% save(savefile, 'R2s', 'M0');
% end