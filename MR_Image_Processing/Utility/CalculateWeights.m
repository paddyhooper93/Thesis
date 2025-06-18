function [weights] = CalculateWeights(Magn, TE, Mask_Use)

TE_4D               = match_dims(TE, Magn);
fieldMapSD          = sqrt(sum(Magn .* Magn .* (TE_4D .* TE_4D), 4));

weights             = sepia_utils_compute_weights_v1(fieldMapSD, Mask_Use);

function TE_4D = match_dims(TE_1D, vol_4D)
    if length(TE_1D) ~= size(vol_4D, 4)
        error('Length of TE_1D must match the fourth dimension of vol_4D.')
    end
    vol_size = size(vol_4D);
    TEs_reshaped = reshape(TE_1D, [1 1 1 length(TE_1D)]);
    TE_4D = repmat(TEs_reshaped, [vol_size(1) vol_size(2) vol_size(3) 1]);
end

end