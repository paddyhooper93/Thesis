function [angle_about_kz] = calculate_kz_angle(theta, psi)
    % theta = rotation about (reference) x-axis
    % psi = rotation about (reference) y-axis
    % output = rotation about (reference) z-axis

    % Convert to radians
    theta_rad = deg2rad(theta);
    psi_rad = deg2rad(psi);

    % Rotation matrices
    R_x = [1, 0, 0; 
           0, cos(theta_rad), -sin(theta_rad); 
           0, sin(theta_rad), cos(theta_rad)];
    
    R_y = [cos(psi_rad), 0, sin(psi_rad); 
           0, 1, 0; 
           -sin(psi_rad), 0, cos(psi_rad)];
    
    % Combined rotation matrix
    R = R_x * R_y;

    % Extract z-axis rotation using arctan2
    angle_about_kz = atan2(-R(2,1), R(1,1));
    angle_about_kz = rad2deg(angle_about_kz);
end
