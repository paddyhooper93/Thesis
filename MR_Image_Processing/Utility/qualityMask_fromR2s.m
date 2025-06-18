% R2s quality mask
function [hdr] = qualityMask_fromR2s(R2s, hdr)
if hdr.FS == 3
    hdr.R2s_qualityMask = double(R2s < 30);
elseif hdr.FS == 7
    hdr.R2s_qualityMask = double(R2s < 50);
end