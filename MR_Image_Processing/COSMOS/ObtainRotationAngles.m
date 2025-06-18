function [Theta_x, Theta_y, Theta_B0] = ObtainRotationAngles(R_tot, N_orient)

B0_dir = zeros(3, size(R_tot, 3));
Theta_B0 = zeros(1, size(R_tot, 3));
Theta_x = zeros(1, size(R_tot, 3));
Theta_y = zeros(1, size(R_tot, 3));
Theta_z = zeros(1, size(R_tot, 3)); % Nil effect on dipole kernel
Theta_xy = zeros(1, size(R_tot, 3));

for ndir = 1:N_orient
    % Project R_tot to original z-axis B0 (reference frame) using vector
    B0_dir(:, ndir) = R_tot(1:3, 1:3, ndir)' * [0 0 1]';
    % Obtain angle the projected vector makes with B0
    Theta_B0(ndir) = acos( B0_dir(3, ndir) );
    % Obtain angle about x- and y- axes
    epsilon = 1e-6;
    if abs(R_tot(3,1,ndir)) < (1 - epsilon)
        Theta_z(ndir) = atan2(R_tot(2,1), R_tot(1,1));
        Theta_y(ndir) = asin( -R_tot(3, 1, ndir) );
        Theta_x(ndir) = atan2( R_tot(3, 2, ndir), R_tot(3, 3, ndir) );
    else
        % Gimbal lock occurs
        Theta_z(ndir) = atan2(-R_tot(1,2), R_tot(2,2));
        Theta_y(ndir) = pi/2 * sign(-R(3, 1, ndir));
        Theta_x(ndir) = 0;
    end
    
    
    % Theta_xy (same as Theta_B0: combined effect of x- and y-axis rotations)
    Theta_xy(ndir) = atan2(sqrt(cos(Theta_x(ndir))^2 * ...
        sin(Theta_y(ndir))^2 + sin(Theta_x(ndir))^2) , ...
        (cos(Theta_x(ndir))*cos(Theta_y(ndir))));
    
    
    % disp('\n');
end


%C = zeros(size(deltaB));
%for t = 1:length(Theta_x)
%    C(:,:,:,t) = 1/3 ...
%        - (kz * cos(Theta_x(t)) * cos(Theta_y(t)) ...
%        + ky * sin(Theta_x(t)) * cos(Theta_y(t)) ...
%        - kx * sin(Theta_y(t)) ).^2 ./  ...
%        (k2 + eps) ;
%end

%C_rss = sqrt(sum((C .^2), 4));
%kappa = max(C_rss(:)) ./ min(C_rss(:));

%fprintf('Condition number (Kappa) using dual-axis method: %.1f \n\n', kappa);

end