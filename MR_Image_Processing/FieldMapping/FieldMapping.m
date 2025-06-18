function [iFreq, hdr] = FieldMapping(hdr)

TE = hdr.TE;
voxel_size = hdr.voxel_size;
Mask_Use = hdr.Mask_Use;

delta_TE = TE(2)-TE(1);

%% MCPC bipolar corrected phase (already done on all datasets)
if isfield(hdr, 'Bipolar_MCPC') && hdr.Bipolar_MCPC
    [hdr.Phs] = PhaseOffsetCorrection_MCPC(hdr);
end

if isfield(hdr, 'ROMEO_qualityMask') && hdr.ROMEO_qualityMask
    [~, quality, robustmask] = PhaseOffsetCorrection_MCPC(hdr);
    export_nii(single(pad_or_crop_target_size(robustmask, hdr.voxel_size)), fullfile(hdr.output_dir, [hdr.dataset, '_robustmask']), hdr.voxel_size);    
    ROMEO_qualityMask = quality > 0.5;
    export_nii(single(pad_or_crop_target_size(ROMEO_qualityMask, hdr.voxel_size)), fullfile(hdr.output_dir, [hdr.dataset, '_ROMEO_Mask']), hdr.voxel_size);
end

mosaic( hdr.Phs(:,:,:,1), 12, 12, 5, 'MCPC bipolar Corrected Phase (TE\_1)', [-pi pi] )

if contains(hdr.EchoCombineMethod, 'wAVG', 'IgnoreCase', true)
    if hdr.useQualityMask
        [~, fieldMapSD] = Fit_ppm_complex(hdr.Magn.*exp(-1i*hdr.Phs)); 
    end
    fprintf('Temporal unwrapping: %s, Echo combination: %s \n', hdr.unwrapMethod, hdr.EchoCombineMethod)
    % Unwrap all the echoes before fieldmapping:
    % ROMEO and GraphCuts (GC) have been tested across all datasets -> no significant difference between each method.
    if matches(hdr.unwrapMethod, 'ROMEO', 'IgnoreCase', true)
        % ROMEO 1st-echo template unwrapping -> fast.
        [unwrapped, iFreq] = UnwrapAllTEs_ROMEO(hdr);
        % hdr.qualityMask = single(quality > 0.5);
        % export_nii(hdr.qualityMask, [hdr.output_dir, hdr.dataset, '_ROMEO_Mask'], hdr.voxel_size);        
    elseif matches(hdr.unwrapMethod, 'GraphCuts')
        % GC unwraps the phase shift between each echoes -> slow.
        [unwrapped] = UnwrapAllTEs_GC(hdr);
    elseif matches(hdr.unwrapMethod, 'Laplacian')
        [unwrapped] = UnwrapAllTEs_Laplacian(hdr);
    end
    if contains(hdr.EchoCombineMethod, 'MagnwAVG', 'IgnoreCase', true)
        % [iFreq] = EchoCombine_MagnWeighted(hdr.Magn, unwrapped, TE) .* Mask_Use;
        iFreq = iFreq .* Mask_Use;
    elseif contains(hdr.EchoCombineMethod, 'SNRwAVG', 'IgnoreCase', true)
        N = size(Mask_Use);
        R2s = hdr.R2s;
        [iFreq] = EchoCombine_SNRweighted(unwrapped, TE, N, R2s) .* Mask_Use;
        % [iFreq] = EchoCombine_SNRweighted(unwrapped, hdr) .* Mask_Use;
    end
    if hdr.saveFieldMap
        export_nii(single(iFreq), fullfile( hdr.output_dir, [hdr.dataset, '_iFreq']), voxel_size);
    end


elseif contains(hdr.EchoCombineMethod, 'NLFit', 'IgnoreCase', true)
    fprintf('Echo combination: %s, Spatial unwrapping: %s \n', hdr.EchoCombineMethod, hdr.unwrapMethod)
    [iFreq_raw, fieldMapSD] = Fit_ppm_complex(hdr.Magn.*exp(-1i*hdr.Phs));

    mosaic( iFreq_raw, 12, 12, 8, 'NLF Field map, not yet unwrapped', [-pi pi] )
    
    % Unwrap the combined phase:
    if matches(hdr.unwrapMethod, 'GraphCuts', 'IgnoreCase', true)
        % Here, GraphCuts (GC) performed noticeably better than ROMEO.
        % In particular, unwrapping of the 7 T data did not fail when using GC.
        [iFreq] = unwrapping_gc(iFreq_raw, hdr.Magn(:,:,:,1), voxel_size, hdr.subsampling);
    elseif matches(hdr.unwrapMethod, 'ROMEO')
        [iFreq] = UnwrapSingleTE_ROMEO(iFreq_raw, hdr.Magn(:,:,:,1), Mask_Use, voxel_size, hdr.output_dir);
    end
    
    % find the centre of mass
    pos     = round(centerofmass(hdr.Magn(:,:,:,1)));
    % use the centre of mass as reference phase
    iFreq = iFreq-round(iFreq(pos(1),pos(2),pos(3))/(2*pi))*2*pi;
    
    % convert from radians to Hz
    iFreq        = iFreq / (2*pi*delta_TE); % Hz
    
    % Multiply by the mask
    iFreq        = iFreq .* Mask_Use;
    
    if hdr.saveFieldMap
        export_nii(single(iFreq), fullfile( hdr.output_dir, [hdr.dataset, '_iFreq']), voxel_size);
    end
    
    mosaic( iFreq, 12, 12, 9, 'NLF fieldmap', [-300 300] )
    
end

% Save fieldMapSD in a struct for later useage.
hdr.fieldMapSD = fieldMapSD;
hdr.iFreq = iFreq;
hdr.delta_TE = delta_TE;

if hdr.useQualityMask
    hdr.qualityMask = hdr.fieldMapSD < (mean(hdr.fieldMapSD(Mask_Use == 1), "all"));
    export_nii(single(pad_or_crop_target_size(hdr.qualityMask, hdr.voxel_size)), fullfile(hdr.output_dir, [hdr.dataset, '_NLFit_Mask']), hdr.voxel_size);
end