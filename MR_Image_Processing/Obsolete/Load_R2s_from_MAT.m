%% Load_R2s_from_MAT

clc
clear
close all

i = {'7T_Rot4'};

hdr = struct();
hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\R2s\';

for dataset = i
    
    R2s_fn = strcat(hdr.output_dir, dataset{1}, '_R2s');
    load(strcat(R2s_fn, '.mat'), 'r2s');
    Mask_fn = strcat(hdr.output_dir, dataset{1}, '_forNLLS');
    load(strcat(Mask_fn, '.mat'), 'Mask_Use');
    for i=size(r2s, 3) :-1 :1
        Mask_Use(:, :, i) = imfill(Mask_Use(:, :, i), 'holes');
    end

    if contains(dataset, "3T")
        voxel_size = [1 1 1];
    elseif contains(dataset, "7T")
        voxel_size = [.7 .7 .7];
    end

    export_nii(r2s, R2s_fn);
    export_nii(Mask_Use, Mask_fn);
    
end