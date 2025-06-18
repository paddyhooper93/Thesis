function wG = gradient_mask_dynamic(iMag, Mask, grad, voxel_size, percentage)
%   w=gradient_mask(iMag, Mask, grad, voxel_size, percentage)
%
%   Inputs:
%   iMag - the anatomical image
%   Mask - a binary 3D matrix denoting the Region Of Interest
%   grad - function that takes gradient
%   voxel_size - the size of a voxel
%   percentage(optional) - percentage of voxels considered to be edges.
%
%   Created by Ildar Khalidov in 20010
%   Modified by Tian Liu and Shuai Wang on 2011.03.28 add voxel_size in grad
%   Modified by Tian Liu on 2011.03.31
%   Modified by Tian Liu on 2013.07.24
%
%   Modified by Paddy Hooper on 2025.01.08 (YYYY.MM.DD):
%   The functionality is exactly the same, but more informative to the user.
%   Now provides print statements to convey how the edge mask
%   threshold parameter (i.e. percentage) affects the field noise level.

if nargin < 5
    percentage = 0.9;
end

% fprintf('Target edge mask ratio: %.1f\n\n', percentage);

% Step 1: Calculate initial field noise level
field_noise_level = 0.01 * max(iMag(:));
% fprintf('Field noise level: %.1f\n\n a.u.', field_noise_level);

% Step 2: Compute magnitude gradient weighting
wG = abs(grad(iMag .* (Mask > 0), voxel_size));

% Step 3: Calculate numerator and denominator
numerator = sum(wG(:) > field_noise_level);  % Count of edge voxels
denominator = sum(Mask(:) == 1);             % Total number of voxels in the mask

% Step 4: Compute edge mask ratio
ratio = numerator / denominator;
% fprintf('Measured edge mask ratio: %.1f\n\n', ratio);


% Step 5: Adjust field noise level to match percentage
if (numerator / denominator) > percentage
    % fprintf('Field noise (DOWN), Edge Count (UP), to match: %.2f \n\n ', percentage);
    while (numerator / denominator) > percentage
        field_noise_level = field_noise_level * 1.05; % Field noise
        numerator = sum(wG(:) > field_noise_level); % Edge Count
    end
else
    % fprintf('Field noise (UP), Edge Count (DOWN), to match: %.2f \n\n ', percentage);
    while (numerator / denominator) < percentage
        field_noise_level = field_noise_level * 0.95;
        numerator = sum(wG(:) > field_noise_level);  % Count of edge voxels
    end
end

% Step 6: Apply threshold to gradient weighting
wG = (wG <= field_noise_level);
end
