function TE_4D = match_dims(TE_1D, vol_4D)
    if length(TE_1D) ~= size(vol_4D, 4)
        error('Length of TE_1D must match the fourth dimension of vol_4D.')
    end
    vol_size = size(vol_4D);
    TEs_reshaped = reshape(TE_1D, [1 1 1 length(TE_1D)]);
    TE_4D = repmat(TEs_reshaped, [vol_size(1) vol_size(2) vol_size(3) 1]);
end