%% CSFMask_MEDI.m

clc
clear
close all

% Done =  '3T_Rot4', '3T_Neutral', '7T_Rot2', '7T_Rot3', ...
% '7T_Neutral', '7T_Rot1', '7T_Rot4'

% i = {'3T_Neutral', '7T_Rot1', '7T_Rot2', '7T_Rot3', '7T_Rot4', '7T_Rot5', ...
%      '7T_Neutral', '3T_Rot1', '3T_Rot2', '3T_Rot3', '3T_Rot4', '3T_Rot5', '3T_Rot6' };

i = {'7T_Neutral'};

hdr = struct();
hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\R2s\';
hdr.Mask_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Mask_Use\';

% if ~isfield(hdr, 'saveErodedComplementMask')
%     hdr.saveErodedComplementMask = 1;
% end
% 
% if ~isfield(hdr, 'saveComplementMask')
%     hdr.saveComplementMask = 0;
% end

if ~isfield(hdr, 'thresh')
    hdr.thresh = 5; % s^-1
    fprintf('R2s threshold: %s \n', num2str(hdr.thresh));
end

if ~isfield(hdr, 'CSF_Method')
    hdr.CSF_Method = 'JHUKKU';
    fprintf('CSF Mask method: %s \n', hdr.CSF_Method)
end

if ~isfield(hdr, 'flag_erode')
    hdr.flag_erode = 0;
end

if hdr.flag_erode
    hdr.erodeRadius = 2; % mm
    fprintf('Erosion : %s mm \n', num2str(hdr.erodeRadius))    
end

if ~isfield(hdr, 'refine_using_r2s')
    hdr.refine_using_r2s = 0;
end

if hdr.refine_using_r2s
    disp('Refining CSF mask with R2s');
end

for dataset = i
    
    if contains(dataset, "3T")
        voxel_size = [1 1 1];
    elseif contains(dataset, "7T")
        voxel_size = [.7 .7 .7];
    end

    Mask_fn = fullfile(hdr.Mask_dir, strcat(dataset{1}, '_Mask_Use.nii.gz'));
    Mask_nii = load_untouch_nii(Mask_fn);
    Mask_Use = double(Mask_nii.img);
    Mask_Use(isinf(Mask_Use)) = 0;
    R2s_fn = fullfile(hdr.output_dir, strcat(dataset{1}, '_R2s'));
    load(strcat(R2s_fn, '.mat'), "r2s", "m0");

    if matches(hdr.CSF_Method, 'MEDI')
        CSFMask = extract_CSF(r2s, Mask_Use, voxel_size, 1, hdr.thresh);
    elseif matches(hdr.CSF_Method, 'JHUKKU')
        r2s(m0 < 3000) = 10;
        CSFMask = CSFmaskThresh(r2s, hdr.thresh, Mask_Use, voxel_size);
        CSFMask = getLargestObject(CSFMask, 6);
    elseif matches(hdr.CSF_Method, 'SimpleThresholding')
        CSFMask = (r2s < hdr.thresh) .* Mask_Use;
    end

    CSFMask = double(CSFMask);
    CSFMask(:) = CSFMask(:) .* Mask_Use(:);   
    CSFMask(isinf(CSFMask)) = 0;
    
    mosaic( CSFMask, 12, 12, 1, strcat('CSF mask after', hdr.CSF_Method));

    if hdr.refine_using_r2s

    % excluding minimum from statistic
    min_r2s = min(r2s(CSFMask>0));

    % compute stats
    iqr_r2s     = iqr(r2s(and( CSFMask>0, r2s>min_r2s )));
    median_r2s  = median(r2s(and( CSFMask>0, r2s>min_r2s )));

    % assume everthing outside 3*IQR from median to be outliers
    mask_r2s = r2s <= (median_r2s + 3*iqr_r2s) .* CSFMask;

    % basic morphology operation
    min_open = 1;
    open_radius_mm  = min(min_open, max(voxel_size)); open_radius_mm( open_radius_mm<1 ) = 1;

    % convert mm to voxel
    open_radius_voxel   = min(round(open_radius_mm ./ voxel_size));

    % remove disconnected voxels, 20230124 v1.2.2: second input of strel has to be double
    CSFMask = imopen(mask_r2s, strel('sphere', double(open_radius_voxel)));
    % get the largest single object
    CSFMask = getLargestObject(CSFMask);    

    CSFMask(:) = CSFMask(:) .* Mask_Use(:);
    CSFMask(isinf(CSFMask)) = 0;

    mosaic( CSFMask, 12, 12, 2, strcat('CSF mask, refined with R2s'));    

    end

    if hdr.flag_erode
        erodeRadius=round(hdr.erodeRadius/min(voxel_size)); % mm to vox
        SE = strel('sphere', erodeRadius);
        CSFMask = imerode(double(CSFMask), SE);

        mosaic( CSFMask, 12, 12, 3, strcat('CSF mask after', num2str(hdr.erodeRadius), 'mm erosion'));    
    end


    CSFmask_fn = fullfile(hdr.output_dir, strcat(dataset{1}, '_CSF_Mask'));
    export_nii(CSFMask, CSFmask_fn);
end