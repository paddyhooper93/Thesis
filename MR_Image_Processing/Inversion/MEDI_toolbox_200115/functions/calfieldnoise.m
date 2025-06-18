% Noise standard deviation calculation
%   noise_level = calfieldnoise(iField, Mask)
% 
%   output
%   noise_level - the noise standard devivation of complex MR signal
%
%   input
%   iField - the complex MR image
%   Mask - the a region of interest that is not pure noise
%
%   Created by Tian Liu in 20013.07.24
%   Last modified by Tian Liu on 2013.07.24
%   modified by X.L. 2015-04-20 to fit the QSMToolbox dataformat and procedure

function [noise_level, noise_level_norm, iField1, iField1_norm] = calfieldnoise(GREMag1, GREPhaseRaw1, Mask_Air, Mask_Skull)
if nargin < 4
    Mask_Skull = [];
end

expected_SNR = 40;
iField1 = GREMag1.*exp(1i.*GREPhaseRaw1).*(Mask_Air==1);
iField1_norm = iField1.*(Mask_Air==1).*(GREMag1<max(GREMag1(:))/expected_SNR).*(GREMag1>0); %  .*(iMag<max(iMag(:))/expected_SNR).*(iMag>0)
noise_level = std(real(iField1(Mask_Air==1))); 
noise_level_norm = std(real(iField1_norm(Mask_Air==1))); 

end