function [Magn, Phs] = ProcessCHLQuadIdpt(dataset, Magn, Phs)
if contains(dataset, "3T_BL")
    % Specify regions to keep (length(dimx) = 100, length(dimy) = 100)
    x_keep = 93:192; % 2nd half of matrix
    y_keep = 8:107; % 1st half of matrix
elseif contains(dataset, "3T_9mth")
    x_keep = 93:192; % 2nd half of matrix
    y_keep = 47:146; % mid-way through matrix
elseif contains(dataset, "3T_24mth")
    x_keep = 83:182; % 2nd half of matrix
    y_keep = 93:192; % 2nd half of matrix
elseif contains(dataset, "7T_BL")
    % (length(dimx) = 142, length(dimy) = 142)
    x_keep = 97:238; % 2nd half of matrix
    y_keep = 111:252; % 2nd half of matrix
elseif contains(dataset, "7T_9mth")
    x_keep = 121:262; % 2nd half of matrix
    y_keep = 71:213; % mid-way through matrix
elseif contains(dataset, "7T_24mth")
    x_keep = 121:262; % 2nd half of matrix
    y_keep = 21:162; % 1st half of matrix
end

[Magn, Phs] = zero_out_complement(x_keep, y_keep, Magn, Phs);
end