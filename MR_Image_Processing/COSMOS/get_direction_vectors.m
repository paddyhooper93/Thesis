%% create direction vectors for each orientation

function [B0vec, Theta_B0, Theta_xy, Theta_x_rad, Theta_y_rad] = get_direction_vectors(R_tot)

% Initialize B0_deg and B0vec for reference frame
% B0vec = zeros(3, size(R_tot,3));
% Theta_x = zeros(size(R_tot,3));
% Theta_y = zeros(size(R_tot,3));
% Theta_z = zeros(size(R_tot,3));
% Theta_B0 = zeros(size(R_tot,3));

for ndir = 1:size(R_tot, 3)
    % Vector about B0 (reference frame)
    B0vec(:, ndir) = R_tot(1:3,1:3, ndir)' * [0;0;1]; % Converts rotation matrix "R_tot" into a vector relative to B0.
    % Theta_B0 
    Theta_B0(ndir) = acosd( B0vec(3, ndir));     
    % Theta_x
    Theta_x(ndir) = atan2d( R_tot(3, 2, ndir), R_tot(3, 3, ndir));
    Theta_x_rad(ndir) = deg2rad(Theta_x(ndir));
    % Theta_y
    Theta_y(ndir) = asind( -R_tot(3, 1, ndir));
    Theta_y_rad(ndir) = deg2rad(Theta_y(ndir));
    % Theta_xy -> different formula to calculate Theta_B0
    Theta_xy(ndir) = atan2d(sqrt(cos(Theta_x_rad(ndir))^2 * sin(Theta_y_rad(ndir))^2 + sin(Theta_x_rad(ndir))^2) , ... 
                     (cos(Theta_x_rad(ndir))*cos(Theta_y_rad(ndir))));
    
    
    % Theta_z => not relevant since parallel to B0
    % Theta_z(ndir) = atand( R_tot(2, 1, ndir) / R_tot(1, 1, ndir));

    % figure(20), hold on, plot3(linspace(0, B0vec(1), 100), linspace(0, B0vec(2), 100), linspace(0, B0vec(3), 100), 'color', rand(3,1))
    % grid on, title('Direction vectors')
    fprintf('Acquisition %i : %.1f %.1f %.1f %.1f %.1f deg \n\n', ndir, Theta_B0(ndir), Theta_xy(ndir), Theta_x(ndir), Theta_y(ndir), Theta_z(ndir));
end

% figure(21), plot(B0_deg, 'marker', '*'), axis tight, title('Degrees of rotation')