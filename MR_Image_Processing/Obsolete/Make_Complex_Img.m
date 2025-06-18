function Make_Complex_Img(dataset)

NC_path = 'C:\Users\rosly\Documents\Valerie_PH\Data\NC\';
magn = load_untouch_nii([NC_path, dataset, '_Magn.nii.gz']);
phs = load_untouch_nii([NC_path, dataset, '_Phs_MCPC.nii.gz']);
mask = load_untouch_nii([NC_path, dataset, '_Mask_Use.nii.gz']);
Cplx=((magn.img).*(cos(phs.img)+1i*(sin(phs.img)))) .* (mask.img > 0);
if contains(dataset, '3T')
    v_size = [1 1 1];
elseif contains(dataset, '7T')
    v_size = [.75 .75 .75];
end
export_nii(single(Cplx), [NC_path, dataset, '_Cplx'], v_size);