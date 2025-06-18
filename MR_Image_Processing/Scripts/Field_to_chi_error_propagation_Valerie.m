%%Field_to_chi_error_propagation_Valerie.m

clc
clearvars
close all

data_dir='C:\Users\rosly\Documents\Valerie_PH\Data\Padded\SDC';
output_dir = 'C:\Users\rosly\Documents\Valerie_PH\SNR_Phase';
% output_dir = 'C:\Users\rosly\Documents\Valerie_PH\field_to_chi';
% output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\STI_Reference';
csf_dir='C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\csf_mask';

i={'3T_Rot1', '3T_Rot2', '7T_Rot1', '7T_Rot2', '7T_Rot3'}; % , '3T_Rot1', '3T_Rot2', '7T_Rot1', '7T_Rot2', '7T_Rot3'
% , ...
%     
%     
% x=0;
% Step 1: Phase processing (Field mapping, background correction, etc.)
for dataset = i
    data_fn=fullfile(data_dir, [dataset{1}, '_forQSM.mat']);
    load(data_fn, 'Magn', 'Phs', 'Mask_Use');
    if ~contains(dataset{1}, 'Neutral')
        str = [dataset{1}(1:2), '_Neutral_to_', dataset{1}(4:end)];
    else
        str = dataset{1};
    end
    csf_mask=load_untouch_nii(fullfile(csf_dir, [str, '_CSF_Mask.nii.gz']));
    
    if contains(dataset{1}, '7T')
        vsz= [.75 .75 .75];
        fs=7;
    else
        vsz=[1 1 1];
        fs=3;
    end

    if contains(dataset{1}, '7T_Neutral')
        Phs=-1*Phs;
    end

    TE=(3:3:21)./1000;
    d_TE = TE(2)-TE(1);
    fov = [210 240 192];
    fov_pad=1.5.*fov.*min(vsz); % [400 400 400]
   
    Magn=pad_or_crop_target_size(Magn, vsz, fov_pad);
    Phs=pad_or_crop_target_size(Phs, vsz, fov_pad);
    Mask=pad_or_crop_target_size(Mask_Use, vsz, fov_pad);
    csf_mask=pad_or_crop_target_size(csf_mask.img, vsz, fov_pad);
    
    % Erode mask
    e_mm = 2;
    e_vox = round(e_mm / min(vsz));
    Mask = imerode(Mask, strel('sphere', e_vox));
    Magn = Magn .* Mask;
    Phs = Phs .* Mask;
    Magn_E1=Magn(:,:,:,1);

    n_TE = length(TE);

    nChunks=3;
    for c = 1:nChunks
        if c==1
            idx=1:3;
        elseif c==2
            idx=3:5;
        else
            idx=5:7;
        end
    
        Magn_chunk=Magn(:,:,:,idx);
        Phs_chunk=Phs(:,:,:,idx);
        TE_chunk=TE(idx);
        epsilon=std(Magn_E1(Magn_E1<10)) / sqrt(2);

        [iFreq, N_std] = Fit_ppm_complex(Magn_chunk .* exp(-1i*Phs_chunk));
        qMask=(N_std<(mean(N_std(Mask>1),"all"))) .* Mask;
        % Spatial unwrapping, use Magn_E1 as quality map.
        [iFreq] = UnwrapSingleTE_ROMEO(iFreq, Magn_E1, Mask, vsz, output_dir);
        % [iFreq] = unwrapping_gc(iFreq, Magn_E1, vsz, 2);
        iFreq = iFreq / (d_TE*2*pi); % Hz

        % Referencing
        iFreq = iFreq - mean(iFreq(csf_mask > 0));
        % Background field correction
        B0_dir = [0 0 1];
        N = size(Mask);
        RDF = PDF(iFreq, N_std, Mask, N, vsz, B0_dir);
        [~, RDF, ~]     = PolyFit(RDF, Mask, 4);
        RDF = pad_or_crop_target_size(RDF, vsz, fov);
        Magn_chunk = pad_or_crop_target_size(Magn_chunk,vsz,fov);
        TE_4D = match_dims(TE_chunk, Magn_chunk);
        SNR_f = 2*pi*RDF ./ sqrt(sum(epsilon ./ (Magn_chunk .* TE_4D) .^2, 4)); % rad

        outname = fullfile(output_dir, ...
            sprintf('%s_SNR_frequency_Echoes_%d_to_%d', dataset{1}, idx(1), idx(3)));
        export_nii(SNR_f, outname, vsz);

    % [~,Delta]=CalculateChiMapfromLF(RDF, fs);
    % Delta=pad_or_crop_target_size(Delta,vsz,fov);
    % export_nii(Delta, fullfile(output_dir, [dataset{1}, '_Delta']), vsz);
    % x=x+1;
    % B(:,:,:,x)=Delta;   
    end
end

%%
% save("3T_COSMOS_6_inputVars.mat", "B", '-append');

for dataset = i
    %% Step 2: Dipole inversion

    % Mask from N_std -> removes erroneous voxels from inversion problem
    % qMask_1 = N_std < (mean(N_std(Mask==1), 'all'));
    % qMask_1 = qMask_1 .* Mask;    
    qMask_dir='C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\Brain_ROI_Mask';
    if ~contains(dataset{1}, 'Neutral')
        str = [dataset{1}(1:2), '_Neutral_to_', dataset{1}(4:end)];
    else
        str = dataset{1};
    end
    qMask=load_untouch_nii(fullfile(qMask_dir, [str, '_Mask_Use.nii.gz']));    
    qMask=pad_or_crop_target_size(qMask.img, vsz, fov_pad);
    % Smoothing qMask -> more "natural" appearance, using 3x3x3 Gaussian kernel (SD = 1 vox)   
    % qMask = smooth3(qMask, 'gaussian', 3, 1);
    % qMask = qMask > 0.5; % Binarizing
    % qMask=qMask.*qMask_ROMEO;
    qMask = imopen(qMask, strel('sphere', 1)); % Removes disconnected voxels
    qMask_crop=pad_or_crop_target_size(qMask, vsz, fov);
    export_nii(qMask_crop, fullfile(output_dir, [dataset{1}, '_qMask']), vsz);
    %%
    % weights calculation, then inversion as required for MEDI_L1 function
    weights=sepia_utils_compute_weights_v1(N_std, Mask);
    N_std=Mask ./ weights;
    N_std(isnan(N_std))=0;
    N_std(isinf(N_std))=0;    
    
    % Constant vars
    if contains(dataset{1}, '3T')
        B0=2.89;
    else
        B0=7;
    end
    gyro=42.6*10^6; % Hz/T
    CF=B0*gyro; % Hz


    
    % Prepare struct for MEDI_L1 function
    B0_dir=B0_dir';
    iMag = sqrt(sum(abs(Magn).^2,4));
    voxel_size=vsz;
    delta_TE=d_TE;
    RDF = single(RDF .* (2*pi*d_TE)); % Hz to rad

    % Remove zero-padding
    iFreq=[];
    RDF=pad_or_crop_target_size(RDF, vsz, fov);
    N_std=pad_or_crop_target_size(N_std, vsz, fov);
    iMag=pad_or_crop_target_size(iMag, vsz, fov);
    qMask=pad_or_crop_target_size(qMask, vsz, fov);
    N=size(qMask);
    % csf_mask=pad_or_crop_target_size(csf_mask, vsz, fov);
    csf_mask=[];

    % Clear up large files from workspace
    clear('Magn', 'Phs');

    tmp_filename = fullfile(output_dir, [dataset{1}, '_tmp_RDF.mat']);
    s = struct('iFreq', iFreq, 'RDF', RDF, 'N_std', N_std, 'iMag', iMag, ...
        'Mask', qMask, 'matrix_size', N, 'voxel_size', vsz, 'delta_TE', d_TE, ...
        'CF', CF, 'B0_dir', B0_dir, 'Mask_CSF', csf_mask);
    
    save(tmp_filename, '-fromstruct', s);

    % Clear up large files from workspace
    clear('Magn', 'Phs', 'iFreq', 'RDF', 'N_std', 'iMag', 'qMask'); 
    
    if exist(fullfile('.', 'results'), 'dir')
        isResultDirMEDIExist=true;
    else
        isResultDirMEDIExist=false;
    end
    
    % Algorithm parameters
    lambda = 10^3;
    lam_CSF = 10^2;
    isMerit = false;
    wData = true;
    wGrad = true;
    padsize = 40;
    percentage = 0.5;
   %%
    [qsm, ~, ~] = MEDI_L1('filename', tmp_filename, 'lambda', lambda, ...
        'data_weighting', wData, 'gradient_weighting', wGrad, ...
        'merit', isMerit, 'zeropad', padsize, 'lambda_CSF', lam_CSF, ...
        'percentage', percentage);

    Mask=pad_or_crop_target_size(Mask,vsz,fov);
    qsm = (qsm-0.1106) .* Mask;
    qsm = pad_or_crop_target_size(qsm, vsz, fov); 
    csf_mask=load_untouch_nii(fullfile(csf_dir, [str, '_CSF_Mask.nii.gz']));
    csf_mask=pad_or_crop_target_size(csf_mask.img, vsz, fov);
    % Referencing
    qsm = qsm - mean(qsm(csf_mask > 0));

    delete(tmp_filename);
    if isResultDirMEDIExist
        fileno=getnextfileno(['results' filesep], 'x', '.mat') -1;
        resultsfile=['results' filesep 'x', sprintf('%08u', fileno), '.mat'];
        delete(resultsfile);
    else
        rmdir(fullfile(pwd, 'results'), 's');
    end
    
    export_nii(qsm, fullfile(output_dir, [dataset{1}, '_QSM']), vsz);

end
        %% Re-order ROIs

        % tmp1 = (roi == 1)*4; 
        % tmp2 = (roi == 2)*5;
        % tmp3 = (roi == 3)*6;
        % tmp4 = (roi == 4)*3;
        % tmp5 = (roi == 5)*2;
        % tmp6 = (roi == 6)*1;
        % roi = tmp1 + tmp2 + tmp3 + tmp4 + tmp5 + tmp6;
        % export_nii(roi,fullfile(roi_dir, [fs_str, '_ROIs_Use.nii.gz']), [.75 .75 .75]);    

    %% Target (7T->3T)
    % 3T_1: Fe_H
    % 2: Ca_L
    % 3: Ca_H
    % 4: Fe_L
    % 5: Str_Trans
    % 6: Str_Prl

    % 7T_1: Str_Trans
    % 7T_2: Ca_L -> DONE
    % 7T_3: Fe_H
    % 7T_4: Ca_H
    % 7T_5: Fe_L
    % 7T_6: Str_Prl -> DONE


    % if contains(dataset{1}, '7T')
    %     tmp1 = (roi == 1)*5; 
    %     tmp2 = (roi == 2)*2;
    %     tmp3 = (roi == 3)*1;
    %     tmp4 = (roi == 4)*3;
    %     tmp5 = (roi == 5)*4;
    %     tmp6 = (roi == 6)*6;
    %     roi = tmp1 + tmp2 + tmp3 + tmp4 + tmp5 + tmp6;
    %     export_nii(roi,fullfile(roi_dir, [fs_str, '_ROIs_Use.nii.gz']), [.75 .75 .75]);
    % end
    
        % if contains(dataset{1}, '7T')
    %     % Swap q=1 and q=5 entries
    %     tmp = Rmse(1); Rmse(1) = Rmse(5); Rmse(5) = tmp;
    %     tmp = Hfen(1); Hfen(1) = Hfen(5); Hfen(5) = tmp;
    %     tmp = Xsim(1); Xsim(1) = Xsim(5); Xsim(5) = tmp;    
    %     tmp=Mean_qsm(1); Mean_qsm(1)=Mean_qsm(5); Mean_qsm(5)=tmp;
    %     tmp=Mean_ref(1); Mean_ref(1)=Mean_ref(5); Mean_ref(5)=tmp;
    %     tmp=diffSD(1); diffSD(1)=diffSD(5); diffSD(5)=tmp;
    %     tmp=diffMean(1); diffMean(1)=diffMean(5); diffMean(5)=tmp;
    % end

            Mean_qsm(q) = round(mean(qsm(roi==q)) .* 1e3); % Round to nearest ppb
        Mean_ref(q) = round(mean(ref(roi==q)) .* 1e3);
        [diffSD(q), diffMean(q)] = std(Mean_qsm(q)-Mean_ref(q));

            mdl = fitlm(Mean_qsm, Mean_ref, 'linear'); 
    intercept=mdl.Coefficients{1,1};
    slope=mdl.Coefficients{2,1};
    SE_intercept=mdl.Coefficients{1,2};
    SE_slope=mdl.Coefficients{2,2};

        Mean_qsm = zeros(nsamples,1);
    Mean_ref = zeros(nsamples,1);
    diffSD = zeros(nsamples,1);
    diffMean = zeros(nsamples,1);

        M_diffSD=mean(diffSD);
    M_diffMean=mean(diffMean);
        % savefile = fullfile(output_dir, [dataset{1}, '_', num2str(n_orient), '_Vars.mat']);
    % save(savefile, 'M_Rmse', 'M_Hfen', 'M_Xsim', 'M_diffSD', 'M_diffMean', ...
    %     'Rmse', 'Hfen', 'Xsim', 'diffSD', 'diffMean', 'Mean_qsm', 'Mean_ref',...
    %     'intercept', 'slope', 'SE_intercept', 'SE_slope'); % 'Cc', 'Mi', 'Gxe', 'Mad', 'Madgx', 

    %% Step 3: Compare to COSMOS
%'3T_Neutral', '3T_Rot1', '3T_Rot2', '3T_Rot3', '3T_Rot6', ...'3T_Neutral', '3T_Rot1', '3T_Rot2', ...
    % '7T_Neutral', '7T_Rot1', '7T_Rot2', '7T_Rot3', '7T_Rot4', '7T_Rot6'


    clc
    clear
    close all
    output_dir = 'C:\Users\rosly\Documents\Valerie_PH\field_to_chi\analysis';
    ref_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\COSMOS_SNRwAVG_PDF\deGibbs';
    qsm_dir='C:\Users\rosly\Documents\Valerie_PH\field_to_chi\Registered';
    % qsm_dir='C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\SNRwAVG_PDF';
    roi_dir = 'C:\Users\rosly\Documents\Valerie_PH\ROIs';
    mask_dir =  'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\SDC';
 
i={'3T_Neutral', '3T_Rot1', '3T_Rot2', '3T_Rot3', '3T_Rot5', '3T_Rot6', ...
    '7T_Neutral', '7T_Rot1', '7T_Rot2', '7T_Rot3', '7T_Rot4', '7T_Rot5'}; 
%  
% 
Rmse_matr=[];
Hfen_matr=[];
Xsim_matr=[];
ROIe_matr=[];
for dataset = i    
    if contains(dataset{1}, '7T')
        n_orient=4;
        vsz=[.75 .75 .75];
    else
        n_orient=5;
        vsz=[1 1 1];
    end
    % Load in `ref' (ie COSMOS)
    ref_fn = fullfile(ref_dir, [dataset{1}(1:2), '_chi_CF_', num2str(n_orient), '_Orient.nii.gz']);
    ref=load_untouch_nii(ref_fn);
    ref=ref.img;

    % Load in `qsm' (ie MEDI)
    if ~contains(dataset{1}, 'Neutral')
        str = [dataset{1}(1:2), '_Neutral_to_', dataset{1}(4:end)];
    else
        str = dataset{1};
    end
    qsm=load_untouch_nii(fullfile(qsm_dir, [str, '_QSM_FLIRT.nii.gz']));
    qsm=qsm.img;
    
    % Load in `roi' (ie segmentation)
    fs_str=dataset{1}(1:2);
    roi=load_untouch_nii(fullfile(roi_dir, [fs_str, '_ROIs_Use.nii.gz']));
    roi=single(roi.img);

    dilate_vox= round(5/min(vsz)); % 5 mm
    roi_dilate = imdilate(roi, strel('sphere',dilate_vox));

    % Load in 'mask'
    mask=load_untouch_nii(fullfile(mask_dir, [fs_str, '_Neutral_mask_FLIRT.nii.gz']));
    mask=single(mask.img);

    nsamples=6;
    
    Rmse = zeros(nsamples,1);
    % Hfen = zeros(nsamples,1);
    Xsim = zeros(nsamples,1);
    % ROIe = zeros(nsamples,1);

    for q = 1:nsamples
        % chi_diff = (qsm(:)-ref(:)).*(roi_dilate(:)==q);
        % ROIe(q,:)=mean(chi_diff(chi_diff~=0));
        % metrics = compute_metrics(qsm, ref, roi_dilate==q);
        % Rmse(q,:)=metrics.rmse;
        Rmse(q,:)=compute_rmse( qsm, ref, roi_dilate==q );
        % Hfen(q,:)=metrics.hfen;
        Xsim(q,:)=compute_xsim( qsm, ref, roi_dilate==q );
    end


    % Rmse_matr=cat(1, Rmse_matr, Rmse);
    % Hfen_matr=cat(1, Hfen_matr, Hfen);
    % Xsim_matr=cat(1, Xsim_matr, Xsim);
    % ROIe_matr=cat(1, ROIe_matr, ROIe);    
    Rmse_matr = [Rmse_matr Rmse];
    % Hfen_matr = [Hfen_matr Hfen];
    Xsim_matr = [Xsim_matr Xsim];
    % ROIe_matr = [ROIe_matr ROIe];
    fprintf('Processed Dataset %s \n', dataset{1});    
   
end

save(fullfile(output_dir, "Vars_Similarity.mat"), "Rmse_matr", "Xsim_matr");

%% All 6

output_dir = 'C:\Users\rosly\Documents\Valerie_PH\field_to_chi\analysis';

load(fullfile(output_dir, 'Vars_Similarity_noDilate.mat'), "Rmse_matr", "Xsim_matr");

Rmse_matr_analysis = [mean(Rmse_matr(:,1:6),2) mean(Rmse_matr(:,7:12),2)];
% Hfen_matr_analysis = [mean(Hfen_matr(:,1:6),2) mean(Hfen_matr(:,7:12),2)];
Xsim_matr_analysis = [mean(Xsim_matr(:,1:6),2) mean(Xsim_matr(:,7:12),2)];
% ROIe_matr_analysis = [mean(ROIe_matr(:,1:6),2) mean(ROIe_matr(:,7:12),2)];

%% Only first 3



Rmse_matr_analysis = [mean(Rmse_matr(:,1:3),2) mean(Rmse_matr(:,7:10),2)];
% Hfen_matr_analysis = [mean(Hfen_matr(:,1:3),2) mean(Hfen_matr(:,7:9),2)];
Xsim_matr_analysis = [mean(Xsim_matr(:,1:3),2) mean(Xsim_matr(:,7:10),2)];
% ROIe_matr_analysis = [mean(ROIe_matr(:,1:3),2) mean(ROIe_matr(:,7:9),2)];

    % Rmse_mean_1=mean(Rmse_matr(1:3,:),1);
    % Rmse_mean_2=mean(Rmse_matr(4:7,:),1);
    % Hfen_mean_1=mean(Hfen_matr(1:3,:),1);
    % Hfen_mean_2=mean(Hfen_matr(4:7,:),1);
    % Xsim_mean_1=mean(Xsim_matr(1:3,:),1);  
    % Xsim_mean_2=mean(Xsim_matr(4:7,:),1);
    % ROIe_mean_1=mean(ROIe_matr(1:3,:),1);
    % ROIe_mean_2=mean(ROIe_matr(4:7,:),1);

   
    % Rmse_matr_analysis = [Rmse_mean_1; Rmse_mean_2];
    % Hfen_matr_analysis = [Hfen_mean_1; Hfen_mean_2];
    % Xsim_matr_analysis = [Xsim_mean_1; Xsim_mean_2];
    % ROIe_matr_analysis = [ROIe_mean_1; ROIe_mean_2];

    %%

    output_dir = 'C:\Users\rosly\Documents\Valerie_PH\field_to_chi\analysis';

    x_fields = {'3T', '7T'};
    zlabels={['Straw, ', char(0x2225)], 'Straw, \perp', 'Ellipsoid, Low Fe', ...
        'Ellipsoid, High Fe', 'Ellipsoid, Low Ca', 'Ellipsoid, High Ca'};

    figure, hold on
    bar(x_fields, Rmse_matr_analysis, 0.8, 'grouped');
    colororder('glow');
    hold on
    ylabel('RMSE (%)');
    yticks('auto')
    pbaspect([1 1 1]);
    legend(zlabels, 'Location', 'bestoutside');
    hold off
    saveas(gcf, fullfile(output_dir, 'RMSE_Ch7.png'));

    % figure, hold on
    % bar(x_fields, Hfen_matr_analysis, 0.8, 'grouped');
    % colororder("glow");
    % hold on
    % ylabel("HFEN (%)")
    % yticks("auto")
    % pbaspect([1 1 1])
    % legend(zlabels, 'Location', 'bestoutside')
    % hold off
    % saveas(gcf, fullfile(output_dir, 'HFEN_Ch7.png'));

    figure, hold on
    bar(x_fields, Xsim_matr_analysis, 0.8, "grouped");
    colororder("glow")
    hold on
    ylabel("XSIM (0-1)")
    % ylim([0.9 1]);
    % yticks([0.9 0.95 1])
    pbaspect([1 1 1])
    legend(zlabels, 'Location', 'bestoutside')
    hold off
    saveas(gcf, fullfile(output_dir, 'XSIM_Ch7.png'));

    % figure, hold on
    % bar(x_fields, ROIe_matr_analysis, 0.8, "grouped")
    % colororder("glow")
    % hold on
    % ylabel("ROI error (ppm)")
    % yticks("auto")
    % pbaspect([1 1 1]);
    % legend(zlabels,'Location','bestoutside')
    % hold off
    % saveas(gcf, fullfile(output_dir, 'ROI_error_Ch7.png'));


%%
i={'3T_Neutral', '3T_Rot1', '3T_Rot2'};
Xsim_matr=zeros(6,3);
% Rmse_matr=zeros(6,3);
x=0;
for dataset=i
    load([dataset{1}, '_5_Vars.mat'], 'Xsim', 'Rmse');
    x=x+1;
    Xsim_matr(:,x)=Xsim;
    % Rmse_matr(:,x)=Rmse;
end
[Xsim_sd_1, Xsim_mean_1]=std(Xsim_matr,2);
% Rmse_mean=mean(Rmse_matr,2);
% save(fullfile(output_dir, '3T_Mean_HeadCoil'), 'Xsim_mean', 'Rmse_mean');

    output_dir = 'C:\Users\rosly\Documents\Valerie_PH\field_to_chi\analysis';

i={'3T_Rot3', '3T_Rot5', '3T_Rot6'};
Xsim_matr=zeros(6,3);
% Rmse_matr=zeros(6,3);
x=0;
for dataset=i
    load([dataset{1}, '_5_Vars.mat'], 'Xsim', 'Hfen', 'Rmse');
    x=x+1;
    Xsim_matr(:,x)=Xsim;
    % Rmse_matr(:,x)=Rmse;
end
[Xsim_sd_2, Xsim_mean_2]=std(Xsim_matr,2);
% Rmse_mean=mean(Rmse_matr,2);
% save(fullfile(output_dir, '3T_Mean_SurfaceCoil'), 'Xsim_mean', 'Rmse_mean');



Xsim_matr=zeros(6,3);
Rmse_matr=zeros(6,3);
y=0;
j={'7T_Neutral', '7T_Rot1', '7T_Rot2', '7T_Rot3'};

for dataset=j
    load([dataset{1}, '_4_Vars.mat'], 'Xsim', 'Rmse');
    y=y+1;
    Xsim_matr(:,y)=Xsim;
    % Rmse_matr(:,y)=Rmse;    
end
[Xsim_sd_3, Xsim_mean_3]=std(Xsim_matr,2);
% Rmse_mean=mean(Rmse_matr,2);
% save(fullfile(output_dir, '7T_Mean_HeadCoil'), 'Xsim_mean', 'Rmse_mean');

j={'7T_Rot4', '7T_Rot5'};
y=0;
for dataset=j
    load([dataset{1}, '_4_Vars.mat'], 'Xsim', 'Rmse');
    y=y+1;
    Xsim_matr(:,y)=Xsim;
    % Rmse_matr(:,y)=Rmse;    
end
[Xsim_sd_4, Xsim_mean_4]=std(Xsim_matr,2);
% Rmse_mean=mean(Rmse_matr,2);
% save(fullfile(output_dir, '7T_Mean_SurfaceCoil'), 'Xsim_mean', 'Rmse_mean');
%%
Xsim_matr = [Xsim_mean_1 Xsim_mean_2 Xsim_mean_3 Xsim_mean_4];

    x_fields={'3T_{Head coil}', '3T_{Surface coil}', '7T_{Head coil}', '7T_{Surface coil}'};   
    zlabels={['Straw, ', char(0x2225)], 'Straw, \perp', 'Ellipsoid, Low Fe', ...
        'Ellipsoid, High Fe', 'Ellipsoid, Low Ca', 'Ellipsoid, High Ca'};
    figure, hold on
    bar(x_fields, Xsim_matr', 0.8, "grouped");
    colororder("glow")
    hold on
    ylabel('XSIM');
    yticks([0 .25 .5 .75 1]);
    ylim([0 1])
    pbaspect([1 1 1])
    legend(zlabels, 'Location', 'southeast'); 
    hold off

    saveas(gcf,fullfile(output_dir,'XSIM.png'));
