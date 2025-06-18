function Wrapper_Phase_Correction_MCPC()
%
% clear cmd window, wkspace, figures window

%% Set directory for data input
hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\NC\';
eval(strcat('cd', 32, hdr.path_to_data));

%% Set and write directory for processing & output
hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\SDC\';
if 7~=exist(hdr.output_dir, 'dir')
    eval(strcat('mkdir', 32, hdr.output_dir));
end

%% Loop through QSM_Main

i = {'7T_Neutral'};

for dataset = i

    [hdr] = InitializeParams_Valerie(dataset{1}, hdr);    
    [hdr.Phs] = PhaseOffsetCorrection_MCPC(hdr);
    hdr.rbw = 320; % Anthropomorphic phantom (Valerie) @ 7 T
    StaticDistortionCorrection(dataset{1}, hdr);
end
end


% hdr.NC_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\NC\';
% hdr.R2s_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\R2s\';
% hdr.Mask_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Mask_Use\';

    % dataset_fn = strcat(dataset{1}, '.mat');
    % load(dataset_fn, "R2s", "Mask_Use");
    % thresh = 5; %s^-1
    % [CSFmask] = CSFmaskThresh_Modified(R2s, thresh, Mask_Use);
    % export_nii(double(CSFmask), fullfile( hdr.output_dir, strcat(dataset{1}, '_CSFmask')));
    % fprintf('Processed Dataset %s \n', dataset{1});
