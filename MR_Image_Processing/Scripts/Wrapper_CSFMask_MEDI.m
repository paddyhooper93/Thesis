%% CSFMask_MEDI.m

i = {'3T_Neutral', '3T_Rot4'};

hdr = struct();
hdr.R2s_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\R2s\';

if ~isfield(hdr, 'thresh_R2s')
    hdr.thresh_R2s = 5; %s^-1
end

if ~isfield(hdr, 'flag_erode')
    hdr.flag_erode = 0; % Boolean
end

if ~hdr.flag_erode
    suffix = '';
else
    suffix = 'Eroded';
end

for dataset = i
    
    if contains(dataset, "3T")
        voxel_size = [1 1 1];
    elseif contains(dataset, "7T")
        voxel_size = [.7 .7 .7];
    end

    NLLS_fn = fullfile(hdr.R2s_dir, strcat(dataset{1}, '_forNLLS.mat'));
    load(NLLS_fn, "BETMask");
    R2s_fn = fullfile(hdr.R2s_dir, strcat(dataset{1}, '_R2s.mat'));
    load(R2s_fn, "r2s");
    
    CSFmask = extract_CSF(r2s, BETMask, voxel_size, hdr.flag_erode, hdr.thresh_R2s);
    CSFmask    = double(CSFmask);
    
    CSFmask_fn = fullfile(hdr.R2s_dir, strcat(dataset{1}, '_CSF_Mask', suffix, '.nii.gz'));
    export_nii(CSFmask, CSFmask_fn);
    mosaic( CSFmask, 12, 12, 22, strcat('"CSF\_Mask"', suffix, ': MEDI Toolbox' ));
    
end