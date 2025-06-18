% Introduce holes into mask
if hdr.useQualityMask

    if contains(hdr.dataset, 'Neutral')
        hdr.qualityMask = hdr.fieldMapSD < (mean(hdr.fieldMapSD(Mask_Use == 1), "all"));
        Mask_Use             = hdr.qualityMask .* Mask_Use;
        % Mask_Use             = hdr.relativeResidualMask .* Mask_Use;
    else

        Mask_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\Brain_ROI_Mask';
        nii_fn = [hdr.dataset(1:2), '_Neutral_to', hdr.dataset(3:7),'_Mask_Use.nii.gz'];
        nii = load_untouch_nii(fullfile(Mask_dir, nii_fn));           
        Mask_Use = pad_or_crop_target_size(nii.img, hdr.voxel_size);

    end

else

    Mask_Use = BET_Mask;

    if contains(hdr.dataset, '3T') 
        if contains(hdr.dataset, 'Rot2')
            Mask_Use = imerode(Mask_Use, strel('sphere', 3));
        else
            Mask_Use = imerode(Mask_Use, strel('sphere', 2));
        end
    elseif contains(hdr.dataset, '7T') 
        Mask_Use = imerode(Mask_Use, strel('sphere', 4));
    end

    hdr.Mask_Use = Mask_Use;

end

% 
% if hdr.isSMV
%     hdr.Mask_Use = imerode(hdr.BET_Mask, strel('sphere', 3/min(hdr.voxel_size)));
% else
%     hdr.Mask_Use = Mask_Use;
% end
% Gaussian smoothing to local fields
if isfield(hdr, 'applyGaussianSmoothing') && hdr.applyGaussianSmoothing
    SD = 1.2/2.355;
    RDF = smooth3(RDF, 'gaussian', 3, SD);
    export_nii(pad_or_crop_target_size(RDF, hdr.voxel_size), fullfile(hdr.output_dir, [hdr.dataset, '_RDF_GaussianSmooth']), hdr.voxel_size);
end

if isfield(hdr, 'applyFermiFiltering') && hdr.applyFermiFiltering
    RDF = FermiFilter(RDF);
    export_nii(pad_or_crop_target_size(RDF, hdr.voxel_size), fullfile(hdr.output_dir, [hdr.dataset, '_RDF_FermiFilt']), hdr.voxel_size);
end

export_nii(Mask_Use, fullfile(hdr.output_dir, [hdr.dataset, '_Mask_Use']), hdr.voxel_size);