function [Magn, Phs] = ProcessUSPQuadIdpt(dataset, Magn, Phs)
if contains(dataset, "3T_BL")
    % Specify regions to keep
    x_keep = 1:100;
    y_keep = 93:192;
elseif contains(dataset, "3T_9mth")
    x_keep = 1:100;
    y_keep = 51:150;
elseif contains(dataset, "3T_24mth")
    x_keep = 1:100;
    y_keep = 71:170;
elseif contains(dataset, "7T_BL")
    x_keep = 1:142;
    y_keep = 21:162;
elseif contains(dataset, "7T_9mth")
    x_keep = 1:142;
    y_keep = 81:222;
elseif contains(dataset, "7T_24mth")
    x_keep = 110:251;
    y_keep = 131:272;
end

[Magn, Phs] = zero_out_complement(x_keep, y_keep, Magn, Phs);
end