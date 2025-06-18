function [Magn, Phs] = ProcessFERQuadIdpt(dataset, Magn, Phs)
if contains(dataset, "3T_BL")
    % Specify regions to keep (length(dimx) = 100, length(dimy) = 100)
    x_keep = 11:110;
    y_keep = 1:100;
elseif contains(dataset, "3T_9mth")
    x_keep = 47:146;
    y_keep = 1:100;
elseif contains(dataset, "3T_24mth")
    x_keep = 93:192;
    y_keep = 13:112;
elseif contains(dataset, "7T_BL")
    % (length(dimx) = 142, length(dimy) = 142)
    x_keep = 97:238;
    y_keep = 1:142;
elseif contains(dataset, "7T_9mth")
    x_keep = 39:180;
    y_keep = 1:142;
elseif contains(dataset, "7T_24mth")
    x_keep = 11:152;
    y_keep = 11:152;
end

[Magn, Phs] = zero_out_complement(x_keep, y_keep, Magn, Phs);
end