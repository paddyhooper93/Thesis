function [unwrapped] = UnwrapAllTEs_GC(hdr)

Magn = hdr.Magn;
Phs = hdr.Phs;
voxel_size = hdr.voxel_size;
Mask_Use = hdr.Mask_Use;
Magn_TE1 = Magn(:,:,:,1) .* Mask_Use;
subsampling = hdr.subsampling;
clear Magn
%%%%%%%%%%%%%%%%%%%%%%%% Multi-echo %%%%%%%%%%%%%%%%%%%%%%%%
    dims = size(Phs);
    dims(4) = dims(4) - 1;


    %%%%%%%%%%%%%%%%%%%%%%%% Step 1: unwrap phase %%%%%%%%%%%%%%%%%%%%%%%%
    % compute wrapped phase shift between successive echoes & unwrap each echo phase shift
        phaseShiftUnwrapAllEchoes = zeros(dims, 'like', Phs);
    for k = 1:dims(4)
        fprintf('Unwrapping #%i echo shift...\n',k);
        tmp	= angle(exp(1i*Phs(:,:,:,k+1))./exp(1i*Phs(:,:,:,k)));
        tmp = unwrapping_gc(tmp, Magn_TE1, voxel_size, subsampling);
        phaseShiftUnwrapAllEchoes(:,:,:,k) = tmp-round(mean(tmp( Mask_Use == 1))/(2*pi))*2*pi;
    end
    % get the unwrapped phase accumulation across echoes
    phaseShiftUnwrapAllEchoes = cumsum(phaseShiftUnwrapAllEchoes,4);   
    % unwrap first echo
    tmp                     = unwrapping_gc(Phs(:,:,:,1), Magn_TE1, voxel_size, subsampling);
    tmp                     = tmp-round(mean(tmp( Mask_Use == 1))/(2*pi))*2*pi;
    % Concatenate the echoes together
    unwrapped = cat(4,tmp,phaseShiftUnwrapAllEchoes + tmp);