% Function to zero out regions of a matrix
function [Vol] = zero_out(x_zero, y_zero, Vol, Mz)
for z = 1:Mz
    % Zero out the region where x AND y are within the speciifed ranges
    Vol(x_zero, y_zero, z) = 0;
end