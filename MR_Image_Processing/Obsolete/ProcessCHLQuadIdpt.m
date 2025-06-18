function [Magn, Phs] = ProcessCHLQuadIdpt(dataset, Magn, Phs)
if contains(dataset, "3T_BL") || contains(dataset, "3T_9mth")
    % Specify regions to keep (length(dimx) = 100, length(dimy) = 100)
    x_keep = 93:192;
    y_keep = 1:100;
elseif contains(dataset, "3T_24mth")
    x_keep = 1:100;
    y_keep = 1:100;
elseif contains(dataset, "7T_BL") || contains(dataset, "7T_9mth")
    % (length(dimx) = 142, length(dimy) = 142)
    x_keep = 111:238;
    y_keep = 1:142;
elseif contains(dataset, "7T_24mth")
    x_keep = 1:126;
    y_keep = 1:142;
end

[Magn, Phs] = zero_out_complement(x_keep, y_keep, Magn, Phs);
end