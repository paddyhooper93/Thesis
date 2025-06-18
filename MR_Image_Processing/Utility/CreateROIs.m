function [ROIs] = CreateROIs(dataset, hdr)
% Argin 1: String variable of dataset
% Argin 2: "hdr" structure, used to parse variables
% Argout: "hdr" structure, variables parsed

%% Step 0: Initialize header opts
[hdr] = CreateHeader(hdr);
[hdr] = InitializeVar(dataset, hdr);

%% Step 1: Generate Mask_Use
[hdr] = MaskingPipeline(hdr);
Mask_Use = hdr.Mask_Use;

%% Step 2: Generate relativeResidualMask
[iFreq, hdr] = FieldMap_UnwrapPhase(hdr);
[~, hdr] = DataConsistencyWeighting(iFreq, hdr);
relativeResidualMask = logical(hdr.relativeResidualMask);

%% Step 3: Find background gel medium (Bckg)
R2s = hdr.R2s;
voxel_size = hdr.voxel_size;
Bckg = refine_brain_mask_using_r2s(R2s, Mask_Use, voxel_size, 1, 1);

%% Step 4: Generate ROIs using Bckg and Mask_Use
% Preallocate memory for the output
ROIs = zeros(size(Mask_Use));
Bckg = logical(Bckg);
Mask_Use = logical(Mask_Use);

% Find the complement of the background within Mask_Use
% Process in slices
for slice = 1:size(Mask_Use, 3)
    ROIs(:, :, slice) = Mask_Use(:, :, slice) & ~Bckg(:, :, slice);
end

%% Step 5: Mask the ROIs by Mask_Use and relativeResidualMask
% Perform element-wise multiplication
ROIs = ROIs .* Mask_Use .* relativeResidualMask;

%% Step 6: Zero out slices not equal to 71 to 120
z_full = 1:size(Mask_Use, 3);
z_keep = 71:130;
ROIs(:, :, setdiff(z_full, z_keep)) = 0;

end