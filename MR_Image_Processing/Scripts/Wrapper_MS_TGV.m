function [QSM] = Wrapper_MS_TGV(iFreq_ppm, Mask_Use, hdr, alpha1, mu0)
% Birkin Bilgic's SS_TGV_QSM_Toolbox, see functions:
% create_dipole_kernel, create_SMVkernel, SS_TGV_QSM
% Reference: Table 1, pp. e3570 "Single-step quantitative susceptibility mapping with
% variational penalties" Chatnuntawech et al., 2017 NMR in Biomed.

if nargin < 5
    % Aug Lagrangian param: always the same for in vivo data.
    mu0 = 3e-2; % Numberical brain phantom
end

if nargin < 4
    if hdr.FS == 3
        alpha1 = 2e-4; % Numerical brain phantom
    elseif hdr.FS == 7
        alpha1 = 2e-4; % Numerical brain phantom
    end
end

chi_mask = Mask_Use;
phase_total = iFreq_ppm;
B0_dir = [0 0 -1];
voxel_size = hdr.voxel_size;
N = hdr.matrix_size;


%% dipole kernel
D = create_dipole_kernel(B0_dir, voxel_size, N, 1);

%% Generate SMV kernels and masks
min_radius = 1;
max_radius = 5;
step_size_radius = 1;

out = create_SMVkernel(phase_total, chi_mask, min_radius, max_radius, step_size_radius, N, voxel_size);

SMV_inv_kernel = out.SMV_inv_kernel;
SMV_phase = out.SMV_phase;
mask_Sharp = out.mask_eval;

%% Inverse V-SHARP
SMV_thres = 2e-2;

SMV_inv_kernel_temp = zeros(N);
SMV_inv_kernel_temp( abs(SMV_inv_kernel) > SMV_thres ) = 1 ./ SMV_inv_kernel( abs(SMV_inv_kernel) > SMV_thres );

phase_inv_Sharp = mask_Sharp .* ifftn(SMV_inv_kernel_temp .* fftn(SMV_phase));

%% Multiple-step TGV QSM
params = [];
params.alpha1 = alpha1;                   % Regularization param for ||Gx-v||_1
params.alpha0 = 2 * params.alpha1;      % Regularization param for ||Ev||_1
params.mu1 = mu0;                      % Aug Lagrangrian param for z1 = Gx-v
params.mu0 = params.mu1;                % Aug Lagrangrian param for z0 = Ev
params.maxOuterIter = 50;               % Max number of iterations
params.tol_update = 1;                  % Stopping criterion: RMSE change in solution
params.N = N;                           % Number of voxels
params.kspace = fftn(phase_inv_Sharp);  % DTFT of V-SHARP filtered phase
params.D = D;                           % Dipole kernel

out_ms_tgv = MS_TGV_QSM(params);

chi_ms_tgv = out_ms_tgv.x .* mask_Sharp;
chi_ms_tgv_0mean = zeros(N);
chi_ms_tgv_0mean(mask_Sharp==1) = chi_ms_tgv(mask_Sharp==1) - mean(chi_ms_tgv(mask_Sharp==1));


QSM = chi_ms_tgv_0mean;
