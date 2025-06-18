function [Data] = Obtain_COSMOS_Data(FS_str, num_orient, dir_COSMOS, type, flag_rmvstraw)

if nargin < 5
    flag_rmvstraw = false;
end

if matches(FS_str, '3T')
    % roi_labels = struct('Prll', 6, 'Perp', 5, 'Fe_L', 4, 'Fe_H', 2, 'Ca_L', 3, 'Ca_H', 1);
    roi_labels = struct('Prll', 6, 'Perp', 5, 'Fe_L', 4, 'Fe_H', 1, 'Ca_L', 2, 'Ca_H', 3);    
    ROI_fn = [FS_str, '_ROIs_Use.nii.gz'];
elseif matches(FS_str, '7T')
    roi_labels = struct('Prll', 6, 'Perp', 1, 'Fe_L', 5, 'Fe_H', 3, 'Ca_L', 2, 'Ca_H', 4);
    ROI_fn = [FS_str, '_ROIs_Erode1vox.nii.gz'];
end

dir_ROIs = 'C:\Users\rosly\Documents\Valerie_PH\ROIs';
ROI_nii = load_untouch_nii(fullfile(dir_ROIs, ROI_fn));
ROIs = single(ROI_nii.img);

chi_fn = fullfile(dir_COSMOS, [FS_str, '_chi_', type, '_', num2str(num_orient), '_Orient.nii.gz']);
chi_nii = load_untouch_nii(chi_fn);
chi = single(chi_nii.img);

if flag_rmvstraw
    roi_labels = rmfield(roi_labels, 'Prll');
    roi_labels = rmfield(roi_labels, 'Perp');
end


% Extract data for each region and assign data
fields = fieldnames(roi_labels);
Data = struct();

for f = 1:numel(fields)
    field_name = fields{f};
    roi_mask = (ROIs == roi_labels.(field_name));
    roi_values = chi(roi_mask);
    
    if ~isempty(roi_values)
        Data.(field_name) = mean(roi_values, 'omitnan');
    else
        Data.(field_name) = NaN;
    end
    
end
