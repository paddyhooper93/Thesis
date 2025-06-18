function [hdr] = Wrapper_MaskUse_Valerie(hdr)
% Argin: "hdr" structure, used to parse variables
% Argout: "hdr" structure, variables parsed
% Generate "Mask_Use": Mask for all steps up to BFC
% Step 1: BET_Mask
% Step 2: Filling in holes: removes masking imperfections

if isfield(hdr, 'Mask_Use')
    return
end

% Step 1: BET Mask
fractional_threshold= 0.5;
gradient_threshold  = 0.0;
BET_Mask             = BET(hdr.Magn(:,:,:,1), hdr.matrix_size, hdr.voxel_size, ...
    fractional_threshold, gradient_threshold) > 0;
mosaic( double(BET_Mask), 12, 12, 1, 'BET\_Mask' )


% Step 2: Filling in holes: removes masking imperfections

% for i=size(BET_Mask, 3) : -1 : 1
%     Mask_Use(:, :, i) = imfill(BET_Mask(:, :, i), 26, 'holes');
% end
Mask_Use = imfill(BET_Mask, 26, 'holes') > 0;

mosaic( double(Mask_Use), 12, 12, 3, 'Mask\_Use' )

if hdr.saveMaskUse
    export_nii(double(Mask_Use), strcat(hdr.output_dir, hdr.dataset, '_Mask_Use'));
end

% Save Mask_Use in a struct for later use.
hdr.Mask_Use = Mask_Use;
hdr.BET_Mask = BET_Mask;