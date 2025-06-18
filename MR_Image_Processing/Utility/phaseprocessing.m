for dataset = {'7T_Rot6'}
%% Phase processing
    
    hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\SDC';
    hdr.BFCMethod = 'PDF'; hdr.erode_before_radius = 3;
    hdr.saveDelta = true; hdr.saveWorkspace = true;
    if contains(dataset{1}, '3T')
        hdr.EchoCombineMethod = 'SNRwAVG';
        hdr.temporalUnwrapping = 'ROMEO';
    else
        hdr.EchoCombineMethod = 'NLFit';
        hdr.unwrapMethod = 'ROMEO';
    end

    hdr.RelativeResidualWeighting = false;
    hdr.RelativeResidualWeighting = false;
    hdr.useQualityMask = true;
    hdr.optimizeMEDI = false;
    hdr.noDipoleInversion = true;
    hdr.saveWorkspace = true;
    hdr.unwrapMethod= 'GraphCuts'; hdr.subsampling=2;
    hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\SNRwAVG_PDF';
    QSM_Main_Valerie(dataset{1}, hdr);

end