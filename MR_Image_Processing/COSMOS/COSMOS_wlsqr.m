function [x_out] = COSMOS_wlsqr(Bi, Di, Wi, M, CSF_Mask, varargin)
% -----------------------
% x_out = COSMOS_wlsqr(Bi, Di, Wi, M, CSF_Mask, varargin);
% Input:
% Bi: tissue field in r-space, scaled to ppm units.
% Di: dipole kernel in k-space
% Wi: weighting matrix in r-space (multiplied by brain ROI mask)
% varargin: Optional parameters as name-value pairs,
% CSF_Mask, tol, maxit, isTik, lam_Tik, isCSF, lam_CSF
% Output:
% x_out: susceptibility map in r-space
% -----------------------
% The function solves the following problem:
%
% given the Fourier operator F and orientation index i,
% this function finds the susceptibility map x that minimizes:
% sum i=1:t || Wi(r) * F' Di(k) * F * x(r) - Bi(k) ||^2
%
%
% The optimization method used is the least squares algorithm
% -----------------------

[tol, maxit, isTik, lam_Tik, isCSF, lam_CSF, x0] = ...
    parse_COSMOS_input(varargin{:}); 

% Masks should be logical
CSF_Mask = CSF_Mask > 0;
M = M > 0;

% Compute b (real vector)
b = sum(Wi .* exp(1i*Bi), 4);
b = real(b(:));

% Compute x0 (real vector)
if isempty(x0)
    x0 = zeros(size(Wi, [1,2,3]));
end 
x0 = x0(:);




% Create function handle for matrix-vector multiplication
Afun = @(x, transp_flag) afun(x, transp_flag, Wi, Di, M, CSF_Mask, isTik, lam_Tik, isCSF, lam_CSF); %

try
    iter_c = 0;
    [x_vec, flag, relres, iter] = lsqr(Afun, b, tol, maxit, [], [], x0); %
    switch flag
        case 0
            fprintf('\n LSQR converged to the desired TOL within MAXIT iterations. \n');
        case 1
            fprintf('\n LSQR iterated MAXIT times but did not converge. \n');
        case 2
            fprintf('\n LSQR preconditioner was ill-conditioned. \n');
        case 3
            fprintf('\n LSQR stagnated (two consecutive iterates were the same). \n');
        case 4
            fprintf('\n LSQR: one of the scalar quantities calculated during LSQR became too small or too large to continue computing. \n');
    end
    
    fprintf('\n LSQR iter: %d, LSQR residual: %.3f \n', iter, relres);
catch ME
    fprintf('\n Error in lsqr execution: \n');
    disp(ME.message);
    rethrow(ME);
end


% Reshape output to match input dimensions
x_out = reshape(real(x_vec), size(M));

% Nested function for LSQR
    function y = afun(x, transp_flag, Wi, Di, M, CSF_Mask, isTik, lam_Tik, isCSF, lam_CSF) 
        assert(numel(x) == numel(M), '\n Cannot reshape x to the size of M. \n');
        dims = size(M);
        x = reshape(x, dims);
        if strcmp(transp_flag,'notransp')
            % Forward operation: y = A * x
            y = sum( Wi .* exp(1i*ifftn(Di .* fftn( x ))), 4);

            if isTik
                y = y + lam_Tik .* x;
            end

            if isCSF
                y_reg = CSF_Mask .* (x - mean(x(CSF_Mask)));
                y = y + lam_CSF .* (y_reg - mean(y_reg(CSF_Mask)));
            end
            
            % Return y as a real vector
            y = real(y(:));
            
        else
            % Adjoint operation: y = A' * x
            y = sum( Wi .* exp(1i*ifftn(conj(Di) .* fftn(x))) , 4);

            if isTik
                y = y + lam_Tik .* x;
            end            

            if isCSF
                y_reg = CSF_Mask .* (x - mean(x(CSF_Mask)));
                y = y + lam_CSF .* (y_reg - mean(y_reg(CSF_Mask)));
            end
            % Return y as a real vector
            y = real(y(:));
            
            % Update iter count
            iter_c = iter_c + 1;
            if mod(iter_c, 10) == 0
                fprintf('\n iteration: %d ... \n', iter_c);
            end
        end
        
        
    end

end