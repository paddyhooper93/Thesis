

dir='C:\Users\rosly\Documents\Valerie_PH\Data\Padded\N4_deGibbs';

iMag = struct();
for dataset = {'3T_Neutral', '3T_Rot1', '3T_Rot2', '3T_Rot3', '3T_Rot5', '3T_Rot6', '7T_Rot1', '7T_Rot2', '7T_Rot3', '7T_Rot4', '7T_Rot5', '7T_Rot6'}
    if contains(dataset{1},'7T')
        TEf_idx=4;
    else
        TEf_idx=7;
    end
    fn = fullfile(dir,[dataset{1}, '_Magn.nii.gz']);
    nii = load_untouch_nii(fn);
    Magn = single(nii.img);
    Magn = Magn(:,:,:,1:TEf_idx);
    Magn = sqrt(sum(abs(Magn).^2,4));
    iMag.([sprintf('%s', num2str(dataset{1}(4:end))), '_', sprintf('%s', dataset{1}(1:2))]) = Magn;
end

save(fullfile(dir, 'iMag.mat'), "iMag")