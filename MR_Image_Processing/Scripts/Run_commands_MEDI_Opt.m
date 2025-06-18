%% Run_commands_MEDI_Opt

clearvars; close all
pc_range = 0.9:-0.05:0.3;
epsilon_f = zeros(size(pc_range));


for dataset = {'3T_Neutral', '7T_Neutral'} % , '7T_Neutral'
input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\SNRwAVG_PDF';
workspace_fn = fullfile(input_dir, [dataset{1}, '_workspace.mat']);
load(workspace_fn, "weights", "RDF", "hdr" )
output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\MEDI_Opt';
%iMag = pad_or_crop_target_size(hdr.iMag, hdr.voxel_size, hdr.FOV);
magn_dir='C:\Users\rosly\Documents\Valerie_PH\Data\Padded\N4_deGibbs';
magn_fn = fullfile(magn_dir, [dataset{1}, '_Magn.nii.gz']);
magn_nii = load_untouch_nii(magn_fn);
magn = pad_or_crop_target_size(magn_nii.img, hdr.voxel_size);
Mask = pad_or_crop_target_size(hdr.BET_Mask, hdr.voxel_size);
if contains(dataset{1}, '3T')
    Mask = imerode(Mask, strel('sphere', 2));
end


export_nii(pad_or_crop_target_size(Mask,hdr.voxel_size), fullfile(output_dir, [dataset{1}, '_Mask_Use']), hdr.voxel_size);

iMag = sqrt(sum(abs(magn).^2,4)) .* Mask;


for idx = 1:length(pc_range)

param = pc_range(idx);
% Mask = hdr.Mask_Use;
grad = @fgrad;
[~, epsilon_i, tmp]=gradient_mask(iMag, Mask, grad, hdr.voxel_size, param);
epsilon_f(idx) = tmp;

% hdr.noDipoleInversion = false; 
% hdr.lambda = 1000; hdr.lam_CSF = 100; hdr.isSMV = true; hdr.radius = 3; hdr.useQualityMask = false;
% hdr.percentage = i;
% hdr.QSM_Prefix = ['QSM_SMV3_Pc', num2str(i)]; 
% DipoleInversion(weights, RDF, hdr);

end

    if contains(dataset{1}, '3T')
        epsilon_target = 110.0;
    else
        epsilon_target = 94.6;
    end

% use linear interpolation to obtain the optimal parameter
interp = 'linear';
paramInterp = linspace(min(pc_range),max(pc_range),1000);
paramCostInterp = interp1(gather(pc_range),gather(epsilon_f),gather(paramInterp),interp);


% Calculate absolute differences and find the index of the minimum difference
[~, idx_interp] = min(abs(paramCostInterp - epsilon_target));
[~, idx_opt] = min(abs(epsilon_f - epsilon_target));

% idx now holds the index of the element closest to the target
pc_opt = pc_range(idx_opt);
fprintf('\n Optimal pc: %.2f , closest to index: %d \n', pc_opt, idx_opt);
epsilon_interp = paramCostInterp(idx_interp);
pc_interp = paramInterp(idx_interp);

save_fn = fullfile(output_dir, [dataset{1}, '_Pc_Cost.mat']);
save(save_fn, "epsilon_f", "epsilon_i", "idx_opt", "pc_opt", "epsilon_interp", "pc_interp");

end