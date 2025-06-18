function [resnorm,residual] = DataFidelityNorm(chi,localField,kernel)

residual = ifftn(kernel.*fftn(chi)) - localField;
resnorm = norm(residual(:),2);

end