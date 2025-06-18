function [QSM] = CombineQSMVols_3T(dir_MEDI)

fn1 = '3T_Neutral';
fn2 = 'QSM_Default_FLIRT.nii.gz';
fn = fullfile(dir_MEDI, [fn1, '_', fn2]);
nii = load_untouch_nii(fn);
QSM = nii.img;

for dataset = {'3T_Rot1', '3T_Rot2', '3T_Rot3', '3T_Rot5', '3T_Rot6'}
    fn = fullfile(dir_MEDI, [fn1, '_to_', dataset{1}(4:7), '_', fn2]);
    nii = load_untouch_nii(fn);
    QSM = cat(4, QSM, nii.img);
end

%output_fn = fullfile(dir_MEDI, '3T_chi_MEDI_6_Orient_30pc');
%export_nii(QSM, output_fn);