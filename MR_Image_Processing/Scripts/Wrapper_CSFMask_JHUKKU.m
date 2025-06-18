%% CSFMask_JHUKKU.m

i = {'3T_Neutral', '3T_Rot4'};

hdr.R2s_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\R2s\';

for dataset = i

    NLLS_fn = fullfile(hdr.R2s_dir, strcat(dataset{1}, '_forNLLS.mat'));
    load(NLLS_fn, "BETMask");
    R2s_fn = fullfile(hdr.R2s_dir, strcat(dataset{1}, '_R2s.mat'));
    load(R2s_fn, "r2s");
    thresh = 5; %s^-1
    if contains(dataset, "3T")
        voxel_size = [1 1 1];
    elseif contains(dataset, "7T")
        voxel_size = [.7 .7 .7];
    end
    
    [ CSFmask] = CSFmaskThresh(r2s, thresh, BETMask, voxel_size);
    CSFmask    = double(CSFmask);
    CSFmask_fn = fullfile(hdr.R2s_dir, strcat(dataset{1}, '_CSF_Mask.nii.gz'));
    export_nii(CSFmask, CSFmask_fn);
    mosaic( CSFmask, 12, 12, 22, '"CSF\_Mask": JHUKKU Toolbox' )

end