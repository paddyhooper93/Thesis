%% Step (1): Morozov
% clc
% clearvars
% close all
% path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\SNRwAVG_PDF';
% i = {'3T_Rot5', '7T_Rot5'};
% 
% 
% lam_range = 4.5e4;
% while lam_range(end) > 1e3
%     lam_range(end+1) = lam_range(end) / exp(1);
% end
% 
% for dataset = i
% 
%     workspace_fn = fullfile(path_to_data, [dataset{1}, '_workspace.mat']);
%     load(workspace_fn, "weights", "RDF", "hdr");
%     hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Morozov';
% 
%     hdr.noDipoleInversion = false;
%     hdr.isSMV = false; hdr.isCSF = false;
%     hdr.percentage = 0.5; hdr.isMerit = 0;
%     hdr.FOV = [210, 240, 192]; % mm^3
% 
%     cost_data = zeros(1,5);
%     Streaking = zeros(1,5);
%     nrmse = zeros(1,5);
%     xsim = zeros(1,5);
%     hfen = zeros(1,5);
%     x = 0;
%     for lambda = lam_range
%         x = x + 1;
%         hdr.lambda = lambda;
%         hdr.QSM_Prefix = ['Lambda_', num2str(hdr.lambda, 4.4), '_QSM'];
%         [cost_data, ~, sd_csf, ~, metrics] = DipoleInversion(weights, RDF, hdr);
%         nrmse(x) = metrics.rmse;
%         hfen(x) = metrics.hfen;
%         xsim(x) = metrics.xsim;
%         Streaking(x) = sd_csf .* 1000;
%         cost_data(x) = cost_data;
%     end
% 
%     if hdr.FS == 3
%         epsilon = 1.55;
%     else
%         epsilon = 3.49;
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
%     savefile = fullfile(hdr.output_dir, [hdr.dataset, '_Lambda', num2str(hdr.lambda, 4.4), '_Cost.mat']);
%     save(savefile, 'lam_range', 'cost_data', 'lambdaOpt', 'xsim', 'Streaking', 'nrmse', 'hfen');
% end
% 
% %% Step (2): Gradient weighting
% 
% clc
% clearvars
% close all
% path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\SNRwAVG_PDF';
% i = {'3T_Rot5', '7T_Rot5'};
% 
% for dataset = i
% 
%     workspace_fn = fullfile(path_to_data, [dataset{1}, '_workspace.mat']);
%     load(workspace_fn, "weights", "RDF", "hdr");
% 
%     nrmse = zeros(1,8);
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
%         hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\GradientWeighting';
%         hdr.noDipoleInversion = false;
%         hdr.isSMV = false; hdr.isCSF = false;
%         hdr.isMerit = 0;
%         hdr.lambda = 1e4;
%         hdr.FOV = [210, 240, 192]; % mm^3
%         [~, ~, sd_csf, ~, metrics] = DipoleInversion(weights, RDF, hdr);
%         x = x + 1;
%         Streaking(x) = sd_csf .* 1e3; % ppb
%         nrmse(x) = metrics.rmse;
%         hfen(x) = metrics.hfen;
%         xsim(x) = metrics.xsim;
%     end
% 
%     % % Find optimal percentage given xsim
%     % [pcInterp, pcXsimInterp] = interpParamMetric(pc_range, xsim, 'pchip');
%     % [~, idx_1] = max(pcXsimInterp);
%     % pcXsimOpt = pcInterp(idx_1);
%     % fprintf('\n Optimal pc given xsim: %d \n', pcXsimOpt);
% 
%     % Find optimal percentage given nrmse
%     [pcInterp, pcNrmseInterp] = interpParamMetric(pc_range, nrmse, 'pchip');
%     [~, idx_1] = max(pcNrmseInterp);
%     pcOptNrmse = pcInterp(idx_1);
%     NrmseVal = pcNrmseInterp(idx_1);
%     fprintf('\n Optimal pc given nrmse: %d at value: %d \n', pcOptNrmse.*100, NrmseVal);
% 
%     % Find optimal percentage given SD_CSF
%     [~, pcStreakingInterp] = interpParamMetric(pc_range, Streaking, 'pchip');
%     [~, idx_2] = min(pcStreakingInterp);
%     pcOptStreaking = pcInterp(idx_2);
%     StreakingVal = pcStreakingInterp(idx_2);
%     fprintf('\n Optimal pc given streaking artifact: %d at value: %d \n', pcOptStreaking.*100, StreakingVal);
% 
%     figure
%     hold on
%     xlabel('percentage threshold')
%     xticks(pc_range);
%     xticklabels(compose("%1.1f", xticks));
%     % yyaxis left
%     scatter(pc_range, nrmse, 50, 'ko', 'filled', 'DisplayName', 'rmse (original data)');
%     hold on
%     plot(pcInterp, pcNrmseInterp, 'LineWidth', 2, 'Color', [.6 0 0], 'DisplayName', 'rmse (interpolated data)');
%     hold on
%     plot(pcOptNrmse, NrmseVal, 'ko', 'MarkerSize', 10, 'DisplayName', 'Optimal pc (rmse)');
%     ylabel('rmse')
%     yticks('auto');
%     yticklabels(compose("%1.2f", yticks));
%     legend('show', 'Location', 'best'); 
%     drawnow;
%     saveas(gcf, fullfile(hdr.output_dir, [hdr.dataset, '_Percentage_rmse.png']));
% 
%     figure
%     % yyaxis right
%     hold on
%     xlabel('percentage threshold')
%     xticks(pc_range);
%     xticklabels(compose("%1.1f", xticks));
%     scatter(pc_range, Streaking, 50, 'ko', 'filled', 'DisplayName', 'streaking (original data)');
%     plot(pcInterp, pcStreakingInterp, 'LineWidth', 2, 'Color', [.6 0 0], 'DisplayName', 'streaking (interpolated data)'); % [1 .8 0]
%     hold on
%     plot(pcOptStreaking, StreakingVal, 'ko', 'MarkerSize', 10, 'DisplayName', 'Optimal pc (Streaking)');   
%     ylabel('Streaking artifact (ppb)')
%     yticks('auto')
%     yticklabels(compose("%d", yticks));    
%     hold on
%     legend('show', 'Location', 'best'); 
%     drawnow;
%     saveas(gcf, fullfile(hdr.output_dir, [hdr.dataset, '_Percentage_streaking.png']));
% 
%     savefile = fullfile(hdr.output_dir, [hdr.dataset, '_Vars.mat']);
%     save(savefile, 'pc_range', 'Streaking', 'pcOptStreaking', 'nrmse', 'pcOptNrmse', 'hfen', 'xsim');
%     fprintf('Processed Dataset %s \n', hdr.dataset);
% end


%% Step (3) Tikhonov regularization

clc
clearvars
close all
path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\SNRwAVG_PDF';
i = {'3T_Rot5', '7T_Rot5'}; % 
for dataset = i

    workspace_fn = fullfile(path_to_data, [dataset{1}, '_workspace.mat']);
    load(workspace_fn, "weights", "RDF", "hdr");

    nrmse = zeros(1,5);
    hfen = zeros(1,5);
    xsim = zeros(1,5);
    Streaking = zeros(1,5);
    cost_data = zeros(1,5);
    cost_reg = zeros(1,5);
    x = 0;
    % x = 4;


    Tik_range = 2.5e2;
    while Tik_range(end) > 1
        Tik_range(end+1) = Tik_range(end) / exp(1);
    end

    for tik = Tik_range

        hdr.lam_CSF = tik;
        hdr.QSM_Prefix = ['Tik_', num2str(hdr.lam_CSF, 4), '_QSM'];
        hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Tik';
        hdr.noDipoleInversion = false;
        hdr.isSMV = false; hdr.isCSF = true;
        hdr.isMerit = 0; hdr.percentage = 0.5;
        hdr.lambda = 1e4;
        % hdr.FOV = round([210, 240, 192].*mean(hdr.voxel_size)); 
        hdr.FOV = [210 240 192];
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

% cost_data=cost_data(1:5);
% cost_reg=cost_reg(1:5);
% Tik_range=Tik_range(1:5);
% hdr.dataset = '7T_Rot5';
% hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Tik';

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
%
    figure
    scatter(log(cost_data), log(cost_reg), 50, 'ko', 'filled', 'DisplayName', 'Original data'), hold on    
    plot(log(DataInterp), log(DataRegInterp), 'LineWidth', 2, 'Color', [.6 0 0], 'DisplayName', 'Interpolated data'), hold on    
    xlabel('Log (Data consistency cost)'), ...
        xticks(round([min(log(cost_data)) max(log(cost_data))], 2)), xticklabels(compose("%1.2f", xticks));
    ylabel('Log (Regularization cost'), ...
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