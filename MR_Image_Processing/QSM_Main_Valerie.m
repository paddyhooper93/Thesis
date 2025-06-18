function [hdr] = QSM_Main_Valerie(dataset, hdr)


%% Step 0: Load dataset and initialize parameters into hdr struct
[hdr] = InitializeParams_Valerie(dataset, hdr);



%% Step 1: Generate Mask_Use (BET Mask with holes filled in)
[hdr] = Wrapper_MaskUse(hdr); 

%% Step 2: Unwrapping and Echo Combination
[iFreq, hdr] = FieldMapping(hdr);

%% Step 3: Data fidelity/consistency weighting
[weights, hdr] = DataConsistencyWeighting(iFreq, hdr);



%% Step 4&5: Single-Step TGV
if hdr.SingleStep
    disp('Using SS-TGV to remove background field and dipole inversion in 1 step.')
    SingleStep(iFreq, hdr)
    % return
end

%% Step 4: Background field correction
[RDF, hdr] = BackgroundFieldCorrection(iFreq, hdr);

% Clear up workspace prior to MEDI
if isfield(hdr, 'Magn')
    hdr = rmfield(hdr, 'Magn');
end
if isfield(hdr, 'Phs')
    hdr = rmfield(hdr, 'Phs');
end
if hdr.saveWorkspace
    hdr.workspace_fn = fullfile(hdr.output_dir, strcat(hdr.dataset, '_workspace.mat'));
    save(hdr.workspace_fn, '-v7.3');
    fprintf('Vars saved to %s\n', hdr.workspace_fn);
end





%% Step 5: Dipole inversion

DipoleInversion(weights, RDF, hdr);


