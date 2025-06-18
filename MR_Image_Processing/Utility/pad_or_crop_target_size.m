function [new_img] = pad_or_crop_target_size(img, voxel_size, FOV)
%% Works for both 3D and 4D images

% Define the target size based on the dataset type
if nargin < 3
    FOV=[210, 240, 192];
end

matrixSize_o = size(img);
mode = 'pre';
img = zeropad_odd_dimension(img,mode,matrixSize_o);

% T: "Target matrix size"
T =  floor(FOV ./ (max(voxel_size)));
% Check if each element is odd and add 1 to make it even
T(mod(T, 2) == 1) = T(mod(T, 2) == 1) + 1;
dims = size( img );

if ndims( img ) == 4 % 4D images
    
    if dims(1) < T(1)
        img = padarray(img, [round(T(1) - dims(1))/2, 0, 0, 0], 0, 'both');
    end
    
    if dims(2) < T(2)
        img = padarray(img, [0, round(T(2) - dims(2))/2, 0, 0], 0, 'both');
    end
    
    if dims(3) < T(3)
        img = padarray(img, [0, 0, round(T(3) - dims(3))/2, 0], 0, 'both');
    end
    
    if dims(1) > T(1)
        crop_start = floor((dims(1) - T(1)) / 2) + 1;
        crop_end = crop_start + T(1) - 1;
        img = img(crop_start:crop_end, :, :, :);
    end
    
    if dims(2) > T(2)
        crop_start = floor((dims(2) - T(2)) / 2) + 1;
        crop_end = crop_start + T(2) - 1;
        img = img(:, crop_start:crop_end, :, :);
    end
    
    if dims(3) > T(3)
        crop_start = floor((dims(3) - T(3)) / 2) + 1;
        crop_end = crop_start + T(3) - 1;
        img = img(:, :, crop_start:crop_end, :);
    end
    
elseif ndims( img ) == 3 % 3D images
    
    if dims(1) < T(1)
        img = padarray(img, [round(T(1) - dims(1))/2, 0, 0], 0, 'both');
    end
    
    if dims(2) < T(2)
        img = padarray(img, [0, round(T(2) - dims(2))/2, 0], 0, 'both');
    end
    
    if dims(3) < T(3)
        img = padarray(img, [0, 0, round(T(3) - dims(3))/2], 0, 'both');
    end
    
    if dims(1) > T(1)
        crop_start = floor((dims(1) - T(1)) / 2) + 1;
        crop_end = crop_start + T(1) - 1;
        img = img(crop_start:crop_end, :, :);
    end
    
    if dims(2) > T(2)
        crop_start = floor((dims(2) - T(2)) / 2) + 1;
        crop_end = crop_start + T(2) - 1;
        img = img(:, crop_start:crop_end, :);
    end
    
    if dims(3) > T(3)
        crop_start = floor((dims(3) - T(3)) / 2) + 1;
        crop_end = crop_start + T(3) - 1;
        img = img(:, :, crop_start:crop_end);
    end
    
end


img = zeropad_odd_dimension(img,mode,matrixSize_o);
new_img = single(img);
end