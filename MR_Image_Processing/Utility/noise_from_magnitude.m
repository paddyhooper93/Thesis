function [mask] = noise_from_magnitude(magn_e1, thresh, open_radius)
mask_thresh=(magn_e1<thresh) .* (magn_e1>0);
mask_conn=getLargestObject(mask_thresh, 6);
mask=imopen(mask_conn, strel('sphere', open_radius));