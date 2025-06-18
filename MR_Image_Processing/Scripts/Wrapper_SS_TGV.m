function [QSM] = Wrapper_SS_TGV(iFreq_ppm, Mask_Use, hdr, alpha1, mu0)
% Birkin Bilgic's SS_TGV_QSM_Toolbox, see functions:
% create_dipole_kernel, create_SMVkernel, SS_TGV_QSM
% Reference: Table 1, pp. e3570 "Single-step quantitative susceptibility mapping with
% variational penalties" Chatnuntawech et al., 2017 NMR in Biomed.

% Aug Lagrangian param:
if nargin < 5
    mu0 = 1e-1; % in vivo data
end

% Regularization parameter:
if nargin < 4
    if hdr.FS == 3
        % alpha1 = 2.69e-4; % Multi-Echo Wave-CAIPI @ 3 T
        alpha1 = 5.46e-3; % 3D EPI @ 3 T
    elseif hdr.FS == 7
        alpha1 = 7e-3;    % Single-Echo Wave-CAIPI @ 7 T
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
step_size_radius = 1;
max_radius = 5;

out = create_SMVkernel(phase_total, chi_mask, min_radius, max_radius, step_size_radius, N, voxel_size);

SMV_kernels = out.SMV_kernel;
SMV_masks = out.SMV_mask;
mask_Sharp = out.mask_eval;

%% Single-step TGV QSM
params = [];
params.alpha0 = 2*alpha1;           % Regularization param for ||Ev||_1
params.alpha1 = alpha1;             % Regularization param for ||Gx-v||_1
params.mu0 = mu0;                   % Aug Lagrangian param for z0 = Ev
params.mu1 = params.mu0;            % Aug Lagrangian param for z1 = Gx
params.mu2 = params.mu0;            % Aug Lagrangian param for z2 = HDFx
params.maxOuterIter = 100;          % Max number of iter
params.tol_soln = 1;                % Stopping criterion: RMSE change in solution
params.N = N;                       % Number of voxels
params.M = SMV_masks;               % Mask for each reliable region
params.H = SMV_kernels;             % SMV kernels
params.D = D;                       % Dipole kernel
params.phase_unwrap = phase_total;  % Unwrapped total phase

out_ss_tgv = SS_TGV_QSM(params);

chi_ss_tgv = mask_Sharp .* out_ss_tgv.x;

chi_ss_tgv_0mean = zeros(N);
chi_ss_tgv_0mean(mask_Sharp==1) = chi_ss_tgv(mask_Sharp==1) - mean(chi_ss_tgv(mask_Sharp==1));

QSM = chi_ss_tgv_0mean;
