function [x_out] = COSMOS_cgs(B, D, W, M, varargin)
% x_out = COSMOS_cgs(B, D, W, M, varargin);
% Input:
% B: tissue field in k-space, scaled to ppm units.
% D: dipole kernel
% W: weighting matrix
% M: brain ROI mask
% varargin: Optional parameters as name-value pairs,
% CSF_Mask, tol, maxit, isTik, lam_Tik, isCSF, lam_CSF
% Output:
% x_out: susceptibility map
% -----------------------
% General CGS method
% argmin (A*x - b)
% Weighted least-squares formulation: COSMOS
% argmin i=1:t || W * (F' * D * F * (chi) - B )||
% -----------------------

[tol, maxit, isTik, lam_Tik, isCSF, lam_CSF, CSF_Mask, x0] = ...
    parse_COSMOS_input(varargin{:});

% Compute b (real vector)
b = sum(W.*real(ifftn(B)),4);
b = b(:);


% Create function handle for matrix-vector multiplication
Afun = @(x, transp_flag) afun(x, W, D, M, CSF_Mask);

try
    tic
    % iter_c = 0;
    [x_vec, relres, iter] = cgsolve(Afun, b, tol, maxit, 1, x0);    
    disp(['CGS iter: ', num2str(iter), 'CGS residual: ', num2str(relres)]);
    toc
catch ME
    disp('Error in cgs execution:');
    disp(ME.message);
    rethrow(ME);
end

% Reshape output to match input dimensions
x_out = reshape(x_vec, size(M)) .* M;

% Nested function for CGS
    function y = afun(x, W, D, M, CSF_Mask)
        dims = size(M);
        x = reshape(x, dims);
        % y = sum( W .* real(ifftn(D .* fftn( x ))), 4);
        y = sum( W .* real(ifftn(conj(D)) .* x ), 4);
        if isTik
            y = y + lam_Tik * x;
        elseif isCSF
            CSF_Mask = reshape(CSF_Mask, size(x)) > 0;
            y = y + lam_CSF * (CSF_Mask .* (x - mean( x ( CSF_Mask))));
        end
        y = y(:);
        % iter_c = iter_c + 1;
        % if mod(iter_c, 10) == 0
        %     disp(['iteration: ', num2str(iter_c), '...']);
        % end
    end

end
