function less_connected_mask = rmv_less_connected_voxels(mask, threshold)
% Remove less connected voxels, num_neighbors <= 10

if nargin == 1
    threshold = 10;
end

% Ensure the input is a binary mask (values should be either 0 or 1)
mask = mask > 0;

% Get the size of the mask
[x_size, y_size, z_size] = size(mask);

% Initialize the new mask
less_connected_mask = mask;

% Iterate through each voxel in the mask
for x = 2:x_size-1  % Avoid edges
    for y = 2:y_size-1
        for z = 2:z_size-1
            % Skip background voxels
            if mask(x, y, z) == 0
                continue;
            end
            
            % Count the number of neighbors
            neighbors = mask(x-1:x+1, y-1:y+1, z-1:z+1);
            num_neighbors = sum(neighbors(:)) - 1;  % Subtract self voxel
            
            % If num_neighbors is less than or equal to threshold, remove it
            if num_neighbors <= threshold
                less_connected_mask(x, y, z) = 0;
            end
        end
    end
end
end