function [D, kappa] = kernel_COSMOS(N, vsz, num_orient, B0_dir, flag_viewkernel)
% Create dipole kernel in k-space, and returns the condition number
% 
% ------------------
% Inputs:
%       N: matrix size
%       num_orient: number of orientations
%       R_tot: 3x3 rotation matrices, indexed to dim3
%       vsz: mm per voxel
% ------------------
% Outputs:
%       D: kernel in k-space
%       kappa: condition number (conditioning of inverse problem), ...
%               ideally, kappa is minimized (~ 2.5 - 3.5 is feasible).

% [N, vsz, num_orient, R_tot, B0_dir, flag_viewkernel] = parse_inputs(varargin{:});

% k-space grid
fprintf('\n Dipole kernel created directly in k-space \n')
[ky, kx, kz] = meshgrid(-N(2)/2:N(2)/2-1, ...
    -N(1)/2:N(1)/2-1, ...
    -N(3)/2:N(3)/2-1);

kx = (kx / max(abs(kx(:)))) /vsz(1);
ky = (ky / max(abs(ky(:)))) /vsz(2);
kz = (kz / max(abs(kz(:)))) /vsz(3);

k2 = kx.^2 + ky.^2 + kz.^2;

% Project the kernel onto B0 by selecting the 3rd row in the R matrix
% i.e. R_31, R_32, R_33, i.e. B0vec_11, B0vec_21, B0vec_31
D = zeros([N, num_orient]);

for t = 1:num_orient
%       

    % if 1~=exist("B0_dir", "var")
        % B0_dir: column vectors of B0 direction, indexed to dim 2
        D(:,:,:,t) = fftshift( 1/3 - ( kx*B0_dir(1,t) + ky*B0_dir(2,t) + kz*B0_dir(3,t) ).^2 ./ (k2 + eps));
    % elseif 1~=exist("R_tot", "var")
        % R_tot: 3x3 rotation matrix, indexed to dim 3
        % D(:,:,:,t) = fftshift( 1/3 - ( kx*R_tot(3,1,t) + ky*R_tot(3,2,t) + kz*R_tot(3,3,t) ).^2 ./ (k2 + eps));
    % end
    % D(isnan(D)) = 0;
    % D(:,:,:,t) = fftshift(D(:,:,:,t));
    % fftshift: shifts the centre of k-space to matrix corners

   
    % Visualization 
    if flag_viewkernel
        mosaic(fftshift(D(:, :, 1+end/2, t)), 1, 1, t+10, ['Kernel, XY plane, Orientation: ', num2str(t)], [-2/3,1/3])
    end
end

% Condition number (Kappa)
C_rss = sqrt(sum((D .^2), 4));
kappa = max(C_rss(:)) ./ min(C_rss(:));


% View the mean kernel
D_mean = fftshift(mean(abs(D), 4));
if flag_viewkernel
    mosaic(squeeze(D_mean(:, :, 1+end/2)), 1, 1, 100, 'Average Kernel, XY plane', [0 , 2/3])
end
% mosaic(squeeze(kernel_mean(:, 1+end/2, :)), 1, 1, 102, 'Average Kernel, XZ plane', [0 , 2/3])

% function [N, vsz, num_orient, R_tot, B0_dir, flag_viewkernel] = parse_inputs(varargin)
% 
%     if size(varargin,2)<4
%         error('At least four inputs are required');
%     end
% 
%     N = varargin{1};
%     vsz = varargin{2};
%     num_orient = varargin{3};
%     R_tot = [];
%     B0_dir = [];
%     flag_viewkernel = false;
% 
% 
%     if size(varargin,2)>3
%         for k=4:size(varargin,2)
%             if strcmpi(varargin{k},'R_tot')
%                 R_tot = varargin{k+1};
%             end
%             if strcmpi(varargin{k},'B0_dir')
%                 B0_dir = varargin{k+1};
%             end
%             if strcmpi(varargin{k},'flag_viewkernel')
%                 flag_viewkernel = varargin{k+1};
%             end
%         end
%     end
% 
% end


%% Susceptibility gradients

% [k2,k1,k3] = meshgrid(0:N(2)-1, 0:N(1)-1, 0:N(3)-1);
% fdx = 1 - exp(-2*pi*1i*k1/N(1));
% fdy = 1 - exp(-2*pi*1i*k2/N(2));
% fdz = 1 - exp(-2*pi*1i*k3/N(3));

end