function [Vol_Quad2] = ProcessQuad2Idpt(fsname, Vol, OS)
if matches(fsname, '3T')
    % Specify regions to keep
    x_keep = 1:(100+OS);
    y_keep = (93-OS):192;
else
    % (length(dimx) = 128, length(dimy) = 142)
    x_keep = 1:(126+OS); % x_keep = 111:238;
    y_keep = (131-OS):272; % y_keep = 131:272;
end

[Vol_Quad2] = zero_out_complement(x_keep, y_keep, Vol);
end