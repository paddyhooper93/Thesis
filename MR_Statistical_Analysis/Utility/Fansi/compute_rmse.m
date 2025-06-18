function [ rmse ] = compute_rmse( chi_recon, chi_true, mask )
% Calculates the L2 norm of the difference between two images
%
% Last modified by Carlos Milovic in 2017.03.30
%

if nargin < 3
    mask = ones(size(chi_recon));
end


chi_recon = chi_recon .* mask;
chi_true = chi_true .* mask;

rmse = 100 * norm( chi_recon(:) - chi_true(:) ) / norm(chi_true(:));


end

