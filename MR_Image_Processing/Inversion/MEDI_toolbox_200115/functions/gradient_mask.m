% Generate the gradient weighting in MEDI
%   w=gradient_mask(gradient_weighting_mode, iMag, Mask, grad, voxel_size, percentage)
%
%   output
%   w - gradient weighting
%
%   input
%   gradient_weighting_mode - 1, binary weighting; other, reserved for
%                             grayscale weighting
%   iMag - the anatomical image
%   Mask - a binary 3D matrix denoting the Region Of Interest
%   grad - function that takes gradient
%   voxel_size - the size of a voxel
%   percentage(optional) - percentage of voxels considered to be edges.
%
%   Created by Ildar Khalidov in 20010
%   Modified by Tian Liu and Shuai Wang on 2011.03.28 add voxel_size in grad
%   Modified by Tian Liu on 2011.03.31
%   Last modified by Tian Liu on 2013.07.24

function [wG]=gradient_mask(iMag, Mask, grad, voxel_size, percentage, gradient_weighting_mode)

if nargin < 6
    gradient_weighting_mode = 1;
end

if nargin < 5
    percentage = 0.3;
end


if gradient_weighting_mode || percentage ~= 0


field_noise_level = 0.01*max(iMag(:));
epsilon_i = field_noise_level;
wG = abs(grad(iMag.*(Mask>0), voxel_size));
numerator = sum(wG(:)>field_noise_level);
denominator = sum(Mask(:)==1);
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
epsilon_f = field_noise_level;

else

wG = ones([size(Mask), 3]).*Mask; % Uniform weighting

end

