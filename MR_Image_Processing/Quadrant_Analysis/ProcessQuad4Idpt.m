function [Vol_Quad4] = ProcessQuad4Idpt(fsname, Vol, OS)
if matches(fsname, '3T')
    % Specify regions to keep
    x_keep = (93-OS):192;
    y_keep = (93-OS):192;
else
    % (length(dimx) = 128, length(dimy) = 142)
    x_keep = (111-OS):238;
    y_keep = (131-OS):272;
end

[Vol_Quad4] = zero_out_complement(x_keep, y_keep, Vol);
end