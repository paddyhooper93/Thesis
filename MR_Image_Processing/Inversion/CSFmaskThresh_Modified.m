function [CSF_Mask] = CSFmaskThresh_Modified(R2s, thresh_R2s, QSM_Mask, voxel_size)
%[ CSF_Mask ] = CSFmaskthresh_R2s(R2s, thresh_R2s, QSM_Mask)
%   Get the central CSF mask based on thresh_R2sold and QSM_Mask if available
%   Updated 2018-04-09, X.L. make it to handle bad R2* data
%  Ref: Liu et al., 2018 79(5):2795-2803

% Modifications P.H. 2025-01-08 (YYYY-MM-DD)
% Morphological erosion: 2 mm radius
% Morphological opening: 1 mm radius
% Remove disconnected voxels: < = 10 mm
% Use SEPIA function to get largest object from CSF mask

if nargin == 2
    QSM_Mask = ones(size(R2s));
    voxel_size = [1, 1, 1];
elseif nargin == 3
    voxel_size = [1, 1, 1];
end

% Get initial data Mask by thresh_R2solding
QSM_Mask = QSM_Mask > 0;
dataMask = (R2s < thresh_R2s).*QSM_Mask;     % Initial mask
dataMask = dataMask > 0;
CSF_Mask = zeros(size(dataMask));

% Set size of the Central region
CenterRegionRadius = [30, 30, 30];            % in mm
CenterRegionRadiusVoxel = floor(CenterRegionRadius ./ voxel_size);

% Further trim based on connectivity and centroid
% Get Centroid of Brain region
BrainCenter = regionprops(QSM_Mask, 'Centroid', 'Area');       % x, y, z

% In case QSM_Mask is discontinuous and there are more than one center
if size(BrainCenter, 1) > 1
    totalArea = 0;
    temp = zeros(size(BrainCenter(1).Centroid));
    
    for centerii = 1:size(BrainCenter, 1)
        temp = temp + (BrainCenter(centerii).Centroid) .* BrainCenter(centerii).Area;      % Weighted sum
        totalArea = totalArea + BrainCenter(centerii).Area;
    end
    BrainCenter = [];
    BrainCenter.Centroid = temp ./ totalArea;
end

% Get Central region mask
CenterRegion = zeros(size(R2s));
CenterRegion(floor(BrainCenter.Centroid(2) - CenterRegionRadiusVoxel(2)) : floor(BrainCenter.Centroid(2) + CenterRegionRadiusVoxel(2)), ...
    floor(BrainCenter.Centroid(1) - CenterRegionRadiusVoxel(1)) : floor(BrainCenter.Centroid(1) + CenterRegionRadiusVoxel(1)), ...
    floor(BrainCenter.Centroid(3) - CenterRegionRadiusVoxel(3)) : floor(BrainCenter.Centroid(3) + CenterRegionRadiusVoxel(3))) = 1;

% Get initial CSF mask in the Center (overlap between dataMask and CenterRegion)
CSF_Mask0 = CenterRegion & dataMask;
cc6mask = bwconncomp(CSF_Mask0, 26);
numPixels = cellfun(@numel, cc6mask.PixelIdxList);
[~, I] = sort(numPixels, 'descend');

% Pick the largest regions and combine
CSF_Mask0 = zeros(size(dataMask));
numRegionComb = 3;      % 2 or 3
for iiRegion = 1:numRegionComb
    CSF_Mask0(cc6mask.PixelIdxList{I(iiRegion)}) = 1;
end

% Extend to connected regions (use overlap of 10)
CONN = 26;
cc6mask = bwconncomp(dataMask, CONN);
numPixels = cellfun(@numel, cc6mask.PixelIdxList);
[~, I] = sort(numPixels, 'descend');

for iiRegion = 1:cc6mask.NumObjects
    if sum(CSF_Mask0(cc6mask.PixelIdxList{I(iiRegion)})) > 0
        CSF_Mask(cc6mask.PixelIdxList{I(iiRegion)}) = 1;
    end
end

% % Remove regions with less than the thresh_R2sold number of pixels
% pixel_count_thresh_R2sold = 0;
% I = find(numPixels >= pixel_count_thresh_R2sold);
%
% % Create mask for large enough connected regions
% CSF_Mask = zeros(size(dataMask));
% for iiRegion = 1:length(I)
%     CSF_Mask(cc6mask.PixelIdxList{I(iiRegion)}) = 1;
% end


% Morphological erosion: 2 mm radius
% Morphological opening: 1 mm radius
% Remove disconnected voxels: < = 10 mm
% Use SEPIA function to get largest object from CSF mask

% Morphological erosion
erode_radius_voxel = min(round(2 ./ voxel_size)); % 2 mm
CSF_Mask = imerode(CSF_Mask,strel('sphere', double(erode_radius_voxel)));
% Morphological opening
open_radius_voxel   = min(round(1 ./ voxel_size)); % 1 mm
CSF_Mask = imopen(CSF_Mask, strel('sphere', double(open_radius_voxel)));
% Remove disconnected voxels: < = 10 mm
num_neighbors_voxel = min(round(10 ./ voxel_size)); % 10 mm
CSF_Mask = rmv_less_connected_voxels(CSF_Mask, double(num_neighbors_voxel));
% Use SEPIA function to get largest object, conn = 26
CSF_Mask = getLargestObject(CSF_Mask, 26);

end