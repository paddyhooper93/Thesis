function [cost_data_norm, lambdaInterp, lambdaCostInterp, lambdaOpt] = Morozov(lam_range, cost_data, epsilon, interpMethod)
%% Optimal lambda using Morozov's Discrepancy Principle: lambda is optimal when cost_data = epsilon

    if nargin < 4
        interpMethod = 'pchip';
    end

    % Normalize cost_data by epsilon
    cost_data_norm = cost_data ./ epsilon;

    % use pchip interpolation to obtain the optimal lambda
    lambdaInterp = linspace(min(lam_range),max(lam_range),1000);
    lambdaCostInterp = interp1(gather(lam_range),gather(cost_data_norm),gather(lambdaInterp),interpMethod);

    % Calculate absolute differences and find the index where
    % cost_data_norm = 1
    [~, idx_interp] = min(abs(lambdaCostInterp - 1));
    lambdaOpt = lambdaInterp(idx_interp);
    fprintf('\n Optimal lambda (Morozov): %d \n', lambdaOpt);

    % idx_interp now holds the interpolated index of lambda

