function Wrapper_ksp_filtering(hdr, dataset)

%% Step 0: Initialize header opts and variables

eval(strcat('cd', 32, hdr.path_to_data));

if 7~=exist(hdr.output_dir, 'dir')
    eval(strcat('mkdir', 32, hdr.output_dir));
end

[hdr, data] = InitializeParams_ksp_operations(dataset, hdr);

hdr.Mask_Use = data.Mask_Use;

%% Fermi filter

img_low_fermi = zeros(size(data.Magn));

tic
for t = 1:size(data.Magn, 4)
    [img_low_fermi(:,:,:,t)] = FermiFilter( ...
       data.Magn(:,:,:,t) .* exp(1i * data.Phs(:,:,:,t))); 
end
toc

Magn_low = abs(img_low_fermi);
Phs_low = angle(img_low_fermi);
clear img_low_fermi

export_nii(single(Magn_low), fullfile(hdr.output_dir, [dataset, '_magn_low_fermi']), hdr.voxel_size);
export_nii(single(Phs_low), fullfile(hdr.output_dir,[dataset, '_phs_low_fermi']), hdr.voxel_size);

%% Hanning filter

% img_low_hanning = zeros(size(data.Magn));
% 
% tic
% for t = 1:size(data.Magn, 4)
%     [img_low_hanning(:,:,:,t)] = HanningFilter( ...
%        data.Magn(:,:,:,t) .* exp(1i * data.Phs(:,:,:,t))); 
% end
% toc
% 
% clear data
% 
% Magn_low = abs(img_low_hanning);
% Phs_low = angle(img_low_hanning);
% clear img_low_hanning
% 
% export_nii(int16(Magn_low), fullfile(hdr.output_dir,[dataset, '_magn_low_hanning']), hdr.voxel_size);
% export_nii(int16(Phs_low), fullfile(hdr.output_dir,[dataset, '_phs_low_hanning']), hdr.voxel_size);