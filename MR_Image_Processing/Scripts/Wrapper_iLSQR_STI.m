function [chi] = Wrapper_iLSQR_STI(RDF, mask, delta_TE, params)

if nargin < 4
    params.Kthreshold   = 0.25;
    params.niter        = 100;
    params.tol_step1    = 0.01;
    params.tol_step2    = 0.001;
    params.padsize      = [4,4,4];
end

% Because of the scaling factor in their implementation,
% the local field map is converted to rad
RDF = RDF .* (2*pi * delta_TE); 

% double precision is requried for this function
chi = QSM_iLSQR(double(RDF), double(mask), 'params',params);
