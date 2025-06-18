function less_connected_mask = remove_small_regions(mask, min_size)
    % Ensure the input is a binary mask (values should be either 0 or 1)
    mask = mask > 0;

    % Find connected components in the binary mask using 3D connectivity
    CC = bwconncomp(mask, 6);  % 26-connectivity for 3D space

    % If no connected components exist, return an empty mask
    if CC.NumObjects == 0
        less_connected_mask = false(size(mask));
        return;
    end

    % Identify the sizes of all connected components
    component_sizes = cellfun(@numel, CC.PixelIdxList);

    % Create a mask that excludes small components
    less_connected_mask = false(size(mask));
    for i = 1:CC.NumObjects
        if component_sizes(i) >= min_size  % Only include components larger than the threshold
            less_connected_mask(CC.PixelIdxList{i}) = true;
        end
    end
end
