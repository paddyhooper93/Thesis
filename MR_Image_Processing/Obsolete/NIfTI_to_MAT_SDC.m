function NIfTI_to_MAT_SDC(hdr, dataset)

    Magn_fn = fullfile( hdr.output_dir, [dataset, '_Magn_SDC.nii.gz']);
    Magn = load_untouch_nii(Magn_fn);
    Magn = double(Magn.img);

    Phs_fn = fullfile( hdr.output_dir, [dataset, '_Phs_SDC.nii.gz']);
    Phs = load_untouch_nii(Phs_fn);
    Phs = double(Phs.img);   

    Mask_fn = fullfile( hdr.path_to_data, [dataset, '_Mask_Use.nii.gz']);
    Mask_Use = load_nii(Mask_fn);
    Mask_Use = double(Mask_Use.img);

    R2s_fn = fullfile( hdr.path_to_data, [dataset, '_R2s.nii.gz'] );
    R2s = load_untouch_nii(R2s_fn);
    R2s = double(R2s.img);
    R2s = pad_or_crop(R2s, dataset);
    
    savefile = fullfile( hdr.output_dir, [dataset, '_forQSM.mat'] );
    save(savefile, "Magn", "Phs", "Mask_Use", "R2s");  

end