    %% Iterative STI recon with LSQR
    
    for FS_str = {'3T', '7T'}

    % Load vars from MAT file
    input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\COSMOS_SNRwAVG_PDF\Num_Orient_6';
    matfile = fullfile(input_dir, [FS_str{1}, '_COSMOS_6_inputVars.mat'] );
    load(matfile, "M", "B", "R_tot", "voxel_size");
    M=pad_or_crop_target_size(M, voxel_size);
    B=pad_or_crop_target_size(B, voxel_size);

    % Set output dir
    output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\COSMOS_SNRwAVG_PDF\STI';
    if 7~=exist("output_dir", "dir")
        mkdir(output_dir);
        cd(output_dir);
    end
    
    %% Creating direction vectors
    H_Matrix = zeros(size(R_tot,3), 3);
    num_orient_STI = 6;
    for ndir = 1:num_orient_STI      
        H_Vec = R_tot(1:3, 1:3, ndir)' * [0 0 1]';
        H_Matrix(ndir, :) = H_Vec;
    end

    %% k-space grid
    N = size(M);
    
    [ky, kx, kz] = meshgrid(-N(2)/2:N(2)/2-1, ...
        -N(1)/2:N(1)/2-1, ...
        -N(3)/2:N(3)/2-1);
    
    kx = fftshift(kx);      ky = fftshift(ky);      kz = fftshift(kz);

    %% Pre-computing FFT of local field for efficiency
    B_ksp = zeros(size(B));
    
    for dir_idx = 1:num_orient_STI
        B_ksp(:,:,:,dir_idx) = fftn(B(:,:,:,dir_idx));
    end

    %% Obtaining eigenvalues using LSQR solver

    param = [];
    param.SS = N;
    param.N_direction = num_orient_STI;
    param.H_Matrix = H_Matrix;
    param.kx = kx;      param.ky = ky;      param.kz = kz;
    param.k2 = kx.^2 + ky.^2 + kz.^2;
    lsqr_tol = 1e-2;                            % LSQR tolerance
    lsqr_iter = 1000;                             % no of LSQR iterations

    tic
    [res, flag, relres, iter] = lsqr(@apply_STI, B_ksp(:), lsqr_tol, lsqr_iter, [], [], [], param);
    disp(['Flag: ', num2str(flag), '  Relres: ', num2str(relres), '  Iter: ', num2str(iter)])
    toc



    Fchi_res = reshape(res, [N,6]);             % susceptibility tensor in k-space
    chi_res = zeros(size(Fchi_res));

    for dir_idx = 1:num_orient_STI
        chi_res(:,:,:,dir_idx) = real( ifftn(Fchi_res(:,:,:,dir_idx)) ) .* M;             % susceptibility tensor in image space
    end
    
    %% Compute eigenvalues at each voxel
    
    Chi_tensor = zeros([N, 3, 3]);
    Chi_tensor(:,:,:,1,1) = chi_res(:,:,:,1);
    Chi_tensor(:,:,:,1,2) = chi_res(:,:,:,2);
    Chi_tensor(:,:,:,2,1) = chi_res(:,:,:,2);
    Chi_tensor(:,:,:,1,3) = chi_res(:,:,:,3);
    Chi_tensor(:,:,:,3,1) = chi_res(:,:,:,3);
    Chi_tensor(:,:,:,2,2) = chi_res(:,:,:,4);
    Chi_tensor(:,:,:,2,3) = chi_res(:,:,:,5);
    Chi_tensor(:,:,:,3,2) = chi_res(:,:,:,5);
    Chi_tensor(:,:,:,3,3) = chi_res(:,:,:,6);
    
    mask_tensor = M(:);
    
    Chi_tensor = permute(Chi_tensor, [4,5,1,2,3]);
    chi_tensor = reshape(Chi_tensor, [3,3, numel(mask_tensor)]);
    
    Chi_eig = zeros(numel(mask_tensor),3);
    
    tic
        for v = 1:length(mask_tensor)
            if mask_tensor(v) ~= 0
                [~,eigenvalues_diag] = eig(chi_tensor(:,:,v));
                Chi_eig(v,:) = diag(eigenvalues_diag)';
            end
        end
    toc
    
    Chi_eig = reshape(Chi_eig, [N, 3]);
    
    MMS = mean(Chi_eig,4);
    MSA = Chi_eig(:,:,:,3) - (Chi_eig(:,:,:,1) + Chi_eig(:,:,:,2)) / 2;
    MMS = (MMS + -0.1106) .* M;
    MMS = pad_or_crop_target_size(MMS, voxel_size);
    MSA = pad_or_crop_target_size(MSA, voxel_size);
    
    
    export_nii(MMS, fullfile(output_dir, [FS_str{1}, '_MMS_STI', num2str(num_orient_STI), '_Orient']), voxel_size);
    export_nii(MSA, fullfile(output_dir, [FS_str{1}, '_MSA_STI', num2str(num_orient_STI), '_Orient']), voxel_size);
    export_nii(chi_res, fullfile(output_dir, [FS_str{1}, '_chi_res_STI', num2str(num_orient_STI), '_Orient']), voxel_size);
    export_nii(Chi_eig, fullfile(output_dir, [FS_str{1}, '_Chi_eig_STI', num2str(num_orient_STI), '_Orient']), voxel_size);

    end