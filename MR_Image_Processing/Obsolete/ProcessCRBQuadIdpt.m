function [Magn, Phs] = ProcessCRBQuadIdpt(dataset, Magn, Phs)
if contains(dataset, "TE1to7_9mth") || contains(dataset, "TE1to7_24mth")
    x_keep = 93:192;
    y_keep = 93:192;
elseif contains(dataset, "TE1to3_9mth") ||  contains(dataset, "TE1to3_24mth")
    x_keep = 111:238;
    y_keep = 131:272;
end

[Magn, Phs] = zero_out_complement(x_keep, y_keep, Magn, Phs);
end