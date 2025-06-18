function [Magn_rs] = Magn_Rescaling(Magn)
% scales all elements to the interval [0 4095] if outside acceptable range.
if max(Magn(:))>4096 || min(Magn(:))<0
    Magn_rs = rescale(Magn, 0, 4095);
else
    Magn_rs = Magn;
end
end
