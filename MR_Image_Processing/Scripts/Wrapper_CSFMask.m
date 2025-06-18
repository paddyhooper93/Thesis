function [varargout] = Wrapper_CSFMask(R2s, voxel_size, Mask, hdr, erodeRadius)
% Mask for automatic zero-referencing with MEDI
% Argin1: R2star map, units: s^-1 
% Argin2: voxel size, units: mm
% Argin3: QSM_Mask
% Argin4: "hdr" structure, used to parse variables
% (Optional) Argin5: erodeRadius, units: mm
% Argout1: Complement_Mask (Complement of the vials, giving the bulk medium) -> standard "CSF_Mask"
% (Optional) Argout2: Eroded_Complement_Mask -> reduces the chi standard deviation of the "CSF_Mask"
% Step 1: Produce R2* map (already done for all datasets)
% Step 2: Perform simple R2* thresholding
% Step 3: Mask erosion

if nargin < 5
    erodeRadius = 2; % mm
end

% Step 1: Produce R2* map (already done for all datasets)
mosaic( double(R2s), 12, 12, 21, 'R2star map (s^{-1})', [0 100] )

% Step 2: Perform simple R2* thresholding
thresh_R2s = 5;
Complement_Mask = R2s < thresh_R2s;
Complement_Mask = double(Complement_Mask .* Mask);

mosaic( Complement_Mask, 12, 12, 22, 'Standard "CSF\_Mask"' )

if hdr.saveComplementMask
    export_nii(Complement_Mask, fullfile(hdr.output_dir, strcat(hdr.dataset, '_Complement_Mask')))
end    

if nargout == 2

    % Step 3: Mask erosion
    erodeRadius=round(erodeRadius/min(voxel_size)); % mm to vox
    SE = strel('sphere', erodeRadius);
    [ Eroded_Complement_Mask ] = imerode(Complement_Mask, SE);

    mosaic( Eroded_Complement_Mask, 12, 12, 23, 'Eroded "CSF\_Mask"' )

    if hdr.saveErodedComplementMask
        export_nii(Eroded_Complement_Mask, fullfile(hdr.output_dir, strcat(hdr.dataset, '_CSF_Mask')))
    end
    
end

% Assign outputs based on the number of requested outputs
if nargout == 1
    varargout{1} = Complement_Mask;
elseif nargout == 2
    varargout{1} = Complement_Mask;
    varargout{2} = Eroded_Complement_Mask;
end




%% Alternative methods for Step 3:
%   Apply "CSFmaskThresh" function from the JHU/KKI toolbox -> [ CSF_Mask ] = CSFmaskThresh(R2s, thresh_R2s, QSM_Mask, voxel_size);
% Standard MEDI+0 implementation -> CSF_Mask = extract_CSF(R2s, Mask_Use, voxel_size);
% perform signal intensity thresholding (Reference: Deh et al., 2019, DOI: 10.1002/mrm.27410)
% -> magThreshold = 40; % percentage
% -> CSF_Mask = iMag > ( magThreshold / 100 * max( iMag ) );

%% Notes on Step 4:
% MEDI+0 assumes Chi(CSF_Mask) = 0 ppm.
% Therefore, additional step required to exclude "high-frequency/susceptibility regions", due to Gibbs Ringing artifacts at vial edge.
% "Low-frequency/susceptibility regions" defined as: abs(Chi) < 0.05 ppm (i.e., 50 ppb).