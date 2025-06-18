function resampled_volumes = resample_volumes(volumes, old_voxel_size, new_voxel_size, interpMethod)

if nargin < 4
    interpMethod = 'linear';
end

% Get the number of volumes
num_volumes = size(volumes, 4);

% Calculate scaling factors
scaling_factors = old_voxel_size ./ new_voxel_size;

% Calculate new image dimensions
new_matrix_size = round(size(volumes, 1:3) .* scaling_factors);

% Initialize an array to store the resampled volumes
resampled_volumes = zeros([new_matrix_size num_volumes]); 

if ndims(volumes) == 4
    % Iterate over each volume
    for i = 1:num_volumes
        
        % Extract the current volume
        current_volume = volumes(:,:,:,i); 
        
        % Resample the current volume
        resampled_volumes(:,:,:,i) = resample_image(current_volume, old_voxel_size, new_voxel_size, interpMethod); 
    end

elseif ndims(volumes) == 3

    % Resample
    resampled_volumes = resample_image(volumes, old_voxel_size, new_voxel_size, interpMethod);

end


    function resampled_image = resample_image(image, old_voxel_size, new_voxel_size, interpMethod)

        % Calculate scaling factors
        scaling_factors = old_voxel_size ./ new_voxel_size;

        % Calculate new image dimensions
        new_matrix_size = round(size(image) .* scaling_factors);

        % Create a grid of coordinates for the original image
        % Meshgrid has size length(y0)-by-length(x0)-by-length(z0).
        [x, y, z] = meshgrid(1:size(image, 2), 1:size(image, 1), 1:size(image, 3));

        % Create a grid of coordinates for the resampled image
        new_x = linspace(1, size(image, 1), new_matrix_size(1));
        new_y = linspace(1, size(image, 2), new_matrix_size(2));
        new_z = linspace(1, size(image, 3), new_matrix_size(3));
        [new_x, new_y, new_z] = meshgrid(new_y, new_x, new_z);

        % Perform interpolation
        resampled_image = interp3(x, y, z, image, new_x, new_y, new_z, interpMethod);

    end

end