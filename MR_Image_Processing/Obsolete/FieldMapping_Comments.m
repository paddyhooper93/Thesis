function [iFreq, hdr] = FieldMapping(hdr)

Magn = hdr.Magn;
Phs = hdr.Phs;
TE = hdr.TE;
voxel_size = hdr.voxel_size;
Mask_Use = hdr.Mask_Use;

% MCPC bipolar corrected phase (already done for all datasets)
mosaic( Phs(:,:,:,1), 12, 12, 5, 'MCPC bipolar Corrected Phase (TE\_1)', [-pi pi] )

if contains(hdr.EchoCombineMethod, 'wAVG')
    % Unwrap echoes before fieldmapping
    % if matches(hdr.unwrapMethod, 'ROMEO')
    [unwrapped] = UnwrapAllTE_ROMEO(hdr);
    % elseif matches(hdr.unwrapMethod, 'GraphCut')
    %     [unwrapped] = UnwrapAllTEs_GC(hdr);
    % end
end

if matches(hdr.EchoCombineMethod, 'Magn_wAVG')
    [iFreq] = EchoCombine_MagnWeighted(Magn, unwrapped, TE);
    iFreq = iFreq .* Mask_Use;
    mosaic( iFreq, 12, 12, 6, 'Magn wAVG Field map', [-300 300] )
    return
elseif matches(hdr.EchoCombineMethod, 'SNR_wAVG')
    [iFreq] = EchoCombine_SNRweighted(unwrapped, hdr);
    iFreq = iFreq .* Mask_Use;
    mosaic( iFreq, 12, 12, 6, 'SNR wAVG Field map', [-300 300] )
    return
end

if matches(hdr.EchoCombineMethod, 'NLF') || ~exist(hdr.EchoCombineMethod, "var")
    % MEDI Nonlinear Fitting
    [iField] = Magn.*exp(-1i*Phs);
    [iFreq_raw, fieldMapSD] = Fit_ppm_complex(iField);
    mosaic( iFreq_raw, 12, 12, 8, 'NLF Field map, not yet unwrapped', [-pi pi] )

    Magn_TE1 = Magn(:,:,:,1) .* Mask_Use;
    subsampling = 2;
    [iFreq_rad] = unwrapping_gc(iFreq_raw, Magn_TE1, voxel_size, subsampling);
% elseif matches(hdr.unwrapMethod, 'ROMEO')
%     [iFreq_rad] = UnwrapSingleTE_ROMEO(iFreq_raw, hdr) .* Mask_Use;
% end

    % find the centre of mass
    pos     = round(centerofmass(Magn(:,:,:,1)));
    % use the centre of mass as reference phase
    iFreq_rad = iFreq_rad-round(iFreq_rad(pos(1),pos(2),pos(3))/(2*pi))*2*pi;

    % convert from radians to Hz
    delta_TE     = TE(2)-TE(1);
    iFreq        = iFreq_rad / (2*pi*delta_TE);

    mosaic( iFreq, 12, 12, 9, 'NLF fieldmap', [-300 300] )

    % Save fieldMapSD in a struct for later useage.
    hdr.fieldMapSD = fieldMapSD;
    
end