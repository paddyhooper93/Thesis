function [hdr] = Wrapper_MaskUse(hdr)
% Argin: "hdr" structure, used to parse variables
% Argout: "hdr" structure, variables parsed
% Generate "Mask_Use": Mask for all steps up to BFC
% Step 1: BET Mask
% Step 2: Filling in holes: removes masking imperfections

iMag = hdr.iMag;

if isfield(hdr, 'Mask_Use')
    % iMag = iMag .* hdr.Mask_Use;
    % hdr.BET_Mask = hdr.Mask_Use;
    % if hdr.erode_before_radius > 0
    %     e_vox=hdr.erode_before_radius;
    %     fprintf(['Eroding ', num2str(e_vox), ' voxels(s) from edges... \n'])
    %     hdr.Mask_Use = imerode(hdr.Mask_Use, strel('sphere', e_vox));
    % end    
    hdr.BET_Mask = hdr.Mask_Use;
    return
end


voxel_size = hdr.voxel_size;
matrix_size = hdr.matrix_size;

% Step 1: BET Mask
fractional_threshold= 0.3;
gradient_threshold  = 0.2;
BET_Mask             = BET(iMag, matrix_size, voxel_size, ...
    fractional_threshold, gradient_threshold);
% mosaic( BET_Mask, 12, 12, 1, 'BetMask' )


% Step 2: Filling in holes: removes masking imperfections

for i=size(iMag,3) :-1 :1
    Mask_Use(:, :, i) = imfill(BET_Mask(:, :, i), 26, 'holes');
end
% Mask_Use = imfill(BETMask, 26, 'holes');
% mosaic( Mask_Use, 12, 12, 3, 'Mask\_Use' )



if hdr.saveMaskUse
    export_nii(Mask_Use, strcat(hdr.output_dir, hdr.dataset, '_Mask_Use'));
end

% Save Mask_Use in a struct for later use.
hdr.BET_Mask = BET_Mask;
hdr.Mask_Use = Mask_Use;