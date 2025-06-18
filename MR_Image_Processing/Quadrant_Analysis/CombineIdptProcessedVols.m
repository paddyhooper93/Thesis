function [CombinedVol] = CombineIdptProcessedVols(dataset, param, hdr)
% Same prefix information, i.e., data from the same acquisition, analysed with partial TEs and full TEs.

quads = {'quad1', 'quad2', 'quad3', 'quad4'};
input_dir = hdr.input_dir;
FullPrefix = fullfile( input_dir, dataset );

if contains(dataset, "3T" )
    PartialPrefix = fullfile( input_dir, strcat('TE1to7_', dataset(4:end)) );
elseif contains(dataset, "7T")
    PartialPrefix = fullfile( input_dir, strcat('TE1to3_', dataset(4:end)) );
end

%% Quad 1
Quad1_fn = strcat(FullPrefix, '_', quads{1}, '_', param, '.nii.gz');
Quad1_nii = load_nii(Quad1_fn);
Quad1 = Quad1_nii.img;

if contains(dataset, "3T")
    x_range = 1:96;
    y_range = 1:96;
elseif contains(dataset, "7T")
    x_range = 1:119;
    y_range = 1:136;
end
[Quad1] = zero_out_complement(x_range, y_range, Quad1);

%% Quad 2
Quad2_fn = strcat(FullPrefix, '_', quads{2}, '_', param, '.nii.gz');
Quad2_nii = load_nii(Quad2_fn);
Quad2 = Quad2_nii.img;

if contains(dataset, "3T")
    x_range = 1:96;
    y_range = 97:192;
elseif contains(dataset, "7T")
    x_range = 1:119;
    y_range = 137:272;
end
[Quad2] = zero_out_complement(x_range, y_range, Quad2);

%% Quad 3

Quad3_fn = strcat(FullPrefix, '_', quads{3}, '_', param, '.nii.gz');
Quad3_nii = load_nii(Quad3_fn);
Quad3 = Quad3_nii.img;

if contains(dataset, "3T")
    x_range = 97:192;
    y_range = 1:96;
elseif contains(dataset, "7T")
    x_range = 120:238;
    y_range = 1:136;
end
[Quad3] = zero_out_complement(x_range, y_range, Quad3);

%% Quad 4

if contains(dataset, "3T")
    x_range = 97:192;
    y_range = 97:192;
elseif contains(dataset, "7T")
    x_range = 120:238;
    y_range = 137:272;
end
if ~contains(dataset, "BL")
    Quad4_fn = strcat(PartialPrefix, '_', quads{4}, '_', param, '.nii.gz');
    Quad4_nii = load_nii(Quad4_fn);
    Quad4 = Quad4_nii.img;
    [Quad4] = zero_out_complement(x_range, y_range, Quad4);
else
    Quad4 = single(zeros(size(Quad1)));
end


%% Add them together. They should line up in equal volume quadrants
CombinedVol = Quad1 + Quad2 + Quad3 + Quad4;

end