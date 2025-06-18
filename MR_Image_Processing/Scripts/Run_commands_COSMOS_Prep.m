%function Run_commands_COSMOS_Prep()
% '3T_Neutral', '3T_Rot1', '3T_Rot2', '3T_Rot3', '3T_Rot5', '3T_Rot6', ...
% '7T_Rot1', '7T_Rot2', '7T_Rot3', '7T_Rot4', '7T_Rot5', '7T_Rot6'

% InitiateParallelComputing();

%% COSMOS Recon

clearvars
close all
input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\COSMOS_SNRwAVG_PDF';
FS_str = '3T';
for num_orient = 4:6
    Wrapper_COSMOS_Recon(num_orient, input_dir, FS_str, 1);
end




%% MEDI Recon

for dataset = {'7T_Neutral'}

fprintf('\n Processing dataset: %s \n', dataset{1});

    input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\SNRwAVG_PDF';    
    workspace_fn = fullfile(input_dir, [dataset{1}, '_workspace.mat']);
    load(workspace_fn, "weights", "RDF", "hdr" )
    magn_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\N4_deGibbs';
    magn_fn = fullfile(magn_dir, [dataset{1}, '_Magn.nii.gz']);
    magn_nii = load_untouch_nii(magn_fn);
    magn = pad_or_crop_target_size(magn_nii.img, hdr.voxel_size);
    hdr.iMag = magn(:,:,:,1);
    
    hdr.noDipoleInversion = false;
    hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\MEDI';
    hdr.QSM_Prefix = 'QSM';
    hdr.useQualityMask = true; 
    hdr.isSMV = false; 
    hdr.isMerit = false;
    hdr.isCSF = false;
    hdr.percentage = 0.3;

    if contains(dataset{1}, '3T')
        hdr.lambda = 10^(4);
    elseif contains(dataset{1}, '7T')
        hdr.lambda = 10^(4.25);
    end    

    clear magn magn_nii
    hdr = rmfield(hdr, 'BET_Mask');
    hdr = rmfield(hdr, 'fieldMapSD');
    hdr = rmfield(hdr, 'iFreq');
    hdr = rmfield(hdr, 'relativeResidualMask');
    hdr = rmfield(hdr, 'R2s');
    hdr = rmfield(hdr, 'Mask_Use');

    [c_d_m, c_r_m, hdr] = DipoleInversion(weights, RDF, hdr);

        save(fullfile(hdr.output_dir, [hdr.dataset, '_Cost.mat']), ...
    "c_r_m", "c_d_m");
end


%% MEDI0 Recon

clearvars; close all
for dataset = {'7T_Neutral'}

fprintf('\n Processing dataset: %s \n', dataset{1});

    input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\SNRwAVG_PDF';    
    workspace_fn = fullfile(input_dir, [dataset{1}, '_workspace.mat']);
    load(workspace_fn, "weights", "RDF", "hdr" )
    % magn_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Noise_Level';
    magn_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\N4_deGibbs';
    magn_fn = fullfile(magn_dir, [dataset{1}, '_Magn.nii.gz']);
    magn_nii = load_untouch_nii(magn_fn);
    magn = pad_or_crop_target_size(magn_nii.img, hdr.voxel_size);
    hdr.iMag = magn(:,:,:,1);
    clear magn magn_nii
    hdr.noDipoleInversion = false;
    hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\MEDI0';
    hdr.QSM_Prefix = 'QSM0';
    hdr.useQualityMask = true; 
    hdr.isSMV = false; 
    hdr.isMerit = false;
    hdr.isCSF = true; 
    hdr.percentage = 0.3;

    if contains(dataset{1}, '3T')
        hdr.lambda = 10^(4.25);
    elseif contains(dataset{1}, '7T')
        hdr.lambda = 10^(4.5);
    end    

    hdr.lam_CSF = 10^1;
    
    clear magn magn_nii
    hdr = rmfield(hdr, 'BET_Mask');
    hdr = rmfield(hdr, 'fieldMapSD');
    hdr = rmfield(hdr, 'iFreq');
    hdr = rmfield(hdr, 'relativeResidualMask');
    hdr = rmfield(hdr, 'R2s');
    hdr = rmfield(hdr, 'Mask_Use');

    [c_d_m, c_r_m, hdr] = DipoleInversion(weights, RDF, hdr);

        save(fullfile(hdr.output_dir, [hdr.dataset, '_Cost.mat']), ...
    "c_r_m", "c_d_m");
end



%% MEDI_lam-range 
InitiateParallelComputing();
maxNumCompThreads(feature('numcores'));
lam_range = [10^5, 10^4.75, 10^4.5, 10^4.25, 10^4 ];
datasets = {'7T_Rot5', '7T_Rot4', '3T_Rot5', '3T_Rot3'};
for datasetIndex = 1:length(datasets) % Iterate using indices
    datasetName = datasets{datasetIndex};
    fprintf('\n Processing dataset: %s \n', datasetName);

    input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\SNRwAVG_PDF';    
    workspace_fn = fullfile(input_dir, [datasetName, '_workspace.mat']);

    if contains(datasetName, '3T')
        voxel_size = [1 1 1];
    elseif contains(datasetName, '7T')
        voxel_size = [.75 .75 .75];
    end        
    
    magn_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\N4_deGibbs';
    magn_fn = fullfile(magn_dir, [datasetName, '_Magn.nii.gz']);
    magn_nii = load_untouch_nii(magn_fn);
    magn = pad_or_crop_target_size(magn_nii.img, voxel_size);
    magn = magn(:,:,:,1);

    clear magn_nii;
    output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\MEDI_Lam-range';
    
    c_d_m = zeros(size(lam_range));
    c_r_m = zeros(size(lam_range));
    formatSpec = '%5.0f';
    for idx = 1:length(lam_range)
        [S] = load(workspace_fn, "weights", "RDF", "hdr" );
        weights = S.weights;
        RDF = S.RDF;
        hdr = S.hdr;
        hdr.noDipoleInversion = false;
        hdr.output_dir = output_dir;
        hdr.useQualityMask = true; 
        hdr.isSMV = false; 
        hdr.isMerit = false;
        hdr.isCSF = false;
        hdr.percentage = 0.3;
        hdr.iMag = magn;        
        hdr.lambda = lam_range(idx);
        hdr.QSM_Prefix = ['QSM_Lambda', num2str(hdr.lambda, formatSpec)];
        [c_d_m(idx), c_r_m(idx), hdr] = DipoleInversion(weights, RDF, hdr);
    end    

    s = struct("c_r_m", c_r_m, "c_d_m", c_d_m);
    save(fullfile(output_dir, [datasetName, '_Cost.mat']), ...
        '-fromstruct', s);

    clear weights RDF
end
delete(pool);
clearvars; close all

%% MEDI_pc-range
clearvars; close all
pc_range = [0.9, 0.7, 0.5, 0.3, 0.1];
for dataset = {'3T_Rot5', '7T_Rot5'}

fprintf('\n Processing dataset: %s \n', dataset{1});

    input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\SNRwAVG_PDF';    
    workspace_fn = fullfile(input_dir, [dataset{1}, '_workspace.mat']);
    load(workspace_fn, "weights", "RDF", "hdr" )
    magn_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\N4_deGibbs';
    magn_fn = fullfile(magn_dir, [dataset{1}, '_Magn.nii.gz']);
    magn_nii = load_untouch_nii(magn_fn);
    magn = pad_or_crop_target_size(magn_nii.img, hdr.voxel_size);
    hdr.iMag = magn(:,:,:,1);
    hdr.noDipoleInversion = false;
    hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\DiscPrinc_2\MEDI_pc-range';
    hdr.useQualityMask = false; 
    hdr.isSMV = false; 
    hdr.isMerit = false;
    hdr.isCSF = false;

    if contains(dataset{1}, '3T')
        hdr.lambda = 9.41e3;
    elseif contains(dataset{1}, '7T')
        hdr.lambda = 1.78e4;
    end    

    c_d_m = zeros(size(pc_range));
    c_r_m = zeros(size(pc_range));
    formatSpec = '%5.1f';
    for idx = 1:length(pc_range)
        hdr.percentage = pc_range(idx);
        hdr.QSM_Prefix = ['QSM_Pc', num2str(hdr.percentage, formatSpec)];
        [c_d_m, c_r_m, hdr] = DipoleInversion(weights, RDF, hdr);
    end    


        save(fullfile(hdr.output_dir, [hdr.dataset, '_Cost.mat']), ...
    "c_r_m", "c_d_m");
 
end


%% MEDI0_lam-range


clearvars; close all
% lam_range = [10^2, 10^2.5, 10^3, 10^3.5, 10^4, 10^4.5];
lam_range = 10^4.5;
for dataset = {'7T_Rot5'}

    fprintf('\n Processing dataset: %s \n', dataset{1});

    input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\SNRwAVG_PDF';    
    workspace_fn = fullfile(input_dir, [dataset{1}, '_workspace.mat']);
    load(workspace_fn, "weights", "RDF", "hdr" )
    magn_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Noise_Level';
    magn_fn = fullfile(magn_dir, [dataset{1}, '_Magn.nii.gz']);
    magn_nii = load_untouch_nii(magn_fn);
    magn = pad_or_crop_target_size(magn_nii.img, hdr.voxel_size);
    magn = magn(:,:,:,1);
    hdr.iMag = sqrt(sum(magn.^2,4));    hdr.noDipoleInversion = false;
    hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\DiscPrinc_2\MEDI0_lam-range';
    hdr.QSM_Prefix = 'QSM_Default';
    hdr.useQualityMask = true; 
    hdr.isSMV = false; hdr.percentage = 0.5; 
    hdr.isCSF = true; hdr.lam_CSF = 10^2;
    hdr.isMerit = false;

    c = zeros(size(lam_range));
    c_s = zeros(size(lam_range));
    c_roi = zeros(size(lam_range));
    c_s_roi = zeros(size(lam_range));
    c_d_m = zeros(size(lam_range));
    c_nl = zeros(size(lam_range));
    c_nl_roi = zeros(size(lam_range));
    formatSpec = '%5.0f';
    for idx = 1:length(lam_range)
        hdr.lambda = lam_range(idx);
        hdr.QSM_Prefix = ['QSM_Lambda', num2str(hdr.lambda, formatSpec)];
        [c(idx), c_s(idx), c_roi(idx), c_s_roi(idx), c_nl(idx), c_nl_roi(idx), c_d_m(idx), hdr] = DipoleInversion(weights, RDF, hdr);
    end    

    save(fullfile(hdr.output_dir, [hdr.dataset, '_Lam_Cost.mat']), ...
    "c", "c_s", "c_roi", "c_s_roi", "c_nl", "c_nl_roi", "c_d_m");
 
end


%% MEDI_lamcsf-range

clearvars; close all
lamcsf_range = logspace(0.5, 2.5, 15);
for dataset = {'7T_Rot5','3T_Rot5'}

    fprintf('\n Processing dataset: %s \n', dataset{1});

    input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\SNRwAVG_PDF';    
    workspace_fn = fullfile(input_dir, [dataset{1}, '_workspace.mat']);
    load(workspace_fn, "weights", "RDF", "hdr" )
    magn_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Noise_Level';
    magn_fn = fullfile(magn_dir, [dataset{1}, '_Magn.nii.gz']);
    magn_nii = load_untouch_nii(magn_fn);
    magn = pad_or_crop_target_size(magn_nii.img, hdr.voxel_size);
    magn = magn(:,:,:,1);
    hdr.iMag = sqrt(sum(magn.^2,4));
    hdr.noDipoleInversion = false;
    hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\MEDI_lamcsf-range';
    hdr.useQualityMask = false; 
    hdr.isSMV = false; hdr.percentage = 0.3; 
    hdr.isMerit = false;

    if contains(dataset{1}, '3T')
        hdr.lambda = 2.09e4;
    elseif contains(dataset{1}, '7T')
        hdr.lambda = 2.44e4;
    end        

    c_d_m = zeros(size(lamcsf_range));
    c_r_m = zeros(size(lamcsf_range));
    formatSpec = '%5.0f';
    for idx = 1:length(lamcsf_range)
        hdr.lam_CSF = lamcsf_range(idx);
        hdr.QSM_Prefix = ['QSM_lam_CSF', num2str(hdr.lam_CSF, formatSpec)];
        [c_d_m(idx), c_r_m(idx), hdr] = DipoleInversion(weights, RDF, hdr);
    end    

    save(fullfile(hdr.output_dir, [hdr.dataset, '_Lam_CSF_Cost.mat']), ...
   "c_r_m", "c_d_m");


    % Optimal param using largest curvature on log-log L-curve
    % find Kappa (largest curvature) 
    rho = log(cost_data.^2);
    eta = log(cost_reg.^2);
    % First derivatives w.r.t. parameter
    drho = myDerivative(rho, param);
    deta = myDerivative(eta, param);
    % Second derivatives w.r.t. parameter
    d2rho = myDerivative(drho, param);
    d2eta = myDerivative(deta, param);
    % Eq. 19 of Bilgic et al. MRM 72:1444-1459 (2014)
    kappa = (d2rho.*deta - d2eta.*drho) ./ (drho.^2 + deta.^2) .^ 1.5;
    % use spline interpolation to obtain finer resolution of the curvature
    interp = 'spline';
    paramInterp = linspace(min(param),max(param),1000);
    paramkappaInterp = interp1(gather(param),gather(kappa),gather(paramInterp),interp);
    % find maximum curvature (kappa)
    [~, I] = sort(paramkappaInterp,'descend');
    paramOpt_LCurve = paramInterp(I(1));
    % Calculate absolute differences and find the index of the minimum difference
    [~, idx_LCurve] = min(abs(cost_data - paramOpt_LCurve));

    fprintf('\n Optimal param (L-Curve) closest to index: %d \n ', idx);
        figure(40), subplot(1,2,1), semilogx(c_d_m, c_r_m, 'Marker', '*'), ...
        title('L-curve'), xlabel('Data consistency cost'), ylabel('Regularization cost')
        subplot(1,2,2), semilogx(paramInterp, paramkappaInterp, 'Marker', '*'), ...
        title('Curvature'), xlabel('Lambda\_CSF'), ylabel('Curvature')
        drawnow; % Force figure update
        saveas(gcf,[FS, '_', num2str(idx_dir), '_lam-csf_L-Curve.png']);

end


%% MEDI-SMV3_lam-range

clearvars; close all
lam_range = [10^2, 10^2.5, 10^3, 10^3.5, 10^4, 10^4.5];
for dataset = {'3T_Rot3', '3T_Rot6', '7T_Rot4', '7T_Rot5'}

fprintf('\n Processing dataset: %s \n', dataset{1});

    input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\SNRwAVG_PDF';    
    workspace_fn = fullfile(input_dir, [dataset{1}, '_workspace.mat']);
    load(workspace_fn, "weights", "RDF", "hdr" )
    hdr.noDipoleInversion = false;
    magn_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Noise_Level';
    magn_fn = fullfile(magn_dir, [dataset{1}, '_Magn.nii.gz']);
    magn_nii = load_untouch_nii(magn_fn);
    magn = pad_or_crop_target_size(magn_nii.img, hdr.voxel_size);
    magn = magn(:,:,:,1);
    hdr.iMag = sqrt(sum(magn.^2,4));
    hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\DiscPrinc_2\MEDI-SMV3_lam-range';
    hdr.useQualityMask = false; 
    hdr.isSMV = true;
    hdr.radius = 3; hdr.percentage = 0.9;
    hdr.isCSF = false;
    hdr.isMerit = false;

    c = zeros(size(lam_range));
    c_s = zeros(size(lam_range));
    c_roi = zeros(size(lam_range));
    c_s_roi = zeros(size(lam_range));
    c_d_m = zeros(size(lam_range));
    c_nl = zeros(size(lam_range));
    c_nl_roi = zeros(size(lam_range));
    formatSpec = '%5.0f';
    for idx = 1:length(lam_range)
        hdr.lambda = lam_range(idx);
        hdr.QSM_Prefix = ['QSM_Lambda', num2str(hdr.lambda, formatSpec)];
        [c(idx), c_s(idx), c_roi(idx), c_s_roi(idx), c_nl(idx), c_nl_roi(idx), c_d_m(idx), hdr] = DipoleInversion(weights, RDF, hdr);
    end    


    save(fullfile(hdr.output_dir, [dataset{1}, '_SMV3_Lam_Cost.mat']), ...
    "c", "c_s", "c_roi", "c_s_roi", "c_nl", "c_nl_roi", "c_d_m");

end



%% MEDI0-SMV3_lam-range

clearvars; close all
lamcsf_range = [10^1, 10^1.5, 10^2, 10^2.5, 10^3];
for dataset = {'3T_Rot5', '7T_Rot5'}

    fprintf('\n Processing dataset: %s \n', dataset{1});

    input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\SNRwAVG_PDF';    
    workspace_fn = fullfile(input_dir, [dataset{1}, '_workspace.mat']);
    load(workspace_fn, "weights", "RDF", "hdr" )
    hdr.noDipoleInversion = false;
    magn_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Noise_Level';
    magn_fn = fullfile(magn_dir, [dataset{1}, '_Magn.nii.gz']);
    magn_nii = load_untouch_nii(magn_fn);
    magn = pad_or_crop_target_size(magn_nii.img, hdr.voxel_size);
    magn = magn(:,:,:,1);
    hdr.iMag = sqrt(sum(magn.^2,4));
    hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\DiscPrinc_2\MEDI0-SMV3_lamcsf-range';
    hdr.useQualityMask = false; 
    hdr.isSMV = true; hdr.radius = 3; hdr.percentage = 0.5; hdr.lambda = 1000;
    hdr.isMerit = false;

    c = zeros(size(lamcsf_range));
    c_s = zeros(size(lamcsf_range));
    c_roi = zeros(size(lamcsf_range));
    c_s_roi = zeros(size(lamcsf_range));
    c_d_m = zeros(size(lamcsf_range));
    c_nl = zeros(size(lamcsf_range));
    c_nl_roi = zeros(size(lamcsf_range));
    formatSpec = '%5.0f';
    for idx = 1:length(lamcsf_range)
        hdr.lam_CSF = lamcsf_range(idx);
        hdr.QSM_Prefix = ['QSM_lam_CSF', num2str(hdr.lam_CSF, formatSpec)];
        [c(idx), c_s(idx), c_roi(idx), c_s_roi(idx), c_nl(idx), c_nl_roi(idx), c_d_m(idx), hdr] = DipoleInversion(weights, RDF, hdr);
    end    

    save(fullfile(hdr.output_dir, [hdr.dataset, '_Default_Cost.mat']), ...
    "c", "c_s", "c_roi", "c_s_roi", "c_nl", "c_nl_roi", "c_d_m");
 
end





%%
% 
% clearvars; close all
% pc_range = [0.9, 0.85, 0.8, 0.75,0.5];
% for dataset = {'7T_Rot4', '7T_Rot5', '3T_Neutral', '3T_Rot1', '3T_Rot2'}
% 
% fprintf('Processing dataset: %s \n', dataset{1});
% 
%     input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\SNRwAVG_PDF';    
%     workspace_fn = fullfile(input_dir, [dataset{1}, '_workspace.mat']);
%     load(workspace_fn, "weights", "RDF", "hdr" )
%     hdr.noDipoleInversion = false;
%     hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\DiscPrinc\MEDI-SMV3_pc-range';
%     hdr.QSM_Prefix = 'QSM_SMV3';
%     hdr.useQualityMask = false; 
%     hdr.isSMV = true;
%     hdr.radius = 3; hdr.lambda = 1000; 
% 
%     if matches(dataset{1}, '3T')
%         hdr.lam_CSF = 10;
%     else
%         hdr.lam_CSF = 100;
%     end    
% 
%     c = zeros(size(pc_range));
%     c_s = zeros(size(pc_range));
%     c_roi = zeros(size(pc_range));
%     c_s_roi = zeros(size(pc_range));
%     c_m = zeros(size(pc_range));
%     for idx = 1:length(pc_range)
%         hdr.percentage = pc_range(idx);
%         hdr.QSM_Prefix = ['QSM_Pc', num2str(hdr.percentage)];
%         [c(idx), c_s(idx), c_roi(idx), c_s_roi(idx), c_m(idx), hdr] = DipoleInversion(weights, RDF, hdr);
%     end    
% 
% 
%     save(fullfile(hdr.output_dir, [dataset{1}, '_SMV3_Cost.mat']), ...
%     "c", "c_s", "c_roi", "c_s_roi", "c_m");
% 
% 
% 
% 
% end

    % vsz = hdr.voxel_size;
    % gamma = 42.6*2*pi; % [rad/s/T]
    % CF = gamma * hdr.FS; % [rad/s]
    % 
    % noise_std = pad_or_crop_target_size(hdr.fieldMapSD, vsz);
    % weights = pad_or_crop_target_size(weights, vsz);
    % Mask = pad_or_crop_target_size(hdr.Mask_Use,vsz);
    % % Compute expected noise for discrepancy principle
    % expected_noise_level = disc_principle(noise_std, weights, CF, Mask);
    % 
    % % Calculate absolute differences and find the index of the minimum difference
    % [~, idx] = min(abs(cost - expected_noise_level));
    % cost_opt = cost(idx);
    % pc_opt = pc_range(idx);
    % fprintf('\n Cost data: %d , pc: %d , closest to index: %d \n', cost_opt, pc_opt, idx);
    % 
    % % use linear interpolation to obtain the optimal parameter
    % interp = 'linear';
    % paramInterp = linspace(min(pc_range),max(pc_range),1000);
    % paramCostInterp = interp1(gather(pc_range),gather(cost),gather(paramInterp),interp);
    % [~, idx_interp] = min(abs(paramCostInterp - expected_noise_level));
    % cost_opt_interp = paramCostInterp(idx_interp);
    % pc_opt_interp = paramInterp(idx_interp);
    % 
    % fprintf('\n Cost data: %d , pc: %d , closest to interp index: %d \n', cost_opt_interp, pc_opt_interp, idx_interp);
    % 
    % save(fullfile(hdr.output_dir, [hdr.dataset, '_', hdr.QSM_Prefix, '_Cost.mat']), ...
    % "cost_sepia", "cost", "cost_opt", "pc_opt", ...
    % "cost_opt_interp", "pc_opt_interp");
    % fprintf('Processed Dataset %s \n', dataset{1});

  














    %% Phase processing

    % dataset{1} = '7T_Rot6';
    % hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\SNRwAVG_PDF';
    %     hdr.workspace_fn = fullfile(hdr.output_dir, strcat(dataset{1}, '_workspace.mat'));
    %     load(hdr.workspace_fn, "hdr", "iFreq")
    %     [RDF, hdr] = BackgroundFieldCorrection(iFreq, hdr);
    %     hdr.workspace_fn = fullfile(hdr.output_dir, strcat(hdr.dataset, '_workspace.mat'));
    %     save(hdr.workspace_fn, '-v7.3');
    %     fprintf('Vars saved to %s\n', hdr.workspace_fn);
    % hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\SDC';
    % hdr.BFCMethod = 'PDF'; hdr.erode_before_radius = 3;
    % hdr.saveDelta = true; hdr.saveWorkspace = true;
    % if contains(dataset{1}, '3T')
    %     hdr.EchoCombineMethod = 'SNRwAVG';
    %     hdr.temporalUnwrapping = 'ROMEO';
    % else
    %     hdr.EchoCombineMethod = 'NLFit';
    %     hdr.unwrapMethod = 'ROMEO';
    % end
    % 
    % hdr.RelativeResidualWeighting = false;
    % hdr.RelativeResidualWeighting = false;
    % hdr.useQualityMask = true;
    % hdr.optimizeMEDI = false;
    % hdr.noDipoleInversion = true;
    % QSM_Main_Valerie(dataset{1}, hdr);
    % Assuming you have already done steps 1 - 4 and saved to workspace
    
    % if matches(dataset{1}, '3T_Neutral')
        % hdr.qualityMask = hdr.fieldMapSD < (mean(hdr.fieldMapSD(hdr.Mask_Use == 1), "all"));
        % hdr.Mask_Use = hdr.Mask_Use .* hdr.qualityMask;
        % hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\ROIs\Working';
        % export_nii(single(pad_or_crop_target_size(hdr.Mask_Use, hdr.voxel_size)), fullfile(hdr.output_dir, [hdr.dataset, '_NLFit_Mask']), hdr.voxel_size);
    % return
    % end
    
    % hdr.noDipoleInversion = false;
    % hdr.useQualityMask = true;
    
    % if contains(dataset{1}, '3T')
    % hdr.radius = 4; hdr.QSM_Prefix = 'QSM_SMV4';
    % hdr.isSMV = true;        hdr.useQualityMask = false;
    % end
    
    % DipoleInversion(weights, RDF, hdr);


%%
% input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\COSMOS_SNRwAVG_PDF';
% for num_orient = 6
%     Wrapper_COSMOS_Recon(num_orient, input_dir);
% end

% InitiateParallelComputing();

% Padding

% input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\SDC\';
% output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\SDC\';
% Wrapper_ZeroPadVolumes(dataset{1}, input_dir, output_dir);


% SDC

% hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\';
% hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\SDC\';
% hdr.isInvert = false;
% Wrapper_FermiFilt_SDC(  hdr, dataset{1} );

% R2star mapping w/ parallel computing

% SDC_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\SDC\';
% mask_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\SDC\';

% InitiateParallelComputing();
% %
% %
% magn_nii = load_untouch_nii(fullfile(SDC_dir, [dataset{1}, '_Magn.nii.gz']));
% mask_nii = load_untouch_nii(fullfile(mask_dir, [dataset{1}, '_Mask_Use.nii.gz']));
% magn = single(magn_nii.img);
% mask = single(mask_nii.img);
% TE=(3:3:21)./1000;
% NUM_MAGN = length(TE);
% isParallel = 0;
% [R2s, ~, ~] = R2star_NLLS(magn, TE, mask, isParallel, NUM_MAGN);
% R2s = R2s .* mask;
% export_nii(R2s, fullfile(dir, [dataset{1}, '_R2s.nii.gz']), voxel_size);


%% Save Pre-processed data to MAT file

% NIfTI_to_MAT_Padded(dataset{1}, dir);

%%
% '3T_Rot1', '3T_Rot2', '3T_Rot3', '3T_Rot5', '3T_Rot6', ...
% '7T_Rot1', '7T_Rot2', '7T_Rot3', '7T_Rot4', '7T_Rot5'

% input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\NC';
% output_dir= 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded';
%
% for dataset = {'7T_Rot4'}
%
%     magn_nii=load_untouch_nii(fullfile(input_dir, [dataset{1}, '_Magn.nii.gz']));
%
%
%     if contains(dataset{1}, '3T')
%         voxel_size = [1 1 1];
%         TE_idx = 1:7;
%     else
%         voxel_size = [.75 .75 .75];
%         TE_idx = 1:4;
%     end
%
%     Magn = single(magn_nii.img);
%     Magn = Magn(:,:,:,TE_idx);
%     Magn = rescale(Magn, 0, 4095);
%     Magn = pad_or_crop_target_size(Magn, voxel_size);
%     Magn_Demeaned                = mean(Magn,4);
%     export_nii(Magn_Demeaned, fullfile(output_dir, [dataset{1}, '_Magn_Demeaned']), voxel_size);
%
%
% end
%
% %%
%
% input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Noise_Level';
% output_dir= 'C:\Users\rosly\Documents\Valerie_PH\Data\Noise_Level';
%
% for dataset = {'7T_Neutral'} % , '7T_Neutral'
%
%     magn_nii=load_untouch_nii(fullfile(input_dir, [dataset{1}, '_Magn_FLIRT.nii.gz']));
%
%
%     if contains(dataset{1}, '3T')
%         voxel_size = [1 1 1];
%     else
%         voxel_size = [.75 .75 .75];
%     end
%
%     Magn = single(magn_nii.img);
%
%     Magn_Demeaned                = mean(Magn,4);
%     export_nii(Magn_Demeaned, fullfile(output_dir, [dataset{1}, '_Magn_Demeaned']), voxel_size);
%
%
% end


%Wrapper_COSMOS_Recon();

%end



% if matches(dataset{1}, '3T_Rot4') || matches(dataset{1}, '7T_Rot6')
%
%     addpath('C:\Users\rosly\Image_Analysis\DistortionCorrection')
%     addpath('C:\Users\rosly\Image_Analysis\spm12')
%
%     hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\NC\';
%     hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\SDC\';
%     hdr.isInvert = false;
%     Wrapper_FermiFilt_SDC(  hdr, dataset{1} );
%
%     rmpath('C:\Users\rosly\Image_Analysis\DistortionCorrection')
%     rmpath('C:\Users\rosly\Image_Analysis\spm12')
%
%     input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\SDC\';
%     output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\SDC\';
%     Wrapper_ZeroPadVolumes(dataset{1}, input_dir, output_dir);
%
%     InitiateParallelComputing();
%
%     magn_nii = load_untouch_nii(fullfile(dir, [dataset{1}, '_Magn_Padded.nii.gz']));
%     mask_nii = load_untouch_nii(fullfile(dir, [dataset{1}, '_mask.nii.gz']));
%     magn = single(magn_nii.img);
%     mask = single(mask_nii.img);
%     TE=(3:3:21)./1000;
%     NUM_MAGN = length(TE);
%     isParallel = 0;
%     [R2s, ~, ~] = R2star_NLLS(magn, TE, mask, isParallel, NUM_MAGN);
%     R2s = R2s .* mask;
%     export_nii(R2s, fullfile(dir, [dataset{1}, '_R2s_Padded.nii.gz']), [.75 .75 .75]);
%
%     NIfTI_to_MAT_Padded(dataset{1}, dir);
% end
% hdr.saveDelta = true; hdr.saveWorkspace = true; hdr.useQualityMask = true;
% hdr.EchoCombineMethod = 'SNRwAVG';
% hdr.RelativeResidualMasking = true;
% hdr.ApplyWeightingFieldMapSD = true;
%
% hdr.RelativeResidualWeighting = false;
% hdr.optimiseMEDI = false;
% hdr.noDipoleInversion = true;
% [hdr] = InitializeParams_Valerie(dataset{1}, hdr);
% [iFreq, hdr.fieldMapSD] = Fit_ppm_complex(hdr.Magn.*exp(-1i*hdr.Phs));
% DataConsistencyWeighting(iFreq, hdr);
% fprintf('Processed Dataset %s \n', dataset{1});


% dataset = '3T_Neutral';
%     input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\SDC\';
%     output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\SDC\';
%     Wrapper_ZeroPadVolumes(dataset, input_dir, output_dir);

% hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\NC\';
% hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\SDC\';
% hdr.isParallel = true;
% hdr.isInvert = false;
% Wrapper_FermiFilt_SDC(  hdr, dataset{1} );
% input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\SDC\';
% output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\SDC\';
% Wrapper_ZeroPadVolumes(dataset{1}, input_dir, output_dir);


% for dataset = {'3T_Rot6'}
% hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\NC\';
% hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\FermiFilt_SDC\';
% hdr.isParallel = true;
% hdr.isInvert = false;
% Wrapper_FermiFilt_SDC(  hdr, dataset{1} );
% input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\FermiFilt_SDC\';
% output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\FermiFilt_SDC\';
% Wrapper_ZeroPadVolumes(dataset{1}, input_dir, output_dir);
% input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\FermiFilt_SDC\';
% output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\R2s\';
% NII_to_MAT_for_R2s(dataset{1}, input_dir, output_dir);
% Wrapper_R2starNLLS(dataset{1}, input_dir, output_dir);
% end

% for dataset = {'3T_Neutral', '7T_Neutral'} % ,
%
%     InitiateParallelComputing();
%     hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\FermiFilt_SNRwAVG_RRW_PDF\';
%     workspace_fn = fullfile(hdr.output_dir, [dataset{1}, '_workspace.mat']);
%     load(workspace_fn, "iFreq", "hdr")
%     hdr.RelativeResidualWeighting = false; hdr.RelativeResidualMasking = false;
%     % hdr.optimiseMEDI = true;
%     hdr.TE = (3:3:21)./1000;
%     in_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\FermiFilt_SDC\';
%     load([in_dir, dataset{1}, '_forQSM'],'Magn');
%     hdr.Magn=Magn;
%     [weights, hdr] = DataConsistencyWeighting(iFreq, hdr);
%     export_nii(weights,fullfile(hdr.output_dir,[dataset{1},'_weights_NoRRW']),hdr.voxel_size);
%
% end

% for dataset = {'7T_Rot1', '7T_Rot2', '7T_Rot4', ...
%         '3T_Rot1', '3T_Rot3', '3T_Rot6'}
%
%     InitiateParallelComputing();
%
%     hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\FermiFilt_SNRwAVG_RRW_PDF\';
%     workspace_fn = fullfile(hdr.output_dir, [dataset{1}, '_workspace.mat']);
%     load(workspace_fn, "iFreq", "weights", "RDF", "hdr");
%     hdr.optimiseMEDI = false;
%     hdr.noDipoleInversion = false;
%     DipoleInversion(iFreq, weights, RDF, hdr);
%     fprintf('Processed Dataset %s\n\n', dataset{1});
%
% end



%% 3 T optimization result
% Lambda (10^-2 -> 10^2) Optimal for lambda = 22.8, curvature = 28312,
% data fidelity = 5603, chi gradient = 110
% Lam_CSF (10^-2 -> 10^2) Optimal for lam_csf = 88.8, curvature = 0.157,
% data fidelity = 5600, chi gradient = 106
% Percentage (0.3 -> 0.9) Optimal for pc = 0.735, curv = 0.010,
% data fidelity = 5600, chi gradient 133
%% 7 T optimization result
% Lambda (1 -> 1000) Optimal for lambda = ..., curvature = ...,
% data fidelity = ..., chi gradient = ...
% Lam_CSF (1 -> 1000) Optimal for lam_csf = ..., curvature = ...,
% data fidelity = ..., chi gradient = ...
% Percentage (0.1 -> 1) Optimal for pc = ..., curv = ...,
% data fidelity = ..., chi gradient ...





% for dataset = {'7T_Neutral', '3T_Neutral'} % ,
%
%     InitiateParallelComputing();
%     hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\FermiFilt_SNRwAVG_RRW_PDF\';
%     workspace_fn = fullfile(hdr.output_dir, [dataset{1}, '_workspace.mat']);
%     load(workspace_fn, "iFreq", "weights", "RDF", "hdr")
%     hdr.optimiseMEDI = true;
%     DipoleInversion(iFreq, weights, RDF, hdr);
%
% end
%
% Wrapper_COSMOS_Recon();

% dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\FermiFilt_SNRwAVG_RRW_PDF';
% cd(dir)
% load('7T_Neutral_workspace.mat','weights')
% export_nii(weights,'7T_Neutral_weights', [.75 .75 .75]);




%     hdr.dataset = dataset{1};
% workspace_fn = fullfile(hdr.output_dir, [hdr.dataset, '_workspace.mat']);
% load(workspace_fn, "iFreq", "RDF", "hdr")
% hdr.TE=(3:3:21)./1000;
% hdr.noDipoleInversion = false;
% hdr.RelativeResidualWeighting = true;
% [weights, hdr] = DataConsistencyWeighting(iFreq, hdr);
%
% DipoleInversion(iFreq, weights, RDF, hdr);


% dataset='7T_Neutral';
% apply_MCPC(dataset);

% DONE = , '3T_Rot1', '3T_Rot3', '7T_Rot1', '3T_Neutral', '3T_Rot2',
% '7T_Neutral', '7T_Rot2', '7T_Rot4'
% TODO = , ..., '3T_Rot6'
%


% InitiateParallelComputing();

% input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\FermiFilt_SDC\';
% output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\R2s\';
% Wrapper_R2starNLLS('7T_Neutral', input_dir, output_dir);


% for dataset = {'3T_Rot6'}
% hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\NC\';
% hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\FermiFilt_SDC\';
% hdr.isParallel = true;
% hdr.isInvert = false;
% Wrapper_FermiFilt_SDC(  hdr, dataset{1} );
% input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\FermiFilt_SDC\';
% output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\FermiFilt_SDC\';
% Wrapper_ZeroPadVolumes(dataset{1}, input_dir, output_dir);
% input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\FermiFilt_SDC\';
% output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\R2s\';
% NII_to_MAT_for_R2s(dataset{1}, input_dir, output_dir);
% Wrapper_R2starNLLS(dataset{1}, input_dir, output_dir);
% end

% dataset = '7T_Neutral';
% input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\FermiFilt_SDC\';
% output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\FermiFilt_SDC\';
% Wrapper_ZeroPadVolumes(dataset, input_dir, output_dir);
% DONE = '3T_Neutral', '7T_Neutral', '7T_Rot2', '7T_Rot4'
% TODO = '3T_Rot6'

% for dataset = {'7T_Neutral', '7T_Rot2', '7T_Rot4', '3T_Neutral', '3T_Rot6'}
%     output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\CSF_Mask';
%     CSF_Mask_test(dataset{1}, output_dir)
% end

% dataset = '7T_Neutral';
% input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\FermiFilt_SDC\';
% output_dir = input_dir;
% NIfTI_to_MAT_Padded(dataset, input_dir, output_dir);

% for dataset = {'7T_Neutral', '7T_Rot1', '7T_Rot2', '7T_Rot3', '7T_Rot4', '7T_Rot5', '3T_Neutral', '3T_Rot1', '3T_Rot3', '3T_Rot5', '3T_Rot6'}
%     hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\FermiFilt_SDC\';
%     hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\FermiFilt_SNRwAVG_VSHARP\';
%     hdr.BFCMethod = 'V-SHARP 12SMV STI';
%     hdr.saveDelta = true; hdr.saveWorkspace = true; hdr.noDipoleInversion = true; hdr.useQualityMask = true;
%     hdr.EchoCombineMethod = 'SNRwAVG';
%     Wrapper_QSM_Main_COSMOS(hdr, dataset{1});
% end


% Wrapper_COSMOS_Recon();



% end



%

% if contains(dataset{1}, '7T_Neutral')
%     new_vsz = [0.75 0.75 0.75];
%     dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\FermiFilt_SDC\';
%     Wrapper_resample_volumes(dataset{1}, dir, new_vsz);
% end

% for dataset = {'3T_Neutral', '3T_Rot1', '3T_Rot2', '3T_Rot3', ...
%                '7T_Neutral', '7T_Rot1', '7T_Rot2', '7T_Rot4'}
%     hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\FermiFilt_SDC\';
%     hdr.isParallel = false;
%     hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\FermiFilt\';
%     hdr.saveDelta = true; hdr.saveWorkspace = false; hdr.useQualityMask = true;
%     Wrapper_QSM_Main_COSMOS(hdr, dataset{1});
% end


% clearvars
% %
% for dataset = {'3T_Rot1'}
%     hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\NC\';
%     hdr.isParallel = false;
%     hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\HanningFilt_SDC\';
%     hdr.isInvert = false;
%     Wrapper_HanningFilt_SDC(hdr, dataset{1});
% end
%
% clearvars
% '3T_Rot5', '7T_Rot1'
% for dataset = { '7T_Rot2', '7T_Rot4' }
%     hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\NC\';
%     hdr.isParallel = true;
%     hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\FermiFilt_SDC\';
%     hdr.isInvert = false; % Flips the sign of the phase
%     Wrapper_FermiFilt_SDC(hdr, dataset{1});
%     NIfTI_to_MAT_COSMOS(dataset{1});
%     clear hdr
%     hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\FermiFilt_SDC\';
%     hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\FermiFilt\';
%     hdr.saveDelta = true; hdr.useQualityMask = true;
%
%     % Mask_fn = fullfile( hdr.path_to_data, [dataset{1}, '_mask.nii.gz'] );
%     % Mask_nii = load_untouch_nii(Mask_fn);
%     % Mask_Use = single(Mask_nii.img);
%     % savefile = fullfile( hdr.path_to_data, [dataset{1}, '_forQSM.mat'] );
%     % save(savefile, "Mask_Use", "-append");
%
%     Wrapper_QSM_Main_COSMOS(hdr, dataset{1});
% end















% for dataset = {'3T_Rot1', '3T_Rot3', '3T_Rot5', '7T_Rot1', '7T_Rot3', '7T_Rot5'}
%     hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\degibbs\';
%     hdr.isParallel = true;
%     hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\COSMOS_Prep\degibbs\';
%     hdr.saveDelta = true; hdr.saveWorkspace = false; hdr.useQualityMask = true;
%     Wrapper_QSM_Main_COSMOS(hdr, dataset{1});
% end
%
% for dataset = {'3T_Rot1', '3T_Rot3', '3T_Rot5', '7T_Rot1', '7T_Rot3', '7T_Rot5'}
%     NIfTI_to_MAT_degibbs(dataset{1});
% end
%
% for dataset = {'3T_Rot1', '3T_Rot3', '3T_Rot5', '7T_Rot1', '7T_Rot3', '7T_Rot5'}
%     hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\degibbs3D\';
%     hdr.isParallel = true;
%     hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\COSMOS_Prep\degibbs3D\';
%     hdr.saveDelta = true; hdr.saveWorkspace = false; hdr.useQualityMask = true;
%     Wrapper_QSM_Main_COSMOS(hdr, dataset{1});
% end




% for dataset = {'3T_Rot1', '3T_Rot3', '3T_Rot5', '7T_Rot1', '7T_Rot3', '7T_Rot5'}
%     ZeroPad_N4_ITK(dataset{1});
% end