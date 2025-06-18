function [resnorm,residual] = NonLinearDataFidelityNorm(chi,localField,kernel)

residual = exp(1i*ifftn(kernel.*fftn(chi))) - exp(1i*localField);
resnorm = norm(residual(:),2);

end