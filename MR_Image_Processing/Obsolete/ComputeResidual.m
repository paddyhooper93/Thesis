%% [resnorm, residual] = ComputeResidual(x,RDF,D,W)
%
% Description: compute the residual and residual norm given the local
%              field, dipole kernel and QSM
%
function [resnorm, residual] = ComputeResidual(x,Delta,D,W,M)

residual = W .* (real(ifftn(D .* fftn(x))) - Delta);
if nargin < 5
    resnorm = norm(residual(:),2);
else
    resnorm = norm(residual(M>0),2);
end