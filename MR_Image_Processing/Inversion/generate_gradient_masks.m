function [fdx, fdy, fdz, E2, magn_weight] = generate_gradient_masks(iMag, Mask_Use)
%% gradient masks from magnitude image using k-space gradients

N = size(Mask_Use);

[k2,k1,k3] = meshgrid(0:N(2)-1, 0:N(1)-1, 0:N(3)-1);
fdx = 1 - exp(-2*pi*1i*k1/N(1));
fdy = 1 - exp(-2*pi*1i*k2/N(2));
fdz = 1 - exp(-2*pi*1i*k3/N(3));

E2 = abs(fdx).^2 + abs(fdy).^2 + abs(fdz).^2; 

% Normalize between 0 and 1, and apply FFT to get k-space
magn_ksp = fftn( iMag / max(iMag(:)) );
% Generate a gradient image for each direction
magn_grad = cat(4, ifftn(magn_ksp.*fdx), ifftn(magn_ksp.*fdy), ifftn(magn_ksp.*fdz));

magn_weight = zeros(size(magn_grad));

for s = 1:size(magn_grad,4)
    magn_use = abs(magn_grad(:,:,:,s));
    
    magn_order = sort(magn_use(Mask_Use==1), 'descend');
    magn_threshold = magn_order( round(length(magn_order) * .3) );
    magn_weight(:,:,:,s) = magn_use <= magn_threshold;

    plot_axialSagittalCoronal(magn_weight(:,:,:,s), s, [0,.1], '')
end