function [wG]=gradient_mask_fansi(iMag, Mask, grad, voxel_size, noise, percentage)

if nargin < 6
    percentage = 0.3;
end

field_noise_level = noise;
wG = abs(grad(iMag.*(Mask>0), voxel_size));
numerator = sum(wG(:)>field_noise_level);
denominator = nnz(Mask(:)==1);
if  (numerator/denominator)>percentage
    while (numerator/denominator)>percentage
        field_noise_level = field_noise_level*1.05;
        numerator = sum(wG(:)>field_noise_level);
    end
else
    while (numerator/denominator)<percentage
        field_noise_level = field_noise_level*.95;
        numerator = sum(wG(:)>field_noise_level);
    end
end

wG = (wG<=field_noise_level);