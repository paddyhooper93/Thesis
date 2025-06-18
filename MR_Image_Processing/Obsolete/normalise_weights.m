function weights = normalise_weights(weights,mask)
% Uses Steps 2-4 of sepia_utils_compute_weights_v1.m in SEPIA Toolbox
% Excludes inversion of fieldMapSD (Step 1)

% Get all masked data
weights_1d = weights(mask>0);

%% Step 2: Normalisation
% get stats
iqr_mask    = iqr(weights_1d);
median_mask = median(weights_1d);

% the histogram of the weights is usually negatively skewed, so median +3*IQR should be safe
% for the right side of the distribution
weights_1d = weights_1d./(median_mask + 3*iqr_mask);
% weights_1d(weights_1d>1) = 1;
% % weights                 = weights./max(weights(mask>0));

%% Step 3: Re-centre
weights_1d = weights_1d - median(weights_1d) + 1;

% put the normalised weights back to image
weights(mask>0) = weights_1d;

%% Step 4: Handle outliers on the right hand side of the histogram
% TODO 20220223: could provide this as option in the future
iqr_mask    = iqr(weights_1d);
median_mask = median(weights_1d);
threshold   = median_mask + 3*iqr_mask;

% use median to filter outliers
% weights_filter = medfilt3(weights.*mask,[3, 3, 3]);
% weights_filter = imgaussfilt3(weights.*mask);
weights_filter = smooth3(weights.*mask); % 3x3x3 smoothing
% avoid introducing zero on the boundary, better to be a bit conservative here
weights_filter(weights_filter == 0) = weights(weights_filter == 0);
weights_final = weights;
% replace outliers by median
weights_final(weights>threshold) = weights_filter(weights>threshold);

weights = weights_final;

end