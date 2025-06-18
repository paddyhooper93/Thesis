function [InfCyl] = Obtain_InfCyl_Data(FS_str, num_orient, dir_Delta)
% -----------------------------------------------------
% Input vars
% FS_str = '3T' or '7T'
% num_orient = 6
% dir_COSMOS = directory containing inputVars MAT file

if matches(FS_str, '3T')
    roi_labels = struct('Prll', 6, 'Perp', 5);
    ROI_fn = [FS_str, '_ROIs_Old.nii.gz']; % _Old _Use
    vsz = [1 1 1];
    prll_init = deg2rad(6);
    perp_init = deg2rad(-1);
elseif matches(FS_str, '7T')
    roi_labels = struct('Prll', 6, 'Perp', 1);
    ROI_fn = [FS_str, '_ROIs_Exclude.nii.gz']; % Erode1vox
    vsz = [.75 .75 .75];
    prll_init = deg2rad(5);
    perp_init = deg2rad(-1);
end

load_fn = fullfile(dir_Delta, [FS_str, '_COSMOS_', num2str(num_orient), '_inputVars.mat']);
load(load_fn, 'B', 'M', 'R_tot');

B = pad_or_crop_target_size(B, vsz);
M = pad_or_crop_target_size(M, vsz);

% -----------------------------------------------------
% Loaded vars
% B: Local field in dimensionless units (scaled to ppm from Hz) by dividing by (gamma * B0);
% M: Brain ROI Mask: excluding erroneous voxels for analysis
% R_tot: rotation matrix
[~, ~, Theta_B0] = ObtainRotationAngles(R_tot, num_orient);

chi_prll = zeros(size(B));
chi_perp = zeros(size(B));

for i = 1:num_orient
    % if i == 1
        % Inf.Cyl.Model (theta = 0 radians): chi_prll
        % chi_prll_tmp = 3 * B(:,:,:,i);
        % Inf.Cyl.Model (theta = pi/2 radians): chi_perp
        % chi_perp_tmp = -6 * B(:,:,:,i);
    % else
        chi_prll_tmp = 6 / (3*cos(prll_init + Theta_B0(i))^2 - 1) * B(:,:,:,i);
        chi_perp_tmp = 6 / (3*cos(perp_init + pi/2 + Theta_B0(i) )^2 - 1) * B(:,:,:,i);
    % end

    % Correct for NaCl susceptibility in bulk medium
    chi_prll(:,:,:,i) = (chi_prll_tmp - 0.1106) .* M;
    chi_perp(:,:,:,i) = (chi_perp_tmp - 0.1106) .* M;
end

dir_ROIs = 'C:\Users\rosly\Documents\Valerie_PH\ROIs';
ROI_nii = load_untouch_nii(fullfile(dir_ROIs, ROI_fn));
ROIs = single(ROI_nii.img);

[InfCyl] = Extract_ROI_Data(roi_labels, chi_prll, chi_perp);


    function [Data] = Extract_ROI_Data(roi_labels, chi_prll, chi_perp)
        
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
                chi_prll_values = chi_prll(:,:,:,t);
                chi_perp_values = chi_perp(:,:,:,t);
                if matches(field_name, 'Prll')
                    roi_values = chi_prll_values(roi_mask);
                elseif matches(field_name, 'Perp')
                    roi_values = chi_perp_values(roi_mask);
                end
                
                if ~isempty(roi_values)
                    Data.(orient_label).(field_name) = mean(roi_values, 'omitnan');
                else
                    Data.(orient_label).(field_name) = NaN;
                end
                
            end
        end
        
    end


end