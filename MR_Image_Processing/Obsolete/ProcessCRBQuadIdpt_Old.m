function [Magn, Phs] = ProcessCRBQuadIdpt(dataset, Magn, Phs)
if contains(dataset, "TE1to7_9mth")
    % Specify regions to keep (length(dimx) = 100, length(dimy) = 100)
    x_keep = 48:147; % mid-way through matrix
    y_keep = 93:192; % 2nd half of matrix
elseif contains(dataset, "TE1to7_24mth")
    x_keep = 11:110; % 1st half of matrix
    y_keep = 1:100; % 1st half of matrix
elseif contains(dataset, "TE1to3_9mth")
    % (length(dimx) = 142, length(dimy) = 142)
    x_keep = 61:202; % mid-way through matrix
    y_keep = 131:272; % 2nd half of matrix
elseif contains(dataset, "TE1to3_24mth")
    x_keep = 1:142; % 1st half of matrix
    y_keep = 121:262; % 2nd half of matrix
end

[Magn, Phs] = zero_out_complement(x_keep, y_keep, Magn, Phs);
end