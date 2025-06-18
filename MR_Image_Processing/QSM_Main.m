function QSM_Main(dataset, hdr)

%% Step 0: Load dataset and initialize parameters into hdr struct
[hdr] = InitializeParams(dataset, hdr);

%% Step 1: Generate Mask_Use (BET Mask with holes filled in)
[hdr] = Wrapper_MaskUse(hdr);

%% Step 2: Unwrapping and Echo Combination
[iFreq, hdr] = FieldMapping(hdr);

%% Step 3: Data fidelity/consistency weighting
[weights, hdr] = DataConsistencyWeighting(iFreq, hdr);

%% Step 4-5: Single-Step TGV
if isfield(hdr, 'SingleStep') && hdr.SingleStep
    disp('Using SS-TGV to remove background field and dipole inversion in 1 step.')
    SingleStep(iFreq, hdr)
    % return
end

%% Step 4: Background field correction
[RDF, hdr] = BackgroundFieldCorrection(iFreq, hdr);

%% Step 5: Save workspace
% Clear up workspace prior to MEDI
if isfield(hdr, 'Magn')
    hdr = rmfield(hdr, 'Magn');
end
if isfield(hdr, 'Phs')
    hdr = rmfield(hdr, 'Phs');
end

if hdr.saveWorkspace
    hdr.workspace_fn = fullfile(hdr.output_dir, [hdr.dataset, '_workspace.mat']);
    save(hdr.workspace_fn, '-v7.3');
    fprintf('Vars saved to %s\n', hdr.workspace_fn);
end

%% Step 6: Masking
% if ~contains(hdr.dataset, 'TE')
%     ROI_Mask = hdr.Mask_Use .* hdr.qualityMask .* hdr.relativeResidualMask;
%     e_vox = round(2 ./ mean(hdr.voxel_size));
%     ROI_Mask = imclose(ROI_Mask, strel('sphere', e_vox));
% else
ROI_Mask = hdr.Mask_Use;
% end
export_nii(pad_or_crop_target_size(ROI_Mask, hdr.voxel_size, hdr.FOV), fullfile(hdr.output_dir, [hdr.dataset,'_ROI_Mask']), hdr.voxel_size);

CSF_Mask = hdr.R2s < 6 .* ROI_Mask; %extract_CSF(hdr.R2s, Mask_Use, voxel_size);
e_vox = round(2 ./ mean(hdr.voxel_size));
CSF_Mask = imerode(CSF_Mask, strel('sphere', e_vox));
sd_vox = 2;
CSF_Mask = smooth3(CSF_Mask, 'gaussian', 3, sd_vox);
CSF_Mask = CSF_Mask > 0.5;
CSF_Mask = getLargestObject(CSF_Mask, 6);
export_nii(pad_or_crop_target_size(CSF_Mask, hdr.voxel_size, hdr.FOV), fullfile(hdr.output_dir, [hdr.dataset,'_CSF_Mask']), hdr.voxel_size);

hdr.CSF_Mask = CSF_Mask;
hdr.ROI_Mask = ROI_Mask;

if hdr.saveWorkspace
    hdr.workspace_fn = fullfile(hdr.output_dir, [hdr.dataset, '_workspace.mat']);
    save(hdr.workspace_fn, 'hdr', '-append');
    fprintf('Vars saved to %s\n', hdr.workspace_fn);
end




%% Step 7: Dipole inversion
% DipoleInversion(weights, RDF, hdr);