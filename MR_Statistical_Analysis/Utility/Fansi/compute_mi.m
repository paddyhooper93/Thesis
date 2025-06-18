function [ mi, sigma ] = compute_mi( chi_recon, chi_true )
% Calculates the Mutual Information index between two images.
%
% Based on the code by R. Moddemeijer, at http://www.cs.rug.nl/~rudy/matlab/
% Last modified by Carlos Milovic in 2017.03.30
%

[mi,nbias,sigma,descriptor]=information((chi_true(:))',chi_recon(:)');



end

