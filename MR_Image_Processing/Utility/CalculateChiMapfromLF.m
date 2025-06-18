%% CalculateChiMapfromLF.m
% Step 1: Convert from map of local frequencies (Hz) to (normalized) local
% map (dimensionless in parts-per-million)
% Step 2: Inf.Cyl.Assumption (prl to B0)
% Input:
% lf = local frequency map (Hz)
% fs = field strength (T)
% Output:
% chi_prl = chimap for Inf. Cyl. (prl to B0) (ppm)


function [varargout] = CalculateChiMapfromLF(lf, fs)

gamma = 42.6; %MHz/T

if fs == 3
    B0 = 2.89; % nominal strength for Siemens 3 T scanners
elseif fs == 7
    B0 = fs;
end

% Step 1: Local field in dimensionless units: delta
delta = lf/(gamma * B0);
% Step 2: Inf.Cyl.Model (theta = 0 radians): chi_prl
chi_prl = 3 * delta;
% Step 3: Inf.Cyl.Model (theta = pi/2 radians): chi_perp
chi_perp = -6 * delta;

% Assign outputs based on the number of requested outputs
if nargout == 1
    varargout{1} = chi_prl;
elseif nargout == 2
    varargout{1} = chi_prl;
    varargout{2} = delta;
elseif nargout == 3
    varargout{1} = chi_prl;
    varargout{2} = delta;
    varargout{3} = chi_perp;
end