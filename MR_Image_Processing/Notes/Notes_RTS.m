% Code to use RTS dipole inversion.
if hdr.isRTS
    disp('Using RTS for dipole inversion.')
    % RTS expects local field in ppm.
    gamma = 42.6; % MHz/T
    RDF_ppm = RDF/(gamma * hdr.FS); % ppm
    bdir  = [0 0 -1];
    opts.tv = 2; % isotropic
    [QSM_RTS] = rts(RDF_ppm, Mask_Use, voxel_size, bdir, opts);
    if hdr.CorrectNaCl
        QSM_RTS = QSM_RTS + (-0.1106 .* Mask_Use); % Bulk medium correction
    end
    QSM_RTS = pad_or_crop_target_size(QSM_RTS, hdr.voxel_size);
    export_nii(QSM_RTS, fullfile(hdr.output_dir, [hdr.dataset, '_QSM_RTS']), hdr.voxel_size);
end