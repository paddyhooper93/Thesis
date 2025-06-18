function Run_commands_Valerie()

% %% Precusor Steps: Echo time inclusion (TE1to4 versus TE1to7), NLFit versus SNRwAVG versus MagnwAVG
%
% % NLFit
% hdr.noDipoleInversion = 1;
% hdr.EchoCombineMethod = 'NLFit';
% hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Precursor_Steps\NLFit_TE1to4\';
% Wrapper_QSM_Main_Valerie_Neutral(hdr)
%



%% NLFit + GC
% hdr.noDipoleInversion = 1; hdr.saveQualityMasks = 1;
% hdr.unwrapMethod = 'GraphCuts'; hdr.subsampling = 2; hdr.EchoCombineMethod = 'NLFit';
% hdr.saveWorkspace = true;
% hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Precursor_Steps\NLFit_GC_TE1to4\';
% Wrapper_QSM_Main_Valerie_Neutral(hdr)
% 
% % ROMEO + SNRwAVG
% hdr.noDipoleInversion = 1; hdr.saveQualityMasks = 1;
% hdr.EchoCombineMethod = 'SNRwAVG'; hdr.temporalUnwrapping = 'ROMEO';
% hdr.saveWorkspace = true;
% hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Precursor_Steps\ROMEO_SNRwAVG_TE1to4\';
% Wrapper_QSM_Main_Valerie_Neutral(hdr)

%% MEDI

i = {'7T_Neutral'};
TE = 3:3:21;

%% Turn data weighting off -> clearly important

for dataset = i
    hdr.input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Precursor_Steps\NLFit_GC_TE1to4\';
    workspace_str = fullfile(hdr.input_dir, strcat(dataset{1}, '_workspace.mat'));
    fileInfo = who('-file', workspace_str);
    load(workspace_str, fileInfo{:});    hdr.noDipoleInversion = false;
    hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\MEDI\wData0\';
    if 7~=exist(hdr.output_dir, 'dir')
        eval(strcat('mkdir', 32, hdr.output_dir));
    end
    hdr.wData = 0;
    hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\SDC\';
    dataset_str = fullfile(hdr.path_to_data, strcat(dataset, '_SDC.mat'));
    load(dataset_str, "Magn", "Mask_Use");
    [weights] = CalculateWeights(Magn, TE, Mask_Use); clear Magn Mask_Use
    DipoleInversion(iFreq, weights, RDF, hdr);
end

%% MEDI-Default
for dataset = i
    hdr.input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Precursor_Steps\NLFit_GC_TE1to4\';
    workspace_str = fullfile(hdr.input_dir, strcat(dataset{1}, '_workspace.mat'));
    fileInfo = who('-file', workspace_str);
    load(workspace_str, fileInfo{:});    hdr.noDipoleInversion = 0; % Set back to default.
    hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\MEDI\MEDI-Default\';
    if 7~=exist(hdr.output_dir, 'dir')
        eval(strcat('mkdir', 32, hdr.output_dir));
    end
    hdr.isLambdaCSF = 0;
    hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\SDC\';
    dataset_str = fullfile(hdr.path_to_data, strcat(dataset, '_SDC.mat'));
    load(dataset_str, "Magn", "Mask_Use");
    [weights] = CalculateWeights(Magn, TE, Mask_Use); clear Magn Mask_Use
    DipoleInversion(iFreq, weights, RDF, hdr);
end



%% Edge mask threshold = 80 % -> reducing percentage is important
for dataset = i
    hdr.input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Precursor_Steps\NLFit_GC_TE1to4\';
    workspace_str = fullfile(hdr.input_dir, strcat(dataset{1}, '_workspace.mat'));
    fileInfo = who('-file', workspace_str);
    load(workspace_str, fileInfo{:});        hdr.noDipoleInversion = false;
    hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\MEDI\Percentage80\';
    if 7~=exist(hdr.output_dir, 'dir')
        eval(strcat('mkdir', 32, hdr.output_dir));
    end
    hdr.percentage = 0.8;    
    hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\SDC\';
    dataset_str = fullfile(hdr.path_to_data, strcat(dataset, '_SDC.mat'));
    load(dataset_str, "Magn", "Mask_Use");
    [weights] = CalculateWeights(Magn, TE, Mask_Use); clear Magn Mask_Use
    DipoleInversion(iFreq, weights, RDF, hdr);
end

%% MEDI+0 -> clearly important

for dataset = i
    hdr.input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Precursor_Steps\NLFit_GC_TE1to4\';
    workspace_str = fullfile(hdr.input_dir, strcat(dataset{1}, '_workspace.mat'));
    fileInfo = who('-file', workspace_str);
    load(workspace_str, fileInfo{:});        hdr.noDipoleInversion = false;
    hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\MEDI\MEDI+0\';
    if 7~=exist(hdr.output_dir, 'dir')
        eval(strcat('mkdir', 32, hdr.output_dir));
    end
    hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\SDC\';
    dataset_str = fullfile(hdr.path_to_data, strcat(dataset, '_SDC.mat'));
    load(dataset_str, "Magn", "Mask_Use");
    [weights] = CalculateWeights(Magn, TE, Mask_Use); clear Magn Mask_Use
    hdr.isLambdaCSF = 1;
    DipoleInversion(iFreq, weights, RDF, hdr);
end

%% MEDI-SMV -> not beneficial, since dataset contained various holes

hdr.unwrapMethod = 'GraphCuts'; hdr.subsampling = 2; hdr.EchoCombineMethod = 'NLFit';
hdr.isSMV = 1; hdr.percentage = 0.8; hdr.isLambdaCSF = 1; hdr.lambda = 1000; hdr.lam_CSF = 100; 
hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\MEDI\MEDI-SMV\';
Wrapper_QSM_Main_Valerie_Neutral(hdr)

%% Edge mask threshold = 70 % -> reducing percentage is important
TE = 3:3:21;
i = {'7T_Neutral'};
for dataset = i
    hdr.input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Precursor_Steps\NLFit_GC_TE1to4\';
    workspace_str = fullfile(hdr.input_dir, strcat(dataset{1}, '_workspace.mat'));
    fileInfo = who('-file', workspace_str);
    load(workspace_str, fileInfo{:});        hdr.noDipoleInversion = false;
    hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\MEDI\Percentage70\';
    if 7~=exist(hdr.output_dir, 'dir')
        eval(strcat('mkdir', 32, hdr.output_dir));
    end
    hdr.percentage = 0.7;    hdr.isLambdaCSF = 1; hdr.lambda = 1000; hdr.lam_CSF = 100; 
    hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\SDC\';
    dataset_str = fullfile(hdr.path_to_data, strcat(dataset, '_SDC.mat'));
    load(dataset_str, "Magn", "Mask_Use");
    [weights] = CalculateWeights(Magn, TE, Mask_Use); clear Magn Mask_Use
    DipoleInversion(iFreq, weights, RDF, hdr);
end



%% Turn Merit off -> makes no difference

for dataset = i
    hdr.input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Precursor_Steps\NLFit_GC_TE1to4\';
    workspace_str = fullfile(hdr.input_dir, strcat(dataset{1}, '_workspace.mat'));
    fileInfo = who('-file', workspace_str);
    load(workspace_str, fileInfo{:});        hdr.noDipoleInversion = false;
    hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\MEDI\isMerit0\';
    hdr.isMerit = 0;
    if 7~=exist(hdr.output_dir, 'dir')
        eval(strcat('mkdir', 32, hdr.output_dir));
    end
    hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\SDC\';
    dataset_str = fullfile(hdr.path_to_data, strcat(dataset, '_SDC.mat'));
    load(dataset_str, "Magn", "Mask_Use");
    [weights] = CalculateWeights(Magn, TE, Mask_Use); clear Magn Mask_Use
    DipoleInversion(iFreq, weights, RDF, hdr);
end

%% lam_CSF = 100
i = {'3T_Neutral', '7T_Neutral'};
for dataset = i
    hdr.input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Precursor_Steps\NLFit_GC_TE1to4\';
    workspace_str = fullfile(hdr.input_dir, strcat(dataset{1}, '_workspace.mat'));
    fileInfo = who('-file', workspace_str);
    load(workspace_str, fileInfo{:});    hdr.noDipoleInversion = false;
    hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\MEDI\lamCSF100\';
    if 7~=exist(hdr.output_dir, 'dir')
        eval(strcat('mkdir', 32, hdr.output_dir));
    end
    hdr.lam_CSF = 100; hdr.percentage = 0.8; hdr.isLambdaCSF = 1; hdr.lambda = 1000;
    hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\SDC\';
    dataset_str = fullfile(hdr.path_to_data, strcat(dataset, '_SDC.mat'));
    load(dataset_str, "Magn", "Mask_Use");
    [weights] = CalculateWeights(Magn, TE, Mask_Use); clear Magn Mask_Use
    DipoleInversion(iFreq, weights, RDF, hdr);
end

%% lambda = 100

for dataset = i
    hdr.input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Precursor_Steps\NLFit_GC_TE1to4\';
    workspace_str = fullfile(hdr.input_dir, strcat(dataset{1}, '_workspace.mat'));
    fileInfo = who('-file', workspace_str);
    load(workspace_str, fileInfo{:});    hdr.noDipoleInversion = false;
    hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\MEDI\lambda100\';
    if 7~=exist(hdr.output_dir, 'dir')
        eval(strcat('mkdir', 32, hdr.output_dir));
    end
    hdr.lambda = 100; hdr.percentage = 0.8; hdr.isLambdaCSF = 1; hdr.lam_CSF = 100; 
    hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\SDC\';
    dataset_str = fullfile(hdr.path_to_data, strcat(dataset, '_SDC.mat'));
    load(dataset_str, "Magn", "Mask_Use");
    [weights] = CalculateWeights(Magn, TE, Mask_Use); clear Magn Mask_Use
    DipoleInversion(iFreq, weights, RDF, hdr);
end
hdr.lambda = 1000; % Set back to default.

%% NewCSFMask
i = {'3T_Neutral', '7T_Neutral'};
for dataset = i
    hdr.input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Precursor_Steps\NLFit_GC_TE1to4\';
    workspace_str = fullfile(hdr.input_dir, strcat(dataset{1}, '_workspace.mat'));
    fileInfo = who('-file', workspace_str);
    load(workspace_str, fileInfo{:});    hdr.noDipoleInversion = false;
    hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\MEDI\NewCSFMask\';
    if 7~=exist(hdr.output_dir, 'dir')
        eval(strcat('mkdir', 32, hdr.output_dir));
    end
    hdr.lam_CSF = 100; hdr.percentage = 0.8; hdr.isLambdaCSF = 1; hdr.lambda = 1000;
    hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\SDC\';
    dataset_str = fullfile(hdr.path_to_data, strcat(dataset, '_SDC.mat'));
    load(dataset_str, "Magn", "Mask_Use");
    [weights] = CalculateWeights(Magn, TE, Mask_Use); clear Magn Mask_Use
    DipoleInversion(iFreq, weights, RDF, hdr);
end




%% SS-TGV

% for dataset = i
%     hdr.input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Precursor_Steps\NLFit_GC_TE1to4\';
%     workspace_str = fullfile(hdr.input_dir, strcat(dataset{1}, '_workspace.mat'));
%     fileInfo = who('-file', workspace_str);
%     load(workspace_str, fileInfo{:});
%     hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\SS-TGV\';
%     if 7~=exist(hdr.output_dir, 'dir')
%         eval(strcat('mkdir', 32, hdr.output_dir));
%     end
%     hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\SDC\';
%     dataset_str = fullfile(hdr.path_to_data, strcat(dataset, '_SDC.mat'));
%     load(dataset_str, "Mask_Use");
%     hdr.Mask_Use = Mask_Use;
%     SingleStep(iFreq, hdr)
% end