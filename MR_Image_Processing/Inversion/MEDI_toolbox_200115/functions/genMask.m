% Mask generation
%   Mask = genMask(iField, voxel_size)
%   
%   
%
%   output
%   Mask - the biggest contiguous region that has decent SNR
%
%   input
%   iField - the complex MR image
%   voxel_size - the size of a voxel
%
%   Created by Tian Liu in 20013.07.24
%   Last modified by Tian Liu on 2013.07.24
%   Adapted by Paddy Hooper on 2024.09.24 
% - Changed default parameters for CSFMasking in Phantoms


function Mask = genMask(iField, voxel_size, opts)

if nargin < 3
    opts.erodeRadius = 0; % in mm
    opts.magThreshold = 5; % in percent
    opts.numRegions = 6;
end

iMag = sqrt(sum(abs(iField).^2,4));
matrix_size = size(iMag);
m = iMag>(opts.magThreshold/100*max(iMag(:)));           % simple threshold
if opts.erodeRadius > 0
    m = SMV(m,matrix_size, voxel_size, opts.erodeRadius)>0.999;   % erode the boundary by 10mm
end
l = bwlabeln(m,opts.numRegions);                       % find the biggest contiguous region
Mask = (l==mode(l(l~=0)));
end
