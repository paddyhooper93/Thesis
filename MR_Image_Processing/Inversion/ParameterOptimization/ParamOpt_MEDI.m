function [paramOpt_LCurve, paramOpt_Morozov, chiOpt_LCurve, chiOpt_Morozov] = ParamOpt_MEDI(varargin) 

[filename, param_flag, FS, idx_dir, RDF, lambda, percentage]  = ...
    parse_paramOpt_input(varargin{:});

    % Parameters to be parsed directly into MEDI_L1.m function
    wData = true;
    wGrad = true;
    isMerit = true;
    pad = 0;
    if matches(FS, '3T')
        lam_CSF = 10^2;   
    elseif matches(FS, '7T')
        lam_CSF = 10^1;
    end

    % Parameter range in logspace (optimal parameter centered in logspace).
    if matches(param_flag, 'pc', 'IgnoreCase',true)
        param = linspace(0.1, 0.7, 10); % Linspace OK for pc.
    elseif matches(param_flag, 'lam', 'IgnoreCase',true) && matches(FS, '3T')
        param = logspace(2, 1, 10);
    elseif matches(param_flag, 'lam', 'IgnoreCase',true) && matches(FS, '7T')
        param = logspace(4, 3, 10);
    elseif matches(param_flag, 'lam_csf', 'IgnoreCase',true) && matches(FS, '3T')
        param = logspace(1.5, 2.5, 10);
    elseif matches(param_flag, 'lam_csf', 'IgnoreCase',true) && matches(FS, '7T')
        param = logspace(0.5, 1.5, 10);
    end

    cost_data = zeros(1,length(param), 'like', RDF);
    cost_reg = zeros(1,length(param), 'like', RDF);
    chi = zeros([size(RDF), length(param)], 'like', RDF);

    for t = 1:length(param)
        
        
        if matches(param_flag, 'pc')
            percentage = param(t);
            fprintf('\n Trying percentage: %.1f \n', param(t));          
        elseif matches(param_flag, 'lam')
            lambda = param(t);
            fprintf('\n Trying lambda: %.3e \n', param(t));          
        elseif matches(param_flag, 'lam_csf')
            lam_CSF = param(t);
            fprintf('\n Trying lam_CSF: %.3e \n', param(t));
        end

    %% Calculating C and R for L-curve: Second and third outputs of MEDI_L1.m
    
    % cost_reg(t) = norm of gradient regularization term   
    % cost_data =  norm of (non-linear) data consistency term

    [chi(:,:,:,t), cost_reg(t), cost_data(t)] = MEDI_L1('filename',filename,'lambda',lambda,'data_weighting',wData,'gradient_weighting',wGrad,...
        'merit',isMerit,'zeropad',pad,'lambda_CSF',lam_CSF,'percentage',percentage);

    end

    %% Optimal param using Morozov's Discrepancy Principle: cost_data:= expected_noise_level
    if matches(FS, '3T')
        expected_noise_level = 1.6;
    elseif matches(FS, '7T')
        expected_noise_level = 3.5;
    end

    % use linear interpolation to obtain the optimal parameter
    interp = 'linear';
    paramInterp = linspace(min(param),max(param),1000);
    paramCostInterp = interp1(gather(param),gather(cost_data),gather(paramInterp),interp);

    % Calculate absolute differences and find the index of the minimum difference
    [~, idx_interp] = min(abs(paramCostInterp - expected_noise_level));
    [~, idx] = min(abs(cost_data - expected_noise_level));
    fprintf('\n Optimal param (Morozov) closest to index: %d \n', idx);

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
    interp = 'spline';
    paramInterp = linspace(min(param),max(param),1000);
    paramkappaInterp = interp1(gather(param),gather(kappa),gather(paramInterp),interp);
    % find maximum curvature (kappa)
    [~, I] = sort(paramkappaInterp,'descend');
    paramOpt_LCurve = paramInterp(I(1));
    % Calculate absolute differences and find the index of the minimum difference
    [~, idx_LCurve] = min(abs(cost_data - paramOpt_LCurve));
    fprintf('\n Optimal param (L-Curve) closest to index: %d \n ', idx);


    chiOpt_LCurve   = chi(:,:,:,idx_LCurve);

    %% Plotting results
    fprintf('\n Optimal param (Morozov): %.3e \n', paramOpt_Morozov);
    fprintf('\n Optimal param (L-curve): %.3e \n', paramOpt_LCurve);    
    if matches(param_flag, 'pc')
        figure(20), subplot(1,2,1), semilogx(cost_data, cost_reg, 'Marker', '*'), ...
        title('L-curve'), xlabel('Data consistency cost'), ylabel('Regularization cost')
        drawnow; % Force figure update    
        subplot(1,2,2), semilogx(paramInterp, paramkappaInterp, 'Marker', '*'), ...
        title('Curvature'), xlabel('Percentage'), ylabel('Curvature')
        drawnow; % Force figure update
        saveas(gcf,[FS, '_', idx_dir, '_pc_L-Curve.png']);
        save([FS, '_', idx_dir, '_pc_history'], "chi", "param", "paramOpt_Morozov", "paramOpt_LCurve", ... 
            "cost_data", "cost_reg", "paramInterp", "paramkappaInterp")
    elseif matches(param_flag, 'lam')
        save([FS, '_', num2str(idx_dir), '_lambda_history'], "chi", "param", "paramOpt_Morozov", "paramOpt_LCurve", ... 
            "cost_data", "cost_reg", "paramInterp", "paramkappaInterp")
        figure(30), subplot(1,2,1), semilogx(cost_data, cost_reg, 'Marker', '*'), ...
        title('L-curve'), xlabel('Data consistency cost'), ylabel('Regularization cost')
        drawnow; % Force figure update    
        subplot(1,2,2), semilogx(paramInterp, paramkappaInterp, 'Marker', '*'), ...
        title('Curvature'), xlabel('Lambda'), ylabel('Curvature')
        drawnow; % Force figure update
        saveas(gcf,[FS, '_', num2str(idx_dir), '_lambda_L-Curve.png']);
        figure(32), semilogx(paramInterp, paramCostInterp, 'LineWidth', 1.5, 'DisplayName', 'Interpolated Data');
        title('Parameter optimization: Lambda'), xlabel('Lambda'), ylabel('Data consistency cost');
        hold on;
        % Scatter plot for the 15 data points
        scatter(param, cost_data, 50, 'bo', 'filled', 'DisplayName', 'Original Data');
        plot(paramOpt_Morozov, noiselevel_interp, 'r*', 'MarkerSize', 10, 'DisplayName', 'Optimal Lambda')
        % Add dotted horizontal line
        yline(noiselevel_interp, 'k--', 'Noise Level', 'LineWidth', 1.5, 'DisplayName', 'Noise Level');
        legend('show')
        drawnow; % Force figure update    
        saveas(gcf,[FS, '_', num2str(idx_dir), '_lambda_Morozov.png']);

    elseif matches(param_flag, 'lam_csf')
        save([FS, '_', num2str(idx_dir), '_lam-CSF_history'], "chi", "param", "paramOpt_Morozov", "paramOpt_LCurve", ... 
            "cost_data", "cost_reg", "paramInterp", "paramkappaInterp")
        figure(40), subplot(1,2,1), semilogx(cost_data, cost_reg, 'Marker', '*'), ...
        title('L-curve'), xlabel('Data consistency cost'), ylabel('Regularization cost')
        subplot(1,2,2), semilogx(paramInterp, paramkappaInterp, 'Marker', '*'), ...
        title('Curvature'), xlabel('Lambda\_CSF'), ylabel('Curvature')
        drawnow; % Force figure update
        saveas(gcf,[FS, '_', num2str(idx_dir), '_lam-csf_L-Curve.png']);
        figure(42), plot(paramInterp, paramCostInterp, 'LineWidth', 1.5, 'DisplayName', 'Interpolated Data');
        title('Parameter optimization: Lambda\_CSF'), xlabel('Lambda\_CSF'), ylabel('Data consistency cost');
        hold on;
        % Scatter plot for the 15 data points
        scatter(param, cost_data, 50, 'bo', 'filled', 'DisplayName', 'Original Data');
        plot(paramOpt_Morozov, noiselevel_interp, 'r*', 'MarkerSize', 10, 'DisplayName', 'Optimal Lambda\_CSF')
        % Add dotted horizontal line
        yline(noiselevel_interp, 'k--', 'Noise Level', 'LineWidth', 1.5, 'DisplayName', 'Noise Level');
        legend('show')
        drawnow; % Force figure update     
        saveas(gcf,[FS, '_', num2str(idx_dir), '_lam-CSF_Morozov.png']);

    end
