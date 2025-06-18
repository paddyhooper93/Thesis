function [RDF] = Wrapper_iRSHARP(hdr)

TE = hdr.TE;

if contains(hdr.EchoCombineMethod, 'wAVG')
    unwrapped = hdr.unwrapped;
    wrapped = hdr.Phs;
    % convert from radians to Hz
    delta_TE     = TE(2)-TE(1);
    unwrapped    = unwrapped / (2*pi*delta_TE);
    wrapped      = wrapped / (2*pi*delta_TE);
else
    % Already in Hz
    unwrapped = iFreq;
    wrapped   = iFreq_raw;
end

% Prepare Params struct
Params.sizeVol = hdr.matrix_size;
Params.voxSize = hdr.voxel_size;

% Prepare Consts struct
Consts.TSVD = 0.1;
Consts.C = 0.28;
Consts.rMIN = 1;
Consts.rMAX = 6;

Mask_Use = hdr.Mask_Use;
n_TE = size(unwrapped, 4);
RDF = zeros(size(unwrapped));

for i = 1:n_TE
    [RDF(:,:,:,i), ~]=iRSHARP(unwrapped(:,:,:,i), wrapped(:,:,:,i), Mask_Use, Params, Consts);
end

if contains(hdr.EchoCombineMethod, 'wAVG')
    if contains(hdr.EchoCombineMethod, 'MagnwAVG')
        Magn = hdr.Magn;
        [RDF] = EchoCombine_MagnWeighted(Magn, RDF, TE);
        RDF = RDF .* Mask_Use;
    elseif contains(hdr.EchoCombineMethod, 'SNRwAVG')
        [RDF] = EchoCombine_SNRweighted(RDF, hdr);
        RDF = RDF .* Mask_Use;
    end
end