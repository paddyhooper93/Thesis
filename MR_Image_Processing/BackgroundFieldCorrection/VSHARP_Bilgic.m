function [RDF, RDFMask] = VSHARP_Bilgic(iFreq, Mask_Use, SMVradii, TSVD_thr)

%% Zero pad for Sharp kernel convolution

pad_size = [10,10,10];     % pad for Sharp recon

mask_pad = padarray(Mask_Use, pad_size);
iFreq = padarray(iFreq, pad_size);

N = size(mask_pad);


%% recursive filtering with decreasing filter sizes




Phase_Del = zeros(N);
mask_prev = zeros(N);


tic
for k = 1:length(SMVradii)
    
    disp(['Kernel size: ', num2str(SMVradii(k))])
    
    Kernel_Size = SMVradii(k);


    ksize = [Kernel_Size, Kernel_Size, Kernel_Size];                % Sharp kernel size


   
    khsize = (ksize-1)/2;
    [a,b,c] = meshgrid(-khsize(2):khsize(2), -khsize(1):khsize(1), -khsize(3):khsize(3));


    kernel = (a.^2 / khsize(1)^2 + b.^2 / khsize(2)^2 + c.^2 / khsize(3)^2 ) <= 1;
    kernel = -kernel / sum(kernel(:));
    kernel(khsize(1)+1,khsize(2)+1,khsize(3)+1) = 1 + kernel(khsize(1)+1,khsize(2)+1,khsize(3)+1);


    Kernel = zeros(N);
    Kernel( 1+N(1)/2 - khsize(1) : 1+N(1)/2 + khsize(1), 1+N(2)/2 - khsize(2) : 1+N(2)/2 + khsize(2), 1+N(3)/2 - khsize(3) : 1+N(3)/2 + khsize(3) ) = -kernel;


    del_sharp = fftn(fftshift(Kernel));
    


    % erode mask to remove convolution artifacts
    erode_size = ksize + 1;


    mask_sharp = imerode(mask_pad, strel('line', erode_size(1), 0));
    mask_sharp = imerode(mask_sharp, strel('line', erode_size(2), 90));
    mask_sharp = permute(mask_sharp, [1,3,2]);
    mask_sharp = imerode(mask_sharp, strel('line', erode_size(3), 0));
    mask_sharp = permute(mask_sharp, [1,3,2]);
    
    
    % apply Sharp to Laplacian unwrapped phase
    phase_del = ifftn(fftn(iFreq) .* del_sharp);


    Phase_Del = Phase_Del + phase_del .* (mask_sharp - mask_prev); 
    
    mask_prev = mask_sharp;


    if k == 1
        delsharp_inv = zeros(size(del_sharp));
        delsharp_inv( abs(del_sharp) > TSVD_thr ) = 1 ./ del_sharp( abs(del_sharp) > TSVD_thr );
    end        
    
end
toc


RDF = real( ifftn(fftn(Phase_Del) .* delsharp_inv) .* mask_sharp );
RDFMask = mask_sharp;