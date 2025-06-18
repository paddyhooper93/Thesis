%% Param_Opt_Morozov.m
% Finding the optimal lambda value, manually entering the cost_data values
% gathered in the output of the MEDI function.

%% 3T

clc
clearvars
close all

output_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\Morozov_2';

x=2:.5:5; lam_range=10.^(x);

cost_data = [ mean([11.64]), mean([6.73]), mean([4.96]), mean([2.23]), ...
    mean([1.64]), mean([0.95]), mean([0.66]) ];
epsilon = 4.32;
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

output_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\Morozov_2';


x=2:.5:5; lam_range=10.^(x);

cost_data = [ mean([45.44]), mean([26.52]), mean([15.88]), mean([10.80]),  ...
    mean([7.88]), mean([5.76]), mean([2.46]) ]; % mean([3.80 3.50]), mean([2.15 2.00])
epsilon = 8.04;
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
