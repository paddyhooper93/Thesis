function [iFreq_Hz] = EchoCombine_SNRweighted(unwrapped_rad, TE, N, R2s)
% TE = hdr.TE;
% N = hdr.matrix_size;
n_echoes = length(TE);
% R2s = hdr.R2s; % [1/s] 
gamma = 42.6*2*pi*1e6; % [rad/(s.T)]

w_j = zeros([N n_echoes]);
for j=1:n_echoes
    w_j(:,:,:,j) = TE(j)*exp(-TE(j)*R2s);
end
w_j_sum = sum(w_j,4);

% Field map calculated in units Tesla (T)
iFreq_w_T = zeros([N n_echoes]);
for i=1:n_echoes
    w_i = TE(i)*exp(-TE(i)*R2s)./w_j_sum;
    iFreq_w_T(:,:,:,i) = ...
        w_i.*unwrapped_rad(:,:,:,i)/(gamma*TE(i));
end
% Convert from T to Hz
iFreq_T = sum(iFreq_w_T, 4);
iFreq_Hz = iFreq_T*gamma/(2*pi);
end