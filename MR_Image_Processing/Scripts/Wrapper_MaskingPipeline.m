%% Wrapper_MaskingPipeline
%% clear cmd window, wkspace, figures window
clc
clear
close all

path_to_data = 'C:\Users\rosly\Documents\QSM_PH\Data\Input\';
hdr = struct();
hdr.output_dir = 'C:\Users\rosly\Documents\QSM_PH\Data\RelativeResidualWeights\';
[hdr] = CreateHeader(hdr); % Adjust parameters here
i = {'7T_BL', '7T_BL_Rep', '7T_9mth', '7T_24mth', '7T_24mth_Rep'}; 
% i = {'3T_BL', '3T_BL_Rep', '3T_9mth', '3T_24mth', '3T_24mth_Rep'};
% i = {'3T_BL', '3T_BL_Rep', '3T_9mth', '3T_24mth', '3T_24mth_Rep'};%, ...
     % '7T_BL', '7T_BL_Rep', '7T_9mth', '7T_24mth', '7T_24mth_Rep'};

for dataset = i
    [hdr] = InitializeVar(dataset{1}, hdr);
    [hdr] = MaskingPipeline(hdr);
    [hdr, iFreq] = FieldMap_UnwrapPhase(hdr);
    hdr.isBFC = true; hdr.isMED0 = true;
    MaskingPipeline(hdr);
end


% for dataset = i
%     data = InitializeVar(dataset{1});
%     R2s = data.R2s;
%     FS = data.FS;
%     voxel_size = data.voxel_size;
%     matrix_size = data.matrix_size;
%     iMag = data.iMag;
%     [~, ~, QSMMask, ~] = MaskingPipeline(dataset{1});
%     if FS == 3
%     magThreshold = 40;
%     SimpleThreshold = iMag>(magThreshold/100*max(iMag(:)));
%     SimpleThreshold = SimpleThreshold .* QSMMask;
%     CSFMask1 = extract_CSF(R2s, SimpleThreshold, voxel_size, 0, 5);
%     CSFMask1 = double(CSFMask1 .* QSMMask);
%     mosaic( CSFMask1, 12, 12, 6, 'Simple Threshold CSF Mask' )   
%     export_nii(CSFMask1, strcat(dataset{1},'_CSFMask.nii.gz'));
%     elseif FS == 7
%     min_r2s = min(R2s(QSMMask>0));
%     iqr_r2s     = iqr(R2s(and( QSMMask>0, R2s>min_r2s )));
%     median_r2s  = median(R2s(and( QSMMask>0, R2s>min_r2s )));
%     r2s_mask = R2s <= (median_r2s + 3*iqr_r2s);
%     r2s_mask = r2s_mask .* QSMMask;
%     CSFMask2 = extract_CSF(R2s, r2s_mask, voxel_size, 1, 5);
%     CSFMask2 = double(CSFMask2 .* QSMMask);
%     mosaic( CSFMask2, 12, 12, 7, 'R2star CSF Mask' )   
%     end
% end

    % erodeRadius = 12;
    % CSFMask = SMV(CSFMask, matrix_size, voxel_size, erodeRadius)>0.999;   % erode the boundary 

        % CSFMask = double(CSFMask .* BETMask);
    % fractional_threshold= 0.3; % (Values lower than 0.5 make mask larger)
    % gradient_threshold  = 0.2; % (Values higher than 0.0 shift mask towards SI direction)
    % BETMask             = BET(iMag, matrix_size, voxel_size, ...
    % fractional_threshold, gradient_threshold);
    % if FS == 3  
    %     if abs(max(Phs(:))-pi)>0.1 || abs(min(Phs(:))-(-pi))>0.1
    %         [phs_min,phs_max]  = bounds( Phs(:) , "all" );
    %         Phs = 2*pi*(Phs - phs_min)/(phs_max-phs_min) - pi ;
    %     end
    %     iField = Magn.*exp(-1i*Phs);
    %     CSFMask = double(genCSFMask(iField, voxel_size, FS)) .* BETMask;
    % elseif FS == 7
    %     % excluding minimum from statistic
    %     min_r2s = min(R2s(BETMask>0));
    % 
    %     % compute stats
    %     iqr_r2s     = iqr(R2s(and( BETMask>0, R2s>min_r2s )));
    %     median_r2s  = median(R2s(and( BETMask>0, R2s>min_r2s )));
    % 
    %     % assume everthing outside 3*IQR from median to be outliers
    %     CSFMask = R2s <= (median_r2s + 3*iqr_r2s);
    % 
    %     erodeRadius = 12;
    %     CSFMask = SMV(CSFMask, matrix_size, voxel_size, erodeRadius)>0.999;   % erode the boundary 
    %     CSFMask = double(CSFMask .* BETMask);
    % 
    %     % min_open = 1; min_close = 1;
    %     % CSFMask = refine_brain_mask_using_r2s(R2s, BETMask, voxel_size, ...
    %     %     min_open, min_close);
    %     % CSFMask = double(extract_CSF(R2s, CSFMask, voxel_size) );
    %     % CSFMask = CSFMask .* BETMask;
    % en    
    % export_nii(CSFMask, strcat(dataset{1},'_CSFMask.nii.gz'));
% end
% for dataset = i
%     [BETMask, Mask_Refined, RDFMask, QSMMask, CSFMask] = ...
%     MaskingPipeline(dataset{1});
% end