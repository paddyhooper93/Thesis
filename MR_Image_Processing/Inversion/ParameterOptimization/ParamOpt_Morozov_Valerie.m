%% Param_Opt_Morozov.m
% Finding the optimal lambda value, manually entering the cost_data values
% gathered in the output of the MEDI function.

%% 3T

clc
clearvars
close all

output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\DiscPrinc_2';

x=2:.5:5; lam_range=10.^(x);

cost_data = [ mean([13.57 13.16]), mean([7.99 7.69]), mean([4.58 4.40]), mean([3.17 2.50]), ...
    mean([1.62 1.55]), mean([0.91 0.87]), mean([0.65 0.61]) ]; % mean([1.22 1.17]), mean([0.87 0.82]),
% epsilon_3T = 1.55;
epsilon = 2.17/.66;
% Find optimal parameter using `pchip' interpolation
[cost_data_norm, lambdaInterp, lambdaCostInterp, lambdaOpt] = Morozov(lam_range, cost_data, epsilon);



    figure
    scatter(log(lam_range), log(cost_data_norm), 50, 'ko', 'filled', 'DisplayName', 'Original Data')
    hold on
    plot(log(lambdaInterp), log(lambdaCostInterp), 'LineWidth', 2, 'Color', [.6 0 0], 'DisplayName', 'Interpolated Data');
    hold on
    plot(log(lambdaOpt), log(1), 'ko', 'MarkerSize', 10, 'DisplayName', 'Optimal Lambda');
    hold on
    legend('show', 'Location', 'best')
    drawnow;
    xlabel('Log (Lambda)')
    % xticks(1e4.*[0 1 2 3 4])
    xticks('auto')
    xticklabels(compose("%.0f", xticks));
    ylabel('Log(Normalized residual)')
    % yticks([0 1 2 3 4])
    yticks('auto')

    yticklabels(compose("%1.1f", yticks));
    saveas(gcf, fullfile(output_dir, '3T_Lambda_Morozov.png'));

    % Optimal Lambda: 2200

%% 7T

clc
clearvars
close all

output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\DiscPrinc_2';


x=2:.5:5; lam_range=10.^(x);

cost_data = [ mean([34.04 34.85]), mean([20.17 20.20]), mean([12.14 11.78]), mean([7.3 6.94]),  ...
    mean([4.95 4.59]), mean([2.88 2.65]), mean([0.59 1.50]) ]; % mean([3.80 3.50]), mean([2.15 2.00])
% epsilon_7T = 3.49;
epsilon = 3.13/.66;
[cost_data_norm, lambdaInterp, lambdaCostInterp, lambdaOpt] = Morozov(lam_range, cost_data, epsilon);


    figure
    scatter(log(lam_range), log(cost_data_norm), 50, 'ko', 'filled', 'DisplayName', 'Original Data')
    hold on
    plot(log(lambdaInterp), log(lambdaCostInterp), 'LineWidth', 2, 'Color', [.6 0 0], 'DisplayName', 'Interpolated Data');
    hold on
    plot(log(lambdaOpt), log(1), 'ko', 'MarkerSize', 10, 'DisplayName', 'Optimal Lambda');
    hold on
    legend('show', 'Location', 'best')
    drawnow;
    xlabel('Log (Lambda)')
    % xticks(1e4.*[0 1 2 3 4])
    xticks('auto')
    xticklabels(compose("%.0f", xticks));
    ylabel('Log(Normalized residual)')
    % yticks([0 1 2 3 4])
    yticks('auto')

    yticklabels(compose("%1.1f", yticks));
    saveas(gcf, fullfile(output_dir, '7T_Lambda_Morozov.png'));

    % Optimal Lambda: 10200
