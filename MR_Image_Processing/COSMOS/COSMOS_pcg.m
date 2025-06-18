%% L2-regularized solution with magnitude weighting (lambda_L2 = 0.05)
[fdx, fdy, fdz, E2, magn_weight] = generate_gradient_masks(iMag, BET_Mask);
lambda_L2 = 0.05;
A_frw = D2 + lambda_L2 * E2;
A_inv = 1 ./ (eps + A_frw);

% b = sum(D.*deltaB_fft, 4);
b = sum(conj(D) .* deltaB_fft, 4);

precond_inverse = @(x, A_inv) A_inv(:).*x;

% F_chi0 = fftn(chi_WLS);      % use close-form L2-reg. solution as initial guess
% F_chi0 = fftn(chi_L2);


tic
    [F_chi, ~, pcg_res, pcg_iter] = pcg(@(x) apply_forward(x, D2, lambda_L2, fdx, fdy, fdz, ...
            conj(fdx), conj(fdy), conj(fdz), magn_weight), b(:), 1e-6, 100, @(x) precond_inverse(x, A_inv));
toc

disp(['PCG iter: ', num2str(pcg_iter), '   PCG residual: ', num2str(pcg_res)])


Chi = reshape(F_chi, size(BET_Mask));

chi_L2pcg = real(ifftn(Chi)) .* BET_Mask;

plot_axialSagittalCoronal(chi_L2pcg, 2, [-.15,.15], 'L2 Magnitude Weighted')
plot_axialSagittalCoronal(fftshift(abs(fftn(chi_L2pcg))).^.5, 12, [0,20], 'L2 Magnitude Weighted k-space')

    chi_L2pcg = (chi_L2pcg + -0.1106) .* BET_Mask;
    [ chi_L2pcg ] = pad_or_crop_target_size(chi_L2pcg, voxel_size);
    export_nii(chi_L2pcg, fullfile(output_dir, [FS_str{1}, '_chi_L2pcg']), voxel_size);


kspace_L2pcg = log( fftshift(abs(fftn(chi_L2pcg))) );

figure(37), subplot(1,3,1), imagesc( kspace_L2pcg(:,:,1+end/2), scale_log ), axis square off, colormap gray
figure(37), subplot(1,3,2), imagesc( squeeze(kspace_L2pcg(:,1+end/2,:)), scale_log ), axis square off, colormap gray
figure(37), subplot(1,3,3), imagesc( squeeze(kspace_L2pcg(1+end/2,:,:)), scale_log ), axis square off, colormap gray