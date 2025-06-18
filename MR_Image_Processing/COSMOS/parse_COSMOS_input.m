function [tol, maxit, x0, isTik, lam_Tik, isCSF, lam_CSF] = ...
    parse_COSMOS_input(varargin)


maxit = 100;
tol = 1e-6;
isTik = false;
lam_Tik = 0.05;
isCSF = true;
lam_CSF = 10;
x0 = [];

if size(varargin,2)>0
    for k=1:size(varargin,2)
        if strcmpi(varargin{k},'maxit')
            maxit=varargin{k+1};
        end
        if strcmpi(varargin{k},'tol')
            tol=varargin{k+1};
        end
        if strcmpi(varargin{k},'isTik')
            isTik=varargin{k+1};
        end
        if strcmpi(varargin{k},'lam_Tik')
            lam_Tik=varargin{k+1};
        end
        if strcmpi(varargin{k},'isCSF')
            isCSF=varargin{k+1};
        end
        if strcmpi(varargin{k},'lam_CSF')
            lam_CSF=varargin{k+1};
        end
        if strcmpi(varargin{k},'x0')
            x0=varargin{k+1};
        end
    end
end