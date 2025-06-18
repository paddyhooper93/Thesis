function [B0_dir] = ObtainFieldDirection(R_tot, N_orient)
% Input: 
%       R_tot: 3x3 rotation matrices, indexed at dim3 
%       N_orient: number of orientations
% Output: 
%       B0_dir: column vectors of B0 direction, index at dim2
B0_dir = zeros(3, N_orient);

for ndir = 1:N_orient
    % Project R_tot to original z-axis B0 (reference frame) using column vectors
    B0_dir(1:3, ndir) = R_tot(1:3, 1:3, ndir)' * [0 0 1]';
end



% Reshape each column vector into a row vector
% B0_dir = B0_dir'; 