function Run_commands_2_Valerie()

clc
clear
close all

%% Edge mask threshold = 40 % -> reducing percentage is important
i = {'3T_Neutral', '7T_Neutral'};
TE = 3:3:21;

for dataset = i
    hdr.input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Precursor_Steps\NLFit_GC_TE1to4\';
    workspace_str = fullfile(hdr.input_dir, strcat(dataset{1}, '_workspace.mat'));
    fileInfo = who('-file', workspace_str);
    load(workspace_str, fileInfo{:});        hdr.noDipoleInversion = false;
    hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\MEDI\Percentage40\';
    if 7~=exist(hdr.output_dir, 'dir')
        eval(strcat('mkdir', 32, hdr.output_dir));
    end
    hdr.percentage = 0.4;    hdr.isLambdaCSF = 1; hdr.lambda = 1000; hdr.lam_CSF = 100; 
    hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\SDC\';
    dataset_str = fullfile(hdr.path_to_data, strcat(dataset, '_SDC.mat'));
    load(dataset_str, "Magn", "Mask_Use");
    [weights] = CalculateWeights(Magn, TE, Mask_Use); clear Magn Mask_Use
    DipoleInversion(iFreq, weights, RDF, hdr);
end

% Edge mask threshold = 30 % -> reducing percentage is important
for dataset = i
    hdr.input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Precursor_Steps\NLFit_GC_TE1to4\';
    workspace_str = fullfile(hdr.input_dir, strcat(dataset{1}, '_workspace.mat'));
    fileInfo = who('-file', workspace_str);
    load(workspace_str, fileInfo{:});        hdr.noDipoleInversion = false;
    hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\MEDI\Percentage30\';
    if 7~=exist(hdr.output_dir, 'dir')
        eval(strcat('mkdir', 32, hdr.output_dir));
    end
    hdr.percentage = 0.3;    hdr.isLambdaCSF = 1; hdr.lambda = 1000; hdr.lam_CSF = 100; 
    hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\SDC\';
    dataset_str = fullfile(hdr.path_to_data, strcat(dataset, '_SDC.mat'));
    load(dataset_str, "Magn", "Mask_Use");
    [weights] = CalculateWeights(Magn, TE, Mask_Use); clear Magn Mask_Use
    DipoleInversion(iFreq, weights, RDF, hdr);
end

% Edge mask threshold = 20 % -> reducing percentage is important
for dataset = i
    hdr.input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Precursor_Steps\NLFit_GC_TE1to4\';
    workspace_str = fullfile(hdr.input_dir, strcat(dataset{1}, '_workspace.mat'));
    fileInfo = who('-file', workspace_str);
    load(workspace_str, fileInfo{:});        hdr.noDipoleInversion = false;
    hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\MEDI\Percentage20\';
    if 7~=exist(hdr.output_dir, 'dir')
        eval(strcat('mkdir', 32, hdr.output_dir));
    end
    hdr.percentage = 0.2;    hdr.isLambdaCSF = 1; hdr.lambda = 1000; hdr.lam_CSF = 100; 
    hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\SDC\';
    dataset_str = fullfile(hdr.path_to_data, strcat(dataset, '_SDC.mat'));
    load(dataset_str, "Magn", "Mask_Use");
    [weights] = CalculateWeights(Magn, TE, Mask_Use); clear Magn Mask_Use
    DipoleInversion(iFreq, weights, RDF, hdr);
end

% Edge mask threshold = 10 % -> reducing percentage is important
for dataset = i
    hdr.input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Precursor_Steps\NLFit_GC_TE1to4\';
    workspace_str = fullfile(hdr.input_dir, strcat(dataset{1}, '_workspace.mat'));
    fileInfo = who('-file', workspace_str);
    load(workspace_str, fileInfo{:});        hdr.noDipoleInversion = false;
    hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\MEDI\Percentage10\';
    if 7~=exist(hdr.output_dir, 'dir')
        eval(strcat('mkdir', 32, hdr.output_dir));
    end
    hdr.percentage = 0.1;    hdr.isLambdaCSF = 1; hdr.lambda = 1000; hdr.lam_CSF = 100; 
    hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\SDC\';
    dataset_str = fullfile(hdr.path_to_data, strcat(dataset, '_SDC.mat'));
    load(dataset_str, "Magn", "Mask_Use");
    [weights] = CalculateWeights(Magn, TE, Mask_Use); clear Magn Mask_Use
    DipoleInversion(iFreq, weights, RDF, hdr);
end

% Edge mask threshold = 0 % -> reducing percentage is important
for dataset = i
    hdr.input_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Precursor_Steps\NLFit_GC_TE1to4\';
    workspace_str = fullfile(hdr.input_dir, strcat(dataset{1}, '_workspace.mat'));
    fileInfo = who('-file', workspace_str);
    load(workspace_str, fileInfo{:});        hdr.noDipoleInversion = false;
    hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\MEDI\Percentage0\';
    if 7~=exist(hdr.output_dir, 'dir')
        eval(strcat('mkdir', 32, hdr.output_dir));
    end
    hdr.percentage = 0;    hdr.isLambdaCSF = 1; hdr.lambda = 1000; hdr.lam_CSF = 100; 
    hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\SDC\';
    dataset_str = fullfile(hdr.path_to_data, strcat(dataset, '_SDC.mat'));
    load(dataset_str, "Magn", "Mask_Use");
    [weights] = CalculateWeights(Magn, TE, Mask_Use); clear Magn Mask_Use
    DipoleInversion(iFreq, weights, RDF, hdr);
end

end