function [chi_STI] = get_scalar_STI_from_tensor(chi_res, M, voxel_size)
% projects anisotropic components from STI tensor to obtain scalar STI

%% Susceptibility tensor components
chi_13 = chi_res(:,:,:,3);
chi_23 = chi_res(:,:,:,5);
chi_33 = chi_res(:,:,:,6);

%% Dipole Kernel
N = size(M);
[~,dKComponents]    = DipoleKernel(N,voxel_size);
kx = dKComponents.kx;
ky = dKComponents.ky;
kz = dKComponents.kz;
k2 = dKComponents.k2;

%% Equation (2) in doi: 10.1002/mrm.28185
%chi_STI_ill_posed = chi_33 + ifftn( (-kz/k2-3*kz^2) .*(kx*fftn(chi_13)+ky*fftn(chi_23)) );

term = -kz./(k2-3*kz.^2);

% Set threshold using value set in doi: 10.1002/mrm.28185
thresh_tkd = 0.3;
% initiate inverse kernel with zeros
term_inv = zeros(N, 'like', N);
% get the inverse only when value > threshold
term_inv( abs(term) > thresh_tkd ) = 1 ./ term( abs(term) > thresh_tkd);


chi_anisotropic_corr = ifftn( (term_inv) .*(kx.*fftn(chi_13)+ky.*fftn(chi_23)) );

chi_STI = (chi_33 + real(chi_anisotropic_corr)) .* M;
