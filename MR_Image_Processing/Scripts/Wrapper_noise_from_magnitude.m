%%Wrapper_noise_from_magnitude

i = {'3T_Rot3', '3T_Rot5', '3T_Rot6', '7T_Rot4', '7T_Rot5'};
for dataset = i
    if contains(dataset{1}, '3T')
        thresh=10;
    else
        thresh=20;
    end
    open_radius=4;
    magn_e1=load_untouch_nii([dataset{1}, '_Magn_E1.nii.gz']);
    magn_e1=single(magn_e1.img);
    [mask] = noise_from_magnitude(magn_e1, thresh, open_radius);
    export_nii(mask,[dataset{1}, '_mask_air_thresh', num2str(thresh), '_open', num2str(open_radius)]);
end