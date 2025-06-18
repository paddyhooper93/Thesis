% , '7T_Neutral', '7T_Rot1', '7T_Rot2', '7T_Rot3', '7T_Rot4', ...
% '3T_Neutral', '3T_Rot1', '3T_Rot3', '3T_Rot5', '3T_Rot6'
for dataset = {'3T_Rot2'} 

hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\SDC\';
hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\NLFit_PDF\';
% workspace_fn = fullfile(hdr.output_dir, [dataset{1}, '_workspace.mat']);
% load(workspace_fn, "iFreq", "hdr") % "weights", "RDF", 
% vars_fn = fullfile(hdr.path_to_data, [dataset{1}, '_forQSM.mat']);
% load(vars_fn, "Magn", "Phs");
% hdr.Magn = Magn_Rescaling(Magn); hdr.Phs = DICOM2Radians(Phs); 
% hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\NLFit_PDF_weighting_test\'; 
% hdr.RelativeResidualMasking = true; 
% if contains(dataset{1}, '3T')
    % hdr.RelativeResidualWeighting = true;
% else
    % hdr.RelativeResidualWeighting = false;
% end

% hdr = rmfield(hdr, 'fieldMapSD');
hdr.useQualityMask = true;
hdr.noDipoleInversion = false;
hdr.EchoCombineMethod = 'NLFit'; hdr.unwrapMethod = 'ROMEO';
hdr.BFCMethod = 'PDF'; hdr.erode_before_radius = 2;    
hdr.saveDelta = true; hdr.saveWorkspace = true;
hdr.invertPhase = true;
[hdr] = InitializeParams_Valerie(dataset{1}, hdr);
[hdr] = Wrapper_MaskUse(hdr); 
[iFreq, hdr] = FieldMapping(hdr);
hdr.RelativeResidualWeighting = false;
[weights, hdr] = DataConsistencyWeighting(iFreq, hdr);
% [RDF, hdr] = BackgroundFieldCorrection(iFreq, hdr);
% hdr.noDipoleInversion = false;    

if contains(dataset{1}, '7T_Neutral')
    hdr.optimizeMEDI = true;
    DipoleInversion(iFreq, weights, RDF, hdr);
end

end


% FS={'3T', '7T'}; num_orient = 5; Wrapper_COSMOS_Recon(FS,num_orient);
% num_orient = 4; Wrapper_COSMOS_Recon(FS,num_orient);