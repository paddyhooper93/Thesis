clc
clear
close all

% i =    {'TE1to3_24mth'};
i =    {'7T_BL', '7T_BL_Rep'}; %,  ..., '7T_24mth_Rep', '7T_24mth'
% i = {'TE1to7_9mth'};


hdr = struct();
hdr.output_dir = 'C:\Users\rosly\Documents\QSM_PH\Data\Input\';
ROIs_Struct = struct();
firstIteration = true; % Flag for initializing multiplication

for dataset = i  
    str = dataset{1};
    [ROIs_Vol] = CreateROIs(dataset{1}, hdr);
    ROIs_Vol = single(ROIs_Vol);
    ROIs_fn = strcat('7T_ROIs_', dataset{1}, '.nii.gz');
    export_nii(ROIs_Vol, ROIs_fn);
    
    % Store ROIs in the structure using dynamic field names
    fieldName = matlab.lang.makeValidName(['Dataset_' dataset{1}]); 
    ROIs_Struct.(fieldName) = ROIs_Vol;

    % Multiply ROIs together
    if firstIteration
        ROIs_Multiplied = ROIs_Vol;
        firstIteration = false;
    else
        ROIs_Multiplied = ROIs_Multiplied .* ROIs_Vol;
    end
    %% : Erode the mask by a 2mm sphere
    SE = strel('sphere', 2);
    ROIs_Use = imerode(ROIs_Multiplied, SE);
end

export_nii(ROIs_Use, '7T_ROIs.nii.gz');