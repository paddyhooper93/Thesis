function [new_img] = apply_padding(img, voxel_size)

% Define the target size based on the dataset type
    FOV=[210, 240, 192];
    target =  FOV ./ (max(voxel_size));
    [xx, yy, zz] = size( img, [1,2,3] );

    if xx > target(1) || yy > target(2) || zz > target(3)
        new_img = crop_image_space(img, target_size);
    end

    if xx < target(1) || yy < target(2) || zz < target(3)
        new_img = padarray(img, [(target(1) - xx)/2, (target(2) - yy)/2, (target(3) - zz)/2], 0, 'both');
    end
end