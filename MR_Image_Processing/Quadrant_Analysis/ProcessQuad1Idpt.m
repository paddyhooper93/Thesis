function [Vol_Quad1] = ProcessQuad1Idpt(fsname, Vol, OS)
if nargin < 3
    OS = 10;
end
if matches(fsname, '3T')
    % Specify regions to keep
    x_keep = 1:(100+OS);
    y_keep = 1:(100+OS);
else
    % (length(dimx) = 128, length(dimy) = 142)
    x_keep = 1:(126+OS); 
    y_keep = 1:(142+OS); 
end

[Vol_Quad1] = zero_out_complement(x_keep, y_keep, Vol);
end