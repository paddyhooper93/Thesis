function [angle_z] = angle_within_xy_plane(angle_x, angle_y)
% angle_x = rotation about x-axis (degrees)
% angle_y = rotation about y-axis (degrees)
% angle_z = net rotation about z (degrees)

% Ensure input is the same length
if length(angle_x) ~= length(angle_y)
    error('angle_x and angle_y must have the same length.');
end

% Convert angles to radians
angle_x_rad = deg2rad(angle_x);
angle_y_rad = deg2rad(angle_y);

% Calculate z-axis angle
angle_z_rad = atan(tan(angle_y_rad) / tan(angle_x_rad));

% Magnitude and direction of the angle
% angle_z_rad = atan2(sin(angle_x), cos(angle_x) * cos(angle_y));

% Convert to degrees
angle_z = rad2deg(angle_z_rad);

end