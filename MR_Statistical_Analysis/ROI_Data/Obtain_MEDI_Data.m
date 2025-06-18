function [Data] = Obtain_MEDI_Data(FS_str, num_orient, dir_MEDI, QSM_fn, flag_rmvstraw)

if nargin < 4
    QSM_fn = 'QSM_Default_FLIRT';
end

if nargin < 5
    flag_rmvstraw = false;
end
fn1 = [FS_str, '_Neutral'];
if matches(FS_str, '3T')
    Registered = {'3T_Rot1', '3T_Rot2', '3T_Rot3', '3T_Rot5', '3T_Rot6'};
    ROI_fn = [FS_str, '_ROIs_Use.nii.gz'];
    fn2='';
elseif matches(FS_str, '7T')
    Registered = {'7T_Rot1', '7T_Rot2', '7T_Rot3', '7T_Rot4', '7T_Rot5'};
    ROI_fn = [FS_str, '_ROIs_Erode1vox.nii.gz'];
    fn2 = '_to_Rot6';
end
    fn = fullfile(dir_MEDI, [fn1, fn2, '_', QSM_fn, '.nii.gz']);
    nii = load_untouch_nii(fn);
    chi = nii.img;

dir_ROIs = 'C:\Users\rosly\Documents\Valerie_PH\ROIs';
ROI_nii = load_untouch_nii(fullfile(dir_ROIs, ROI_fn));
ROIs = single(ROI_nii.img);

for dataset = Registered
    fn = fullfile(dir_MEDI, [fn1, '_to_', dataset{1}(4:7), '_', QSM_fn, '.nii.gz']);
    nii = load_untouch_nii(fn);
    chi = cat(4, chi, nii.img);
end


% chi_fn = fullfile(dir_COSMOS, [FS_str, '_chi_MEDI_', num2str(num_orient), '_Orient_30pc.nii.gz']);
% chi_nii = load_untouch_nii(chi_fn);
% chi = single(chi_nii.img);



if matches(FS_str, '3T')
    % roi_labels = struct('Prll', 6, 'Perp', 5, 'Fe_L', 4, 'Fe_H', 2, 'Ca_L', 3, 'Ca_H', 1);
    roi_labels = struct('Prll', 6, 'Perp', 5, 'Fe_L', 4, 'Fe_H', 1, 'Ca_L', 2, 'Ca_H', 3);    
elseif matches(FS_str, '7T')
    roi_labels = struct('Prll', 6, 'Perp', 1, 'Fe_L', 5, 'Fe_H', 3, 'Ca_L', 2, 'Ca_H', 4);
end

if flag_rmvstraw
    roi_labels = rmfield(roi_labels, 'Prll');
    roi_labels = rmfield(roi_labels, 'Perp');
end


% Extract data for each region and assign data
fields = fieldnames(roi_labels);
Data = struct();

for t = 1:num_orient
    orient_label = ['Orient_', num2str(t)];
    Data.(orient_label) = struct();
    
    for f = 1:numel(fields)
        field_name = fields{f};
        roi_mask = (ROIs == roi_labels.(field_name));
        
        % Extract the susceptibility values within the mask
        chi_values = chi(:,:,:,t);
        roi_values = chi_values(roi_mask);
        
        if ~isempty(roi_values)
            Data.(orient_label).(field_name) = mean(roi_values, 'omitnan');
        else
            Data.(orient_label).(field_name) = NaN;
        end
        
    end
end

%for f = 1:numel(fields);
%    field_name = fields{f};
%    roi_mask = (ROIs == roi_labels.(field_name));
%    for t = 1:size(chi, 4)
%        Data.field_name.(['chi_' num2str(t)]) = chi(:,:,:,t) .* roi_mask;
%
%    end
%end