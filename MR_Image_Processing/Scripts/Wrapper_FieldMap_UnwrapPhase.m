%% Wrapper_FieldMap_UnwrapPhase
%% clear cmd window, wkspace, figures window
clc
clear
close all

%% Set directory for data input
input_dir = 'C:\Users\rosly\Documents\QSM_PH\Data\NC\';
eval(strcat('cd', 32, input_dir));

%% Set and write directory for temp processing
hdr = struct();
hdr.output_dir = 'C:\Users\rosly\Documents\QSM_PH\Registration\Unregistered\L1L2_14mm_Eddy_RR05\tmp\';
if 7~=exist(hdr.output_dir, 'dir')
    eval(strcat('mkdir', 32, hdr.output_dir));
end

%% Loop through QSM_Main
i = {'7T_9mth'};
% i =   {'3T_BL', '3T_BL_Rep', '3T_9mth', '3T_24mth', '3T_24mth_Rep'};
% Done = {'7T_BL', '7T_BL_Rep'}

for dataset = i
    %% Step 0: Initialize header opts
    [hdr] = CreateHeader(hdr); % Adjust parameters here
    [hdr] = InitializeVar(dataset{1}, hdr);

    %% Step 1: Generate BET Mask (Holes Filled In)
    [hdr] = MaskingPipeline(hdr); 

    %% Step 2: Unwrapping and Fieldmap calculation
    [iFreq, hdr] = FieldMap_UnwrapPhase(hdr);
    %% Step 3: Data fidelity/consistency weighting
    [weights, hdr] = DataConsistencyWeighting(iFreq, hdr);

    %% Step 4: Background field correction
    hdr.isBFC = true; hdr.isMEDI0 = false;
    [hdr] = MaskingPipeline(hdr); 
    [RDF] = BackgroundFieldCorrection(iFreq, hdr);
    fprintf('Processed Dataset %s \n', dataset{1});
end