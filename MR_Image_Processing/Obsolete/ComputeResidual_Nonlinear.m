function [resnorm, residual] = ComputeResidual_Nonlinear(x,Delta,D,W,M)

residual = W .* exp(1i*real(ifftn(D .* fftn( x )))) - ( W .* exp(1i*Delta) );
if nargin < 5
    resnorm = norm(residual(:),2);
else
    resnorm = norm(residual(M>0),2);
end

end

