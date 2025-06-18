function [CombinedVol] = CombineProcessedVols(dataset, param, hdr)
% Same prefix information, i.e., data from the same acquisition, analysed with partial TEs and full TEs.

suffix = '_Quad.nii.gz';

input_dir = hdr.input_dir;
FullPrefix = dataset;
Full_fn = fullfile(input_dir, strcat(FullPrefix, '_', param, suffix));
Full_nii = load_nii(Full_fn);
Full = Full_nii.img;
[Mx, My, Mz] = size(Full);

if contains(dataset, "3T_9mth" ) || contains(dataset, "3T_24mth") 
    PartialPrefix = strcat('TE1to7_', dataset(4:end));
elseif contains(dataset, "7T_9mth") || contains(dataset, "7T_24mth") 
    PartialPrefix = strcat('TE1to3_', dataset(4:end));
else
    Partial = zeros([Mx, My, Mz]);
end

if ~exist('Partial', 'var')
    Partial_fn = fullfile(input_dir, strcat(PartialPrefix, '_', param, suffix));
    Partial_nii = load_nii(Partial_fn);
    Partial = Partial_nii.img;
end

if contains(dataset, "3T")
    x_range = 97:192; % 2nd half of matrix
    y_range = 97:192; % 2nd half of matrix
elseif contains(dataset, "7T")
    x_range = 120:238; % 2nd half of matrix
    y_range = 137:272; % 2nd half of matrix
end

[Full] = zero_out(x_range, y_range, Full, Mz);
[Partial] = zero_out_complement(x_range, y_range, Partial);
CombinedVol = Full + Partial;

end