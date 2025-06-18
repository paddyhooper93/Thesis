function [angle_z] = kz_angle_from_two_axis_rotations(angle_x, angle_y)
% angle_x = rotation about x-axis (degrees)
% angle_y = rotation about y-axis (degrees)
% angle_z = net rotation about z (degrees)

% Ensure input is the same length
if length(angle_x) ~= length(angle_y)
    error('angle_x and angle_y must have the same length.');
end

% Convert to radians
angle_x_rad = deg2rad(angle_x);
angle_y_rad = deg2rad(angle_y);

% Calculate numerator and denominator
numerator = sqrt(cos(angle_x_rad)^2 * sin(angle_y_rad)^2 + sin(angle_x_rad)^2);
denominator = cos(angle_x_rad) * cos(angle_y_rad);
if abs(denominator) < eps
    denominator = sign(denominator) * eps; % Preserve sign and use small epsilon
end
% Calculate z-axis angle
angle_z = round(atan2d(numerator, denominator)); % atan2d: "atan2 + rad2deg"

end