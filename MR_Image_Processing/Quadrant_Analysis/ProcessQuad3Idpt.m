function [Vol_Quad3] = ProcessQuad3Idpt(fsname, Vol, OS)
if matches(fsname, '3T')
    x_keep = (93-OS):192;
    y_keep = 1:(100+OS);
else
    % (length(dimx) = 128, length(dimy) = 142)
    x_keep = (111-OS):238;
    y_keep = 1:(142+OS);
end

[Vol_Quad3] = zero_out_complement(x_keep, y_keep, Vol);
end