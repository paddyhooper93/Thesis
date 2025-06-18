% Test cases
cases = [20, 0; -10, 17; -10, -17];
expected_results = [20, 20, -20]; % Expected z-axis angles

% Verify Method1
disp('Method1 Results:');
for i = 1:size(cases, 1)
    theta = cases(i, 1);
    psi = cases(i, 2);
    angle_z = kz_angle_from_two_axis_rotations(theta, psi);
    fprintf('Case %d: theta = %d, psi = %d, angle_z = %.2f (Expected: %d)\n', ...
        i, theta, psi, angle_z, expected_results(i));
end

% Verify Method2
disp('Method2 Results:');
for i = 1:size(cases, 1)
    theta = cases(i, 1);
    psi = cases(i, 2);
    angle_z = calculate_kz_angle(theta, psi);
    fprintf('Case %d: theta = %d, psi = %d, angle_z = %.2f (Expected: %d)\n', ...
        i, theta, psi, angle_z, expected_results(i));
end

% Verify Method3
disp('Method3 Results:');
for i = 1:size(cases, 1)
    theta = cases(i, 1);
    psi = cases(i, 2);
    angle_z = angle_within_xy_plane(theta, psi);
    fprintf('Case %d: theta = %d, psi = %d, angle_z = %.2f (Expected: %d)\n', ...
        i, theta, psi, angle_z, expected_results(i));
end
