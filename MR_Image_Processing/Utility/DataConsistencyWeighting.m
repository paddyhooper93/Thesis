function [weights, hdr] = DataConsistencyWeighting(iFreq, hdr)

% e_mm = 1;
% e_vox=ceil(e_mm/min(hdr.voxel_size));
% fprintf('\n Eroding %d mm from edges ... \n', e_mm)
% Mask_Use = imerode(hdr.Mask_Use, strel('sphere', e_vox));

Mask_Use = hdr.Mask_Use;
voxel_size = hdr.voxel_size;


if ~isfield(hdr, 'fieldMapSD')
    TE_4D               = match_dims(hdr.TE, hdr.Magn);
    fieldMapSD          = sqrt(sum(hdr.Magn.^2 .* TE_4D.^2, 4));
else
    fieldMapSD = hdr.fieldMapSD .* Mask_Use;
end


weights             = sepia_utils_compute_weights_v1(fieldMapSD, Mask_Use);
% export_nii(single(weights), fullfile(hdr.output_dir, [hdr.dataset, '_weights']), hdr.voxel_size);


if hdr.ApplyWeightingFieldMapSD
    exclude_threshold = mean(fieldMapSD(Mask_Use == 1), "all");
    WeightingFieldMapSD = fieldMapSD;
    WeightingFieldMapSD(WeightingFieldMapSD > exclude_threshold) = exclude_threshold;
    WeightingFieldMapSD = (exclude_threshold - WeightingFieldMapSD) ./ exclude_threshold;
    weights = weights .* WeightingFieldMapSD; % Modulate the weighting map by a thresholded fieldMapSD
    % export_nii(single(weights), [hdr.output_dir, hdr.dataset, '_weights_N_std'], hdr.voxel_size);
elseif hdr.RelativeResidualMasking || hdr.RelativeResidualWeighting
    relativeResidualMap = ComputeResidualGivenR2sFieldmap(hdr.TE, hdr.R2s, ...
        iFreq, hdr.Magn .* exp(1i * hdr.Phs));
    exclude_threshold = 0.5;
    if hdr.RelativeResidualMasking
        hdr.relativeResidualMask = relativeResidualMap < exclude_threshold; % The thresholded relative residual map excludes unreliable voxels.
        if hdr.useQualityMask   
            export_nii(pad_or_crop_target_size(hdr.relativeResidualMask, voxel_size, hdr.FOV), fullfile(hdr.output_dir, [hdr.dataset, '_relativeResidualMask']), voxel_size);
        end
    elseif hdr.RelativeResidualWeighting
        relativeResidualWeights = relativeResidualMap;
        relativeResidualWeights(relativeResidualWeights > exclude_threshold) = exclude_threshold;
        relativeResidualWeights = (exclude_threshold - relativeResidualWeights) ./ exclude_threshold;
        weights = weights .* relativeResidualWeights; % Modulate the weighting map by a thresholded relative residual map.

%% Remove strong signal (weighting) contribution from glue
% The glue produces a strong signal (therefore a strong weighting value)
% The maximum weighting value should not be larger than 2; if so, set to 0
% weights(weights > 2) = 0;

        % export_nii(single(weights), [hdr.output_dir, hdr.dataset, '_weights_RR'], hdr.voxel_size);
    end
end



export_nii(pad_or_crop_target_size(weights, voxel_size, hdr.FOV), fullfile(hdr.output_dir, [hdr.dataset, '_weights']), voxel_size);
% mosaic( weights, 12, 12, 11, 'Data consistency weighting map', [0 1] )

end
