function [paramInterp, paramMetricInterp] = optimal_percentage(param, metric, interpMethod)
%% Interpolate x-var (param) and y-var (metric) using interpMethod

    if nargin < 3
        interpMethod = 'pchip';
    end

    % use interpolation to obtain the optimal pc
    paramInterp = linspace(min(param),max(param),1000);
    paramMetricInterp = interp1(gather(param),gather(metric),gather(paramInterp),interpMethod);