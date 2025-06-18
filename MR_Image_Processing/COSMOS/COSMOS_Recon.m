function [chi_cl, chi_wls, chi_tik] = COSMOS_Recon(deltaB, Mask_Use, R_tot, weights, voxel_size, optimise)
% [chi_cl, chi_wls, chi_tik, B0_deg, B0_vec] = COSMOS_Recon(deltaB, Mask_Use, R_tot, weights, voxel_size)
% Input vars:
% deltaB = Registered tissue fields (concatenated along dim4)
% R_tot = 3x3 rotation matrices (concatenated along dim4)
% Mask_Use = mask (reference orientation)
% weights = inverse fieldmap noise (reference orientation)
% voxel_size = resolution (mm per vox)

mosaic(-imrotate(mean(deltaB(15:end-15,:,60:5:end,:),4), -90), 2, 5, 1, 'Average Tissue Phase', [-.045,.045]);

%% Create susceptibility kernels for each orientation
N = size(Mask_Use);
[ky, kx, kz] = meshgrid(-N(2)/2:N(2)/2-1, -N(1)/2:N(1)/2-1, -N(3)/2:N(3)/2-1); % k-space grid

kx = (kx / max(abs(kx(:)))) / voxel_size(1);
ky = (ky / max(abs(ky(:)))) / voxel_size(2);
kz = (kz / max(abs(kz(:)))) / voxel_size(3);

kernel_denominator = kx.^2 + ky.^2 + kz.^2;

kernel = zeros(size(deltaB));
for t = 1:size(R_tot,3)
    kernel(:,:,:,t) = fftshift( 1/3 - (kx * R_tot(3,1,t) + ky * R_tot(3,2,t) + kz * R_tot(3,3,t)).^2 ./ (kernel_denominator + eps));
    
    mosaic(fftshift(kernel(:,:,:,t)), 8, 20, 2, ['Orientation: ', num2str(t)], [-2/3,1/3])
end

kernel_sum = fftshift(mean(abs(kernel), 4));
mosaic(squeeze(kernel_sum(1+end/2,:,:)), 1, 1, 3, 'Average Kernel', [0,2/3])

%% Closed-form solution
deltaB_Use = zeros(size(deltaB));
for t = 1:size(deltaB, 4)
    deltaB_Use(:,:,:,t) = fftn(deltaB(:,:,:,t));
end
kernel_sum = sum(abs(kernel).^2, 4);
chi_cl = real( ifftn( sum(kernel .* deltaB_Use, 4) ./ (kernel_sum + eps) ) ) .* Mask_Use ;
export_nii(chi_cl, 'test_chi_cl', voxel_size);
mosaic(imrotate(chi_cl(15:end-15,:,60:5:end), -90), 2, 5, 5, 'COSMOS\_CL', [-.14,.14]),

%% Weighted least-squares formulation

[chi_wls] = COSMOS_lsqr(deltaB_Use, kernel, weights, Mask_Use);

%% Tikhonov regularization

%% Optimizing lambda
lambda = [];
lambdaOptimal = zeros(size(R_tot,3));
if optimise
    for t = 1:size(R_tot,3)
        [~, lambdaOptimal(t)] = qsmClosedFormL2(deltaB(:,:,:,t), Mask_Use, N, voxel_size, 'optimise', optimise, 'b0dir', B0_vec);
        lambda = cat(2, lambda, lambdaOptimal(t));
    end
    lambda = mean(lambda,2);
else
    lambda = 0.05;
end
[chi_tik] = COSMOS_lsqr_Tik(deltaB_Use, kernel, weights, Mask_Use, lambda);


%% Apply the mask and bulk medium correction
% chi_cl = (chi_cl + -0.1106) .* Mask_Use;
% chi_wls = (chi_wls + -0.1106) .* Mask_Use;


%% Visualize the results
%mosaic( single(chi_wls), 12, 12, 19, 'QSM\_COSMOS\_WLS' )
%mosaic( single(chi_tik), 12, 12, 20, 'QSM\_COSMOS\_Tik')

end
