function [CombinedVol] = CombineProcessedVols_New(dataset, param, hdr)
% Same prefix information, i.e., data from the same acquisition, analysed with partial TEs and full TEs.

suffix = '_Quad.nii.gz';

input_dir = hdr.input_dir;
FullPrefix = dataset;
Full_fn = fullfile(input_dir, strcat(FullPrefix, '_', param, suffix));
Full_nii = load_nii(Full_fn);
Full = Full_nii.img;
[Mx, My, Mz] = size(Full);

if contains(dataset, "3T")
    % Quad4_Prefix designates TE selection of Calcium-Carbonate: TE1to7@3T
    % Quad4_Prefix = FullPrefix;
    Quad4_Prefix = strcat('TE1to7_', dataset(4:end));
    % USP_Prefix designates TE selection of USPIO: TE1to7,8,10,12 @ 3T
    % USP_Prefix = Quad4_Prefix; % TE1to7
    % USP_Prefix = strcat('TE1to8_', dataset(4:end));
    % USP_Prefix = strcat('TE1to10_', dataset(4:end));
    USP_Prefix = FullPrefix; % TE1to12
    % USP_Prefix = strcat(FullPrefix, '_usp');
elseif contains(dataset, "7T")
    % Quad4_Prefix designates TE selection of Calcium-Carbonate: TE1to3@7T
    Quad4_Prefix = strcat('TE1to3_', dataset(4:end));
    % Quad4_Prefix = FullPrefix;
    % USP_Prefix = Quad4_Prefix;
    % USP_Prefix designates TE selection of USPIO: TE1to4,5,6,7 @ 7T
    % USP_Prefix = strcat('TE1to4_', dataset(4:end));
    % USP_Prefix = strcat('TE1to5_', dataset(4:end));
    % USP_Prefix = strcat('TE1to6_', dataset(4:end));
    % USP_Prefix = strcat('7T_TE1to07_', dataset(4:end));
    USP_Prefix = FullPrefix; % TE1to9
    % USP_Prefix = strcat(FullPrefix, '_usp');
end

% USP_Prefix = strcat(dataset, '_usp');

%% Quad 1

if contains(dataset, "3T")
    x_range = 1:96;
    y_range = 1:96;
elseif contains(dataset, "7T")
    x_range = 1:119;
    y_range = 1:136;
end

if ~contains(dataset, "24mth")
    USP_fn = fullfile(input_dir, strcat(USP_Prefix, '_', param, suffix));
    USP_nii = load_nii(USP_fn);
    USP = USP_nii.img;
    [Quad1] = zero_out_complement(x_range, y_range, USP);
else
    [Quad1] = zero_out_complement(x_range, y_range, Full);
end

%% Quad 2

if contains(dataset, "3T")
    x_range = 1:96;
    y_range = 97:192;
elseif contains(dataset, "7T")
    x_range = 1:119;
    y_range = 137:272;
end
[Quad2] = zero_out_complement(x_range, y_range, Full);

%% Quad 3

if contains(dataset, "3T")
    x_range = 97:192;
    y_range = 1:96;
elseif contains(dataset, "7T")
    x_range = 120:238;
    y_range = 1:136;
end
if contains(dataset, "24mth")
    USP_fn = fullfile(input_dir, strcat(USP_Prefix, '_', param, suffix));
    USP_nii = load_nii(USP_fn);
    USP = USP_nii.img;
    [Quad3] = zero_out_complement(x_range, y_range, USP);
else
    [Quad3] = zero_out_complement(x_range, y_range, Full);
end

%% Quad 4

if contains(dataset, "3T")
    x_range = 97:192;
    y_range = 97:192;
elseif contains(dataset, "7T")
    x_range = 120:238;
    y_range = 137:272;
end

if ~contains(dataset, "BL")
    Quad4_fn = fullfile(input_dir, strcat(Quad4_Prefix, '_', param, suffix));
    Quad4_nii = load_nii(Quad4_fn);
    Quad4 = Quad4_nii.img;
    [Quad4] = zero_out_complement(x_range, y_range, Quad4);
else
    Quad4 = single(zeros([Mx, My, Mz]));
end

CombinedVol = Quad1 + Quad2 + Quad3 + Quad4;

end