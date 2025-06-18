function Run_commands
% See InitializeVar.m for optional parameters

clc
clearvars
close all
path_to_data = 'C:\Users\rosly\Documents\QSM_PH\Analysis\Morozov'; 


i = {'3T_9mth', '7T_9mth'};

for dataset = i
    workspace_fn = fullfile(path_to_data, [dataset{1}, '_workspace.mat']);
    load(workspace_fn, 'RDF', 'hdr', 'weights');
    hdr.output_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\Tik'; 
    nrmse = zeros(1,7);
    hfen = zeros(1,7);
    xsim = zeros(1,7);
    Streaking = zeros(1,7);
    cost_data = zeros(1,7);
    cost_reg = zeros(1,7);
    x = 0;

    Tik_range = 2.5e2;
    while Tik_range(end) > 1
        Tik_range(end+1) = Tik_range(end) / exp(1);
    end


    for tik = Tik_range

        hdr.lam_CSF = tik;
        hdr.QSM_Prefix = ['Tik_', num2str(hdr.lam_CSF, 4), '_QSM'];
        
        hdr.noDipoleInversion = false;
        hdr.isSMV = false; hdr.isCSF = true;
        hdr.isMerit = 0; hdr.percentage = 0.5;        
        % if hdr.FS == 3
            hdr.lambda = 1e4;
        % else
            % hdr.lambda = 1e4;
        % end
        % hdr.FOV = round([192 192 112].*mean(hdr.voxel_size)); 
        hdr.FOV = [192 192 112];
        x = x + 1;
        [cost_data(x), cost_reg(x), sd_csf, ~, metrics] = DipoleInversion(weights, RDF, hdr);
        Streaking(x) = sd_csf .* 1e3; % ppb
        nrmse(x) = metrics.rmse;
        hfen(x) = metrics.hfen;
        xsim(x) = metrics.xsim;

    end

    savefile = fullfile(hdr.output_dir, [hdr.dataset, '_Vars.mat']);
    save(savefile, 'cost_data', 'cost_reg', 'Streaking', 'nrmse', 'hfen', 'xsim');
    fprintf('Processed Dataset %s \n', hdr.dataset);
%%

% cost_data=cost_data(1:6);
% cost_reg=cost_reg(1:6);
% Tik_range=Tik_range(1:6);

    % hdr.dataset = '7T_9mth';
    % hdr.output_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\Tik'; 
    % savefile = fullfile(hdr.output_dir, [hdr.dataset, '_Vars.mat']);
    % load(savefile, 'cost_data', 'cost_reg', 'Streaking', 'nrmse', 'hfen', 'xsim');    

    % Optimal param using largest curvature on log-log L-curve
    % find Kappa (largest curvature) 
    rho = log(cost_data.^2);
    eta = log(cost_reg.^2);
    % First derivatives w.r.t. parameter
    drho = myDerivative(rho, Tik_range);
    deta = myDerivative(eta, Tik_range);
    % Second derivatives w.r.t. parameter
    d2rho = myDerivative(drho, Tik_range);
    d2eta = myDerivative(deta, Tik_range);
    % Eq. 19 of Bilgic et al. MRM 72:1444-1459 (2014)
    kappa = (d2rho.*deta - d2eta.*drho) ./ (drho.^2 + deta.^2) .^ 1.5;
    % use spline interpolation to obtain finer resolution of the curvature
    tikInterp = linspace(min(Tik_range),max(Tik_range),1000);
    TikkappaInterp = interp1(gather(Tik_range),gather(kappa),gather(tikInterp),'spline');
    % Find maximum curvature (kappa)
    [~, I] = sort(TikkappaInterp,'descend');
    % Find optimal parameter
    TikOpt = tikInterp(I(1));
    CurvatureMax = TikkappaInterp(I(1));

    [DataInterp, DataRegInterp] = interpParamMetric(cost_data, cost_reg, 'pchip');        
%%    

    figure
    scatter(log(cost_data), log(cost_reg), 50, 'ko', 'filled', 'DisplayName', 'Original data'), hold on    
    plot(log(DataInterp), log(DataRegInterp), 'LineWidth', 2, 'Color', [.6 0 0], 'DisplayName', 'Interpolated data'), hold on    
    xlabel('Log (Data consistency cost)'), ...
    xticks(round([min(log(cost_data)) max(log(cost_data))], 2)), xticklabels(compose("%1.2f", xticks));
    ylabel('Log (Regularization cost)'), ...
    yticks(round([min(log(cost_reg)) max(log(cost_reg))], 2)), yticklabels(compose("%1.2f", yticks));
    legend('show', 'Location', 'best'), drawnow;
    saveas(gcf,fullfile(hdr.output_dir,[hdr.dataset,'_Tik_L-Curve.png']));
%%
    figure
    xlabel('Tikhonov parameter'), xticks(round([min(tikInterp) max(tikInterp)], 1)), ...
        xticklabels(compose("%1.0f", xticks)), hold on
    ylabel('Curvature'), yticks(round([min(TikkappaInterp) max(TikkappaInterp)], 0)), ...
        yticklabels(compose("%1.0f", yticks)), hold on
    plot(tikInterp, TikkappaInterp, 'LineWidth', 2, 'Color', [.6 0 0], 'DisplayName', 'Curvature'), hold on    
    plot(TikOpt, CurvatureMax, 'ko', 'MarkerSize', 10, 'DisplayName', 'Maximum curvature'), hold on
    legend('show', 'Location', 'best'), drawnow;   
    saveas(gcf,fullfile(hdr.output_dir,[hdr.dataset,'_Tik_Curvature.png']));
%%
    savefile = fullfile(hdr.output_dir, [hdr.dataset, '_Vars.mat']);
    save(savefile, 'TikOpt', 'Tik_range',  '-append');
    fprintf('Processed Dataset %s \n', hdr.dataset);    

end
    
% clc
% clearvars
% close all
% hdr.path_to_data = 'C:\Users\rosly\Documents\QSM_PH\Data\SDC-Cplx';
% hdr.output_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\Morozov'; 
% 
% if 7~=exist(hdr.output_dir, 'dir')
%     mkdir(hdr.output_dir);
% end
% 
% cd(hdr.output_dir);
% 
% i   = {'TE1to3_9mth' };  % 'TE1to3_9mth', '7T_9mth', ... 
% 
% for dataset = i
%     QSM_Main(dataset{1}, hdr);
%     fprintf('Processed Dataset %s \n', dataset{1});
% end
% %%
% clc
% clearvars
% close all
% 
% i = {'3T_9mth', '7T_9mth', 'TE1to3_9mth', 'TE1to7_9mth'};
% 
% for dataset = i
%     hdr.output_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\Morozov'; 
%     hdr.workspace_fn = fullfile(hdr.output_dir, [dataset{1}, '_workspace.mat']);
%     load(hdr.workspace_fn);
%     hdr.output_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\GradientWeighting_1'; 
%     if hdr.FS == 3
%         hdr.lambda = 1e3;
%     else
%         hdr.lambda = 1e4;
%     end
%     hdr.isCSF = false;
%     hdr.FOV = round(1.5.*[192 192 112].*mean(hdr.voxel_size)); % [288 x 288 x 168] mm^3
%     hdr.isSMV = false; hdr.isMerit = 0;
% 
%     rmse = zeros(1,8);
%     hfen = zeros(1,8);
%     xsim = zeros(1,8);
%     Streaking = zeros(1,8);
%     x = 0;
% 
%     pc_range = [0.1 0.5 0.9 1.3 1.7 2.1 2.5 2.9];
% 
%     for pc = pc_range
%         hdr.percentage = pc;
%         hdr.QSM_Prefix = ['Percentage_', num2str(hdr.percentage*100, 4.4), '_QSM'];        
%         [c_d_m, c_r_m, sd_csf, mean_csf, metrics] = DipoleInversion(weights, RDF, hdr);
%         savefile = fullfile(hdr.output_dir, [hdr.dataset, '_Pc', num2str(hdr.percentage*100, 4.4), '_Cost.mat']);
%         save(savefile, 'c_d_m', 'c_r_m', 'rmse', 'hfen', 'xsim', 'sd_csf', 'mean_csf');
%         x = x + 1;
%         Streaking(x) = sd_csf .* 1000;
%         rmse(x) = metrics.rmse;
%         hfen(x) = metrics.hfen;
%         xsim(x) = metrics.xsim;
%     end
% 
% %%
%     % Find optimal percentage given xsim
%     [pcInterp, pcXsimInterp] = interpParamMetric(pc_range, xsim, 'pchip');
%     [~, idx_1] = max(pcXsimInterp);
%     pcXsimOpt = pcInterp(idx_1);
%     xsimVal = pcXsimInterp(idx_1);
%     fprintf('\n Optimal pc given xsim: %d \n', pcXsimOpt);
% 
%     % Find optimal percentage given Streaking
%     [~, pcStreakingInterp] = interpParamMetric(pc_range, Streaking, 'pchip');
%     [~, idx_2] = min(pcStreakingInterp);
%     pcStreakingOpt = pcInterp(idx_2);
%     StreakingVal = pcStreakingInterp(idx_2);
%     fprintf('\n Optimal pc given streaking artifact: %d \n', pcStreakingOpt);
% 
%     figure
%     hold on
%     xlabel('percentage threshold')
%     xticks(pc_range);
%     xticklabels(compose("%1.1f", xticks));
%     % yyaxis left
%     scatter(pc_range, xsim, 20, 'ko', 'filled', 'DisplayName', 'xsim (original data)');
%     hold on
%     plot(pcInterp, pcXsimInterp, 'LineWidth', 2, 'Color', [.6 0 0], 'DisplayName', 'xsim (interpolated data)'); % [.6 0 0]
%     hold on
%     plot(pcXsimOpt, xsimVal, 'ko', 'MarkerSize', 10, 'DisplayName', 'Optimal pc (xsim)');
%     ylabel('xsim')
%     yticks('auto');
%     yticklabels(compose("%1.2f", yticks));
%     legend('show', 'Location', 'best'); 
%     drawnow;
%     saveas(gcf, fullfile(hdr.output_dir, [hdr.dataset, '_Percentage_xsim.png']));
% 
%     figure
%     % yyaxis right
%     hold on
%     xlabel('percentage threshold')
%     xticks(pc_range);
%     xticklabels(compose("%1.1f", xticks));
%     scatter(pc_range, Streaking, 20, 'ko', 'filled', 'DisplayName', 'streaking (original data)');
%     plot(pcInterp, pcStreakingInterp, 'LineWidth', 2, 'Color', [.6 0 0], 'DisplayName', 'streaking (interpolated data)'); % [1 .8 0]
%     hold on
%     plot(pcStreakingOpt, StreakingVal, 'ko', 'MarkerSize', 10, 'DisplayName', 'Optimal pc (Streaking)');   
%     ylabel('Streaking artifact (ppb)')
%     yticks('auto')
%     yticklabels(compose("%d", yticks));    
%     hold on
%     legend('show', 'Location', 'best'); 
%     drawnow;
%     saveas(gcf, fullfile(hdr.output_dir, [hdr.dataset, '_Percentage_streaking.png']));
%     % savefile = fullfile(hdr.output_dir, [hdr.dataset, '_Vars.mat']);
%     % save(savefile, 'pc_range', 'sd_csf', 'pcStreakingOpt', 'rmse', 'hfen', 'xsim', 'pcXsimOpt');    
%     fprintf('Processed Dataset %s \n', hdr.dataset);
% end
% %%
% i = {'7T_9mth', '3T_9mth', 'TE1to3_9mth', 'TE1to7_9mth'};
% 
% for dataset = i
%     hdr.output_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\Morozov'; 
%     hdr.workspace_fn = fullfile(hdr.output_dir, [dataset{1}, '_workspace.mat']);
%     load(hdr.workspace_fn);
%     hdr.output_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\Morozov_1'; 
%     hdr.FOV = round(1.5.*[192 192 112].*mean(hdr.voxel_size)); % [288 x 288 x 168] mm^3
%     hdr.isSMV = false; hdr.percentage = 0.5; hdr.isMerit = 0;
% 
%     lam_range = 4.5e4;
%     while lam_range(end) > 1e3
%         lam_range(end+1) = lam_range(end) / exp(1);
%     end
% 
%     cost_data = [];
%     x = 0;
%     for lambda = lam_range
%         hdr.lambda = lambda;
%         hdr.QSM_Prefix = ['Lambda_', num2str(hdr.lambda, 4.4), '_QSM'];        
%         [c_d_m, c_r_m, sd_csf, mean_csf, metrics] = DipoleInversion(weights, RDF, hdr);
%         rmse = metrics.rmse;
%         hfen = metrics.hfen;
%         xsim = metrics.xsim;
%         savefile = fullfile(hdr.output_dir, [hdr.dataset, '_Lambda', num2str(hdr.lambda, 4.4), '_Cost.mat']);
%         save(savefile, 'c_d_m', 'c_r_m', 'lam_range', 'rmse', 'hfen', 'xsim', 'sd_csf', 'mean_csf');
%         x = x + 1;
%         cost_data(x) = [cost_data c_d_m];
%     end
% 
%     if hdr.FS == 3
%         epsilon = 3.6;
%     else
%         epsilon = 7.2;
%     end    
% 
%     %% Statter plot for 5 data points and optimal lambda
%     [cost_data_norm, lambdaInterp, lambdaCostInterp, lambdaOpt] = Morozov(lam_range, cost_data, epsilon);
%     figure
%     scatter(lam_range, cost_data_norm, 50, 'ko', 'filled', 'DisplayName', 'Original Data')
%     hold on
%     plot(lambdaInterp, lambdaCostInterp, 'LineWidth', 2, 'Color', [.6 0 0], 'DisplayName', 'Interpolated Data');
%     hold on
%     plot(lambdaOpt, 1, 'ko', 'MarkerSize', 10, 'DisplayName', 'Optimal Lambda');
%     hold on
%     % yline(epsilon, 'k--', 'Noise Level', 'LineWidth', 1.5, 'DisplayName', 'Noise Level');
%     % hold on
%     legend('show', 'Location', 'best')
%     drawnow;
%     xlabel('Lambda')
%     xticks(1e4.*[0 1 2 3 4])
%     % xticks('auto')
%     xticklabels(compose("%.0e", xticks));
%     ylabel('Normalized residual')
%     yticks('auto')
%     yticklabels(compose("%1.1f", yticks));
%     saveas(gcf, fullfile(hdr.output_dir, [hdr.dataset, '_Lambda_Morozov.png']));
%     fprintf('Processed Dataset %s \n', hdr.dataset);
%     % savefile = fullfile(hdr.output_dir, [hdr.dataset, '_Lambda', num2str(hdr.lambda, 4.4), '_Cost.mat']);
%     % save(savefile, 'lam_range', 'cost_data', 'lambdaOpt', 'xsim', 'sd_csf');    
% end


% 1.0e+05 * [1.0000    0.8222    0.6443    0.4665    0.2887    0.1109]

% clearvars
% close all
% hdr = struct();
% hdr.output_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\VSH10_SEPIA\tmp_NLFit_MEDI0\'; 
% hdr.EchoCombineMethod = 'NLFit'; hdr.BFCMethod = 'V-SHARP 10SMV'; 
% hdr.isLambdaCSF = true;
% Wrapper_QSM_Main_All(hdr);

% clearvars
% close all
% hdr = struct();
% hdr.output_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\VSH12_SEPIA\tmp_SNRwAVG\'; 
% hdr.EchoCombineMethod = 'SNRwAVG'; hdr.BFCMethod = 'V-SHARP 12SMV'; 
% hdr.noDipoleInversion = true; hdr.saveInfCyl = true;
% Wrapper_QSM_Main_All(hdr);

% clearvars
% close all
% hdr = struct();
% hdr.output_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\RESHARP\tmp_SNRwAVG\'; 
% hdr.EchoCombineMethod = 'SNRwAVG'; hdr.BFCMethod = 'RESHARP'; 
% hdr.noDipoleInversion = true; hdr.saveInfCyl = true;
% Wrapper_QSM_Main_Short(hdr);
% 
% clearvars
% close all
% hdr = struct();
% hdr.output_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\VSH8_SEPIA\tmp_SNRwAVG_RTS_SSTGV_MEDISMV\'; 
% hdr.EchoCombineMethod = 'SNRwAVG'; hdr.isRTS = true; hdr.SingleStep = true; hdr.isSMV = true;
% Wrapper_QSM_Main_Shorter(hdr);
% 
% clearvars
% close all
% hdr = struct();
% hdr.output_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\VSH8_SEPIA_Idpt\tmp_SNRwAVG_MEDI+0\'; 
% hdr.isInvert = true; hdr.isLambdaCSF = true; hdr.EchoCombineMethod = 'SNRwAVG'; hdr.temporalUnwrapping = 'GraphCuts';
% Wrapper_QSM_Main_Idpt_All(hdr);