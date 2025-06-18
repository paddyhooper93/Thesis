function [chiOpt_Morozov] = LCurve_LSQR_COSMOS(param, FS_str, B, W, M, D, chi_CF)


    % Pre-compute mean B
    B_Mean = mean(B, 4);
    matrix_size = size(M);    


    cost_data = zeros(1,length(param), 'like', B_Mean);
    cost_reg = zeros(1,length(param), 'like', B_Mean);
    chi = zeros([size(B_Mean), length(param)]);
        
    for t = 1:length(param)
        
        fprintf('\n Trying param: %.3e \n', param(t));
        % tol = param(t);
        lam_CSF = param(t);

        tic
            [ chi(:,:,:,t) ] = COSMOS_nonlinear(B, D, W, M, 'tol', tol, ... 
                'x0', chi_CF); 
        toc

        % norm of data consistency term
        [cost_data(t), ~] = NonLinearDataFidelityNorm(chi(:,:,:,t), B_Mean, D);
        % norm of gradient regularization term
        [cost_reg(t), ~] = ResidualGradientGivenQSM(chi(:,:,:,t), matrix_size);
        fprintf('\n cost data: %g , cost gradient: %g \n', cost_data(t), cost_reg(t));
    end

    %% Optimal param using Morozov's Discrepancy Principle: cost_data:= expected_noise_level

    if matches(FS_str, '3T')
        expected_noise_level = mean([32.0 27.6]);
    elseif matches(FS_str, '7T')
        expected_noise_level = mean([18.3 16.5]);
    end

    % use spline interpolation to obtain finer resolution of the curvature
    interp = 'spline';
    paramInterp = linspace(min(param),max(param),1000);
    paramCostInterp = interp1(gather(param),gather(cost_data),gather(paramInterp),interp);

    % Calculate absolute differences and find the index of the minimum difference
    [~, idx_interp] = min(abs(paramCostInterp - expected_noise_level));
    [~, idx] = min(abs(cost_data - expected_noise_level));

    % idx now holds the index of the element closest to the target
    noiselevel_interp = paramCostInterp(idx_interp);
    paramOpt_Morozov = paramInterp(idx_interp);
    chiOpt_Morozov = chi(:,:,:,idx);
    

    %% Optimal param using largest curvature on log-log L-curve
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
    interpMethod = 'spline';
    paramInterp = linspace(min(param),max(param),1000);
    paramkappaInterp = interp1(gather(param),gather(kappa),gather(paramInterp),interpMethod);
    % Find maximum curvature (kappa)
    [~, I] = sort(paramkappaInterp,'descend');
    % Find optimal parameter to be parsed into COSMOS_nonlinear.m function
    paramOpt_LCurve = paramInterp(I(1));

    %% Plotting results
    fprintf('\n Optimal param (Morozov): %.3e \n', paramOpt_Morozov);
    fprintf('\n Optimal param (L-curve): %.3e \n', paramOpt_LCurve);    
    save(fullfile(output_dir, [FS_str, '_', num2str(dir_idx), '_param_history']), "chi", "param", "paramOpt_Morozov", "paramOpt_LCurve", ... 
    "cost_data", "cost_reg", "paramInterp", "paramkappaInterp")
    figure(50), subplot(1,2,1), semilogx(cost_data, cost_reg, 'Marker', '*'), ...
    title('L-curve'), xlabel('Data consistency cost'), ylabel('Gradient cost')
    subplot(1,2,2), semilogx(paramInterp, paramkappaInterp, 'Marker', '*'), ...
    title('Curvature of L-curve'), xlabel('Tolerance'), ylabel('Curvature')
    drawnow; % Force figure update
    saveas(gcf,fullfile(output_dir,[FS_str,'_LSQR-tol_L-Curve.png']));
    figure(52), semilogx(paramInterp, paramCostInterp, 'LineWidth', 1.5, 'DisplayName', 'Interpolated Data');
    title('Parameter optimization: LSQR Tolerance'), xlabel('Tolerance'), ylabel('Data consistency cost');
    hold on;
    % Scatter plot for the 15 data points
    scatter(param, cost_data, 50, 'bo', 'filled', 'DisplayName', 'Original Data');
    plot(paramOpt_Morozov, noiselevel_interp, 'r*', 'MarkerSize', 10, 'DisplayName', 'Optimal Tolerance')
    % Add dotted horizontal line
    yline(noiselevel_interp, 'k--', 'Noise Level', 'LineWidth', 1.5, 'DisplayName', 'Noise Level');
    legend('show')
    drawnow; % Force figure update    
    saveas(gcf,fullfile(output_dir, [FS_str, '_', num2str(dir_idx), '_tol_Morozov.png']));
    