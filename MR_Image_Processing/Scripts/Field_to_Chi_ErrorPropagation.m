%% Field_to_chi_ErrorPropagation.m
% Compares `MEDI+0' to `infinite cylinder model' within the ROI 
% (ROI constrained via the `internal field mask')

%% Step (1): Generate internal field mask

clc
clear

data_dir='C:\Users\rosly\Documents\QSM_PH\Analysis\Morozov';    
out_dir='C:\Users\rosly\Documents\QSM_PH\Analysis\internal_field_mask';
i = {'3T_9mth', '7T_9mth'}; % 

for dataset=i
    if contains(dataset{1}, '3T')
        vsz = [1 1 1]; 
        fov=[192 192 104] .* mean(vsz);
        o_mm=0;
    else
        vsz=[.7 .7 .7];        
        fov=round([238 272 160] .* mean(vsz));
    end

    file = fullfile(data_dir, [dataset{1}, '_workspace.mat']);
    load(file, 'hdr');
    hdr.R2s = pad_or_crop_target_size(hdr.R2s, vsz, fov);
    export_nii(hdr.R2s, [dataset{1}, '_R2s'], vsz);  
    % hdr.R2s = hdr.R2s ./ max(hdr.R2s); % Normalize
    % BW = edge3(hdr.R2s,'approxcanny', 0.5);
    % export_nii(BW, [dataset{1}, '_R2s_Edges'], vsz);
    hdr.CSF_Mask = pad_or_crop_target_size(hdr.CSF_Mask, vsz, fov);
    hdr.relativeResidualMask = pad_or_crop_target_size(hdr.relativeResidualMask, vsz, fov);
    hdr.Mask_Use = pad_or_crop_target_size(hdr.Mask_Use, vsz, fov);
    if contains(dataset{1}, '7T')
        hdr.relativeResidualMask(:,:, 1:70) = 0;
        hdr.CSF_Mask(:,:, 1:70) = 0;       
        hdr.Mask_Use(:,:, 1:70) = 0;
    end    
    % Step (i) Erode BET mask by 8 mm (already done 2 mm)
    hdr.Mask_Use = imfill(logical(hdr.Mask_Use), 26, 'holes'); % Removing any holes
    e_vox = round(8 ./ min(vsz) );
    eroded_BET_mask = imerode(logical(hdr.Mask_Use), strel('sphere', e_vox));
    export_nii(eroded_BET_mask, [dataset{1}, '_eroded_BET_mask'], vsz);
    % Step (ii) Generate complement of CSF mask
    CSF_Mask_Complement = imcomplement(logical(hdr.CSF_Mask));
    export_nii(CSF_Mask_Complement, [dataset{1}, '_CSF_Complement'], vsz);
    % Step (iii) Generate RR quality mask
    rrmask = (hdr.relativeResidualMask>0);
    export_nii(rrmask, [dataset{1}, '_rrmask'], vsz);
    % Step (iv) Multiply these 3 masks together
    mask = (eroded_BET_mask>0) .* (rrmask>0) .* (CSF_Mask_Complement>0);
    export_nii(mask, [dataset{1}, '_multiplication'], vsz);
    % Step (v) Additional morphological operations
    if contains(dataset{1}, '3T')
        % erode by 2 mm (3 T)
        e_vox = round(2 ./ min(vsz));
        mask = imerode(logical(mask), strel('sphere', e_vox));
    end    

    % Close by 5 mm (3 T and 7 T)
    o_vox = round(5 ./ min(vsz));
    mask = imclose(mask, strel('sphere', o_vox));

    export_nii(mask, fullfile(out_dir, [dataset{1}, '_internal_field_mask']), vsz);
    % Step (vi) Perform segmentation
    % seg = imsegkmeans3(single(hdr.R2s),20);
    % export_nii(seg, fullfile(out_dir, [dataset{1}, '_segmentation']), vsz);

    % [mask] = generateinternalfieldmask(Mask_Use, CSF_Mask, vsz, e_mm, o_mm);  

    % export_nii(hdr.CSF_Mask, fullfile(out_dir, [dataset{1}, '_CSF_mask']), vsz);
    
end
%% Step (2): Crop matrices for registration

i = {'3T_9mth', '7T_9mth'}; % 
qsm_dir='C:\Users\rosly\Documents\QSM_PH\Analysis\Tik';
% ref_dir='C:\Users\rosly\Documents\QSM_PH\Analysis\Morozov';    

for dataset=i
    if contains(dataset{1}, '3T')
        vsz=[1 1 1];
        fov=[192 192 104] .* mean(vsz);
    else
        vsz = [.7 .7 .7]; 
        fov=round([238 272 160] .* mean(vsz));
    end

    % qsm_nii=load_untouch_nii(fullfile(qsm_dir, [dataset{1}, '_Tik_10_QSM.nii.gz']));
    % qsm=pad_or_crop_target_size(qsm_nii.img, vsz, fov);
    % export_nii(qsm, fullfile(qsm_dir, [dataset{1}, '_Tik_10_Crop']), vsz);
    % ref_nii=load_untouch_nii(fullfile(ref_dir, [dataset{1}, '_InfCyl.nii.gz']));
    % ref=pad_or_crop_target_size(ref_nii.img, vsz, fov);
    % export_nii(ref, fullfile(ref_dir, [dataset{1}, '_InfCyl_Crop']), vsz);
    % mask_nii=load_untouch_nii(fullfile(ref_dir, [dataset{1}, '_internal_field_mask.nii.gz']));
    % mask=pad_or_crop_target_size(mask_nii.img, vsz, fov);
    % export_nii(mask, fullfile(qsm_dir, [dataset{1}, '_internal_mask_Crop']), vsz);
    csf_nii=load_untouch_nii(fullfile(qsm_dir, [dataset{1}, '_CSF_Mask.nii.gz']));
    csf=pad_or_crop_target_size(csf_nii.img, vsz, fov);
    export_nii(csf, fullfile(qsm_dir, [dataset{1}, '_CSF_mask_Crop']), vsz);
end
%analysis_dir='C:\Users\rosly\Documents\QSM_PH\Analysis\field_to_chi';

%% Step (3): Run_antsApplyTransforms.sh script to obtain phantom symmetry.

%% Step (4): Prepare for segmentation
% Quad #1 = Ferritin
% Quad #2 = USPIO
% Quad #3 = CaCl2
% Quad #4 = CaCO3

clc
clear
close all

analysis_dir='C:\Users\rosly\Documents\QSM_PH\Analysis\field_to_chi';
roi_dir='C:\Users\rosly\Documents\QSM_PH\Analysis\internal_field_mask';
i={'3T_9mth', '7T_9mth'};

for dataset = i
    internal_mask_nii=load_untouch_nii(fullfile(analysis_dir, [dataset{1}, '_internal_mask_Quad_Erode.nii.gz']));
    internal_mask_quads = ProcessQuadIdpt(dataset, internal_mask_nii.img);
    if contains(dataset{1}, '3T')
        vsz=[1 1 1];
    else
        vsz=[.7 .7 .7];
    end
    for q = 1:4
        export_nii(internal_mask_quads{q}, fullfile(roi_dir, [dataset{1}, '_mask_Quad_', num2str(q), '.nii.gz']), vsz);
    end
end

%% Step 5: Assign values to segmentation

clc
clear
close all

roi_dir='C:\Users\rosly\Documents\QSM_PH\Analysis\internal_field_mask';
i={'3T_9mth', '7T_9mth'};

for dataset = i
    nii=cell(1,4);
    seg=cell(1,4);
    for q = 1:4
        nii{q}=load_untouch_nii(fullfile(roi_dir, [dataset{1}, '_seg_Quad_', num2str(q), '.nii.gz']));
        seg{q}=single(nii{q}.img);
        % export_nii(mask_quads{q}, fullfile(roi_dir, [dataset{1}, '_mask_Quad_', num2str(q), '.nii.gz']), vsz);
    end
        Seg=zeros(size(seg{1}));
        Seg(seg{1}==4)=6;
        Seg(seg{1}==5)=7;
        Seg(seg{1}==1)=8;
        Seg(seg{1}==3)=9;
        Seg(seg{1}==2)=10;    
        Seg(seg{2}==1)=5;
        Seg(seg{2}==4)=4;
        Seg(seg{3}==2)=13;
    if contains(dataset{1}, '3T')
        vsz=[1 1 1];
        Seg(seg{2}==3)=1;
        Seg(seg{2}==5)=2;
        Seg(seg{2}==2)=3;
        Seg(seg{3}==4)=11;
        Seg(seg{3}==5)=12;
        Seg(seg{3}==1)=14;
        Seg(seg{3}==3)=15;
        Seg(seg{4}==1)=16;
        Seg(seg{4}==2)=18;
        Seg(seg{4}==3)=17;
        Seg(seg{4}==4)=20;
        Seg(seg{4}==5)=19;
    else
        vsz=[.7 .7 .7];
        Seg(seg{2}==4)=1;
        Seg(seg{2}==3)=2;
        Seg(seg{2}==5)=3;
        Seg(seg{2}==2)=4;
        Seg(seg{3}==5)=11;
        Seg(seg{3}==1)=12;
        Seg(seg{3}==3)=14;
        Seg(seg{3}==4)=15;
        Seg(seg{4}==5)=16;
        Seg(seg{4}==4)=17;
        Seg(seg{4}==2)=18;
        Seg(seg{4}==1)=19;
        Seg(seg{4}==3)=20;        
    end

    export_nii(Seg, fullfile(roi_dir, [dataset{1}, '_segmentation_init.nii.gz']), vsz);

end

% qsm_nii=load_untouch_nii(fullfile(analysis_dir, [dataset{1}, '_Tik_10_Crop_Quad.nii.gz']));
% seg_nii=load_untouch_nii(fullfile(analysis_dir, [dataset{1}, '_segmentation.nii.gz']));
% imagesc3d2(qsm_nii.img);
% qsm_quads = ProcessQuadIdpt(dataset, qsm_nii.img);
% seg_quads = ProcessQuadIdpt(dataset, seg_nii.img);
% pos = round(size(qsm_quads{1})/2);
% for q = 1:4
%     imagesc3d2(qsm_quads{q}, pos, q);
%     imagesc3d2(seg_quads{q}, pos, q+4);
% end





%% Step (5): Perform field_to_chi_ErrorPropagation analysis

clc
clear
close all
%'3T_BL', '3T_BL_Rep', '7T_BL', '7T_BL_Rep',
i = { '3T_BL', '3T_BL_Rep', '3T_9mth', '3T_24mth', '3T_24mth_Rep', ...
     '7T_BL', '7T_BL_Rep', '7T_9mth', '7T_24mth', '7T_24mth_Rep'}; %  
analysis_dir='C:\Users\rosly\Documents\QSM_PH\Analysis\field_to_chi';
ref_dir='C:\Users\rosly\Documents\QSM_PH\Analysis\VSH8_SEPIA';
qsm_dir='C:\Users\rosly\Documents\QSM_PH\Analysis\VSH8_SEPIA';
Rmse_matr=[];
Hfen_matr=[];
Xsim_matr=[];
ROIe_matr=[];
x=0;
for dataset=i
    if contains(dataset{1}, '3T')
        vsz=[1 1 1];
        fov=[192 192 104] .* mean(vsz);
    else
        vsz=[.7 .7 .7];
        fov=round([238 272 160] .* mean(vsz));
    end
    qsm_nii=load_untouch_nii(fullfile(qsm_dir, [dataset{1}, '_QSM.nii.gz']));
    ref_nii=load_untouch_nii(fullfile(ref_dir, [dataset{1}, '_InfCyl.nii.gz']));
    internal_mask_nii=load_untouch_nii(fullfile(analysis_dir, [dataset{1}(1:2), '_9mth_internal_mask_Quad_Erode.nii.gz']));
    csf_nii=load_untouch_nii(fullfile(analysis_dir, [dataset{1}(1:2), '_9mth_CSF_mask_Crop_Quad.nii.gz']));
    mask_nii=load_untouch_nii(fullfile(analysis_dir, [dataset{1}(1:2), '_9mth_Mask.nii.gz']));

    if contains(dataset{1}, '7T')
        qsm_nii.img(:,:, 1:70) = 0;
        ref_nii.img(:,:, 1:70) = 0;
        internal_mask_nii.img(:,:, 1:70) = 0;
        csf_nii.img(:,:, 1:70) = 0;       
        mask_nii.img(:,:,1:70)=0;
    end

    qsm_quads = ProcessQuadIdpt(dataset, qsm_nii.img);
    ref_quads = ProcessQuadIdpt(dataset, ref_nii.img);
    internal_mask_quads = ProcessQuadIdpt(dataset, internal_mask_nii.img);
    csf_quads = ProcessQuadIdpt(dataset, csf_nii.img);
    mask_quads=ProcessQuadIdpt(dataset, mask_nii.img);

    Rmse = zeros(1,4);
    Hfen = zeros(1,4);
    Xsim = zeros(1,4);
    ROIe = zeros(1,4);
    % Cc = cell(1,4);
    % Mi = cell(1,4);
    % Gxe = cell(1,4);
    % Mad = cell(1,4);
    % Madgx = cell(1,4);
    % SD_csf = cell(1,4);

    mode = 0; % 2 - include extended and gradient domain metrics

    for q = 1:4
        if (q==2 && contains(dataset{1}, '24mth')) || (q==4 && contains(dataset{1}, 'BL'))
            Rmse(:,q)=0; 
            Hfen(:,q)=0;
            Xsim(:,q)=0;
            ROIe(:,q)=0;
        else    
            [ metrics ] = compute_metrics( qsm_quads{q}, ref_quads{q}, mask_quads{q}); % , mask_quads{q}, mode
            Rmse(:,q) = metrics.rmse;
            Hfen(:,q) = metrics.hfen;
            Xsim(:,q) = metrics.xsim;
            chi_recon=qsm_quads{q}.*(internal_mask_quads{q}==1);
            chi_true=ref_quads{q}.*(internal_mask_quads{q}==1);        
            chi_diff=(chi_recon(:) - chi_true(:)).*1e3;
            ROIe(:,q) = mean(chi_diff(chi_diff ~= 0));
        end
        % Cc{q} = round(metrics.cc, 2);
        % Mi{q} = round(metrics.mi, 2);
        % Gxe{q} = round(metrics.gxe);
        % Mad{q} = round(metrics.mad);
        % Madgx{q} = round(metrics.madgx);
        % SD_csf{q} = round(std(qsm_quads{q}(csf_quads{q}>0)) .* 1e3);
    end
    x=x+1;
    if contains(dataset{1},'24mth')
        % Quad1->Quad2
        % Quad2->Quad3
        % Quad3->Quad1
        % Quad4->Quad4
        Rmse = [Rmse(3) Rmse(1) Rmse(2) Rmse(4)];
        Hfen = [Hfen(3) Hfen(1) Hfen(2) Hfen(4)];
        Xsim = [Xsim(3) Xsim(1) Xsim(2) Xsim(4)];
        ROIe = [ROIe(3) ROIe(1) ROIe(2) ROIe(4)];
    end

    % Swap q=1 and q=2 entries
    % tmp = Rmse{1}; Rmse{1} = Rmse{2}; Rmse{2} = tmp;
    % tmp = Hfen{1}; Hfen{1} = Hfen{2}; Hfen{2} = tmp;
    % tmp = Xsim{1}; Xsim{1} = Xsim{2}; Xsim{2} = tmp;
    % tmp = Cc{1}; Cc{1} = Cc{2}; Cc{2} = tmp;
    % tmp = Mi{1}; Mi{1} = Mi{2}; Mi{2} = tmp;
    % tmp = Gxe{1}; Gxe{1} = Gxe{2}; Gxe{2} = tmp;
    % tmp = Mad{1}; Mad{1} = Mad{2}; Mad{2} = tmp;
    % tmp = Madgx{1}; Madgx{1} = Madgx{2}; Madgx{2} = tmp;
    % tmp = SD_csf{1}; SD_csf{1} = SD_csf{2}; SD_csf{2} = tmp;


    % savefile = fullfile(analysis_dir, [dataset{1}, '_Vars.mat']);
    % save(savefile, 'Rmse', 'Hfen', 'Xsim', 'Cc', 'Mi', 'Gxe', 'Mad', 'Madgx', 'SD_csf');
    Rmse_matr=cat(1, Rmse_matr, Rmse);
    Hfen_matr=cat(1, Hfen_matr, Hfen);
    Xsim_matr=cat(1, Xsim_matr, Xsim);
    ROIe_matr=cat(1, ROIe_matr, ROIe);
    fprintf('Processed Dataset %s \n', dataset{1});    
end


Rmse_mean_1 = mean(Rmse_matr(1:5,:), 1);
Rmse_mean_2 = mean(Rmse_matr(6:10,:), 1);
Hfen_mean_1 = mean(Hfen_matr(1:5,:), 1);
Hfen_mean_2 = mean(Hfen_matr(6:10,:), 1);
Xsim_mean_1 = mean(Xsim_matr(1:5,:), 1);
Xsim_mean_2 = mean(Xsim_matr(6:10,:), 1);
ROIe_mean_1 = mean(ROIe_matr(1:5,:), 1);
ROIe_mean_2 = mean(ROIe_matr(6:10,:), 1);
Rmse_matr_analysis = [Rmse_mean_1; Rmse_mean_2];
Hfen_matr_analysis = [Hfen_mean_1; Hfen_mean_2];
Xsim_matr_analysis = [Xsim_mean_1; Xsim_mean_2];
ROIe_matr_analysis = [ROIe_mean_1; ROIe_mean_2];


    x_fields={'3 T', '7 T'};
    zlabels={'USPIO', 'Ferritin', 'CaCl_2', 'CaCO_3'};

    figure, hold on
    bar(x_fields, Rmse_matr_analysis, 0.8, "grouped");
    colororder("glow")
    hold on
    ylabel('RMSE (%)');
    yticks([0 25 50 75 100]);
    pbaspect([1 1 1])
    legend(zlabels, 'Location', 'bestoutside'); 
    hold off
    saveas(gcf,fullfile(analysis_dir,'RMSE_Ch5.png'));

    figure, hold on
    bar(x_fields, Hfen_matr_analysis, 0.8, "grouped");
    colororder("glow")
    hold on
    ylabel("HFEN (%)");
    yticks([0 25 50 75 100]);
    pbaspect([1 1 1])
    legend(zlabels, 'Location', 'bestoutside'); 
    hold off
    saveas(gcf, fullfile(analysis_dir, 'HFEN_Ch5.png'));

    figure, hold on
    bar(x_fields, Xsim_matr_analysis, 0.8, "grouped");
    colororder("glow")
    hold on
    ylabel('XSIM (0-1)');
    yticks([0 .25 .5 .75 1]);
    pbaspect([1 1 1])
    legend(zlabels, 'Location', 'bestoutside'); 
    hold off
    saveas(gcf,fullfile(analysis_dir,'XSIM_Ch5.png'));

    zlabels={'USPIO', 'Ferritin', 'CaCl_2', 'CaCO_3'};
    x_fields={'3 T', '7 T'};
    figure, hold on
    bar(x_fields, ROIe_matr_analysis, 0.8, "grouped");
    colororder("glow")
    hold on
    ylabel('ROI error (ppb)');
    yticks('auto');
    pbaspect([1 1 1])
    legend(zlabels, 'Location', 'bestoutside'); 
    hold off
    saveas(gcf,fullfile(analysis_dir,'ROI_error_Ch5.png'));    

%% Step (6) Compute map of Phase_SNR in radians

clc
clear

i = {'3T_9mth'}; %   

output_dir='C:\Users\rosly\Documents\QSM_PH\Analysis\SNR_phase';
data_dir='C:\Users\rosly\Documents\QSM_PH\Data\Quad-AfterCplx';
csf_dir='C:\Users\rosly\Documents\QSM_PH\Analysis\field_to_chi';



for dataset = i
    csf_nii=load_untouch_nii(fullfile(csf_dir, [dataset{1}, '_CSF_mask_Crop_Quad.nii.gz']));
    data_fn=fullfile(data_dir, [dataset{1}, '.mat']);
    load(data_fn, 'Magn', 'Phs');    

    if contains(dataset{1}, '7T')
        TE = 3.15:3.15:9*3.15;
        vsz= [.7 .7 .7];
        fov = [238 272 160] .* min(vsz);
    else
        TE = 1.87:1.87:12*1.87;
        vsz=[1 1 1];
        fov = [192 192 104] .* min(vsz);
        % load(data_fn, 'R2s');
    end
    delta_TE = TE(2)-TE(1);
    fov_pad = round(1.5.*[192 192 112]);

    Magn=pad_or_crop_target_size(Magn, vsz, fov_pad);
    Phs=pad_or_crop_target_size(Phs, vsz, fov_pad);
    Phs = -1 * Phs;
    Magn_E1=Magn(:,:,:,1);

    f = 0.3;
    g = 0.2;
    N1 = size(Magn_E1);
    Mask = BET(Magn_E1, N1, vsz, f, g); 
    for i=size(Magn_E1,3) :-1 :1
        Mask(:, :, i) = imfill(Mask(:, :, i), 26, 'holes');
    end    

    % Erode mask
    e_mm = 2;
    e_vox = round(e_mm / min(vsz));
    Mask = imerode(Mask, strel('sphere', e_vox));
    % export_nii(Mask, fullfile(output_dir, [dataset{1}, '_Mask']), vsz);    
    nTE = length(TE);
    chunk_size = 3;
    nChunks = ceil(nTE / chunk_size);

    % if contains(dataset{1}, '3T')
    %    parameters.output_dir = fullfile(output_dir, 'romeo_tmp');
    %    parameters.TE = TE;
    %    parameters.mag = Magn;
    %    parameters.mask = Mask;
    %    parameters.no_unwrapped_output=false;
    %    parameters.calculate_B0=false;
    %    parameters.phase_offset_correction='off';
    %    parameters.voxel_size=vsz;
    % 
    %    mkdir(parameters.output_dir);
    %    [unwrapped, ~] = ROMEO(Phs, parameters);
    % 
    %    try
    %       rmdir(parameters.output_dir, 's');
    %    catch ME
    %       warning('Failed to remove directory: %s. Error: %s', parameters.output_dir, ME.message);
    %    end     
    % 
    % end

    for c = 1%:nChunks
        idx_start = (c - 1) * chunk_size + 1;
        % idx_start = 1;
        idx_end = min(c * chunk_size, nTE);
        echo_range = idx_start:idx_end;

        Magn_chunk = Magn(:,:,:,echo_range);
        Phs_chunk = Phs(:,:,:,echo_range);
        TE_chunk = TE(echo_range);

        % epsilon = zeros(size(Magn_E1));
        % epsilon(Magn_E1 < 10) = 1;
        % epsilon(Magn_E1 == 0) = 0;
        epsilon = std(Magn_E1(Magn_E1<10), 'omitmissing') / sqrt(2);
     
        % if contains( dataset{1}, '7T')
            [iFreq, ~]   = Fit_ppm_complex(Magn_chunk.*exp(-1i*Phs_chunk));  
            [iFreq]      = unwrapping_gc(iFreq, Magn_E1, vsz, 2);
            iFreq        = iFreq / (2*pi*delta_TE); % Hz
        % else
        %     parameters.output_dir = fullfile(output_dir, 'romeo_tmp');
        %     parameters.TE = TE;
        %     parameters.mag = Magn_chunk;
        %     parameters.mask = Mask;
        %     parameters.no_unwrapped_output=true;
        %     parameters.calculate_B0=true;
        %     parameters.phase_offset_correction='off';
        %     parameters.voxel_size=vsz;
        % 
        %     mkdir(parameters.output_dir);
        %     [~, iFreq] = ROMEO(Phs_chunk, parameters);
        % 
        % 
        %     try
        %         rmdir(parameters.output_dir, 's');
        %     catch ME
        %         warning('Failed to remove directory: %s. Error: %s', parameters.output_dir, ME.message);
        %     end     

        % end            

        % Referencing
        % iFreq = iFreq - mean(iFreq(csf_nii.img>0));

        % Remove background fields
        radiusMax_vox = ceil(8 / min(vsz));
        radiusArray = radiusMax_vox:-1:1;
        % iFreq = pad_or_crop_target_size(iFreq, vsz, fov_pad);
        % Mask2 = pad_or_crop_target_size(Mask, vsz, fov_pad);
        % N2 = size(Mask2);
        
        [RDF, Mask2] = BKGRemovalVSHARP(iFreq, Mask, N1, 'radius', radiusArray);  
        RDF = RDF .* Mask2;

        % Referencing
        RDF = RDF - mean(RDF(csf_nii.img>0));

        % Compute phase SNR
        RDF = pad_or_crop_target_size(RDF, vsz, fov);
        Magn_chunk = pad_or_crop_target_size(Magn_chunk, vsz, fov);
        TE_4D = match_dims(TE_chunk, Magn_chunk);
        SNR_f = 2*pi*RDF ./ sqrt(sum(epsilon ./ (Magn_chunk .* TE_4D).^2, 4)); % rad
        % SNR_f_w = 2*pi*RDF_w ./ sqrt(sum(epsilon ./ Magn_chunk .* TE_4D).^2, 4); % rad
    
        outname = fullfile(output_dir, ...
            sprintf('%s_SNR_frequency_Echos_%d_to_%d', dataset{1}, idx_start, idx_end));        
        export_nii(SNR_f, outname, vsz);    
        % export_nii(SNR_f_w, [outname, '_weighted'], vsz);
    end
end

%%

roi_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis';
seg_nii = load_untouch_nii(fullfile(roi_dir, '7T_9mth_segmentation.nii.gz'));
seg_shifted = circshift(seg_nii.img, [-1 -1 0]);
export_nii(seg_shifted, fullfile(roi_dir, '7T_9mth_segmentation_shift'), [.7 .7 .7]);


%%  Step (7) Plot Phase_SNR, normalized to max(Phase_SNR)

clc
clear
close all
i = {'3T_9mth'}; %

snr_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis\SNR_phase';
roi_dir = 'C:\Users\rosly\Documents\QSM_PH\Analysis';
for dataset = i
    x_fields={'TE_{1to3}', 'TE_{4to6}', 'TE_{7to9}'};   
    if contains(dataset{1}, '7T')
        nTE = 9;
        x_array = 3:3:9;        
    else
        nTE = 12;
        x_fields{:,4}='TE_{10to12}';
        x_array = 3:3:12;        
    end
    chunk_size = 3;
    nChunks = ceil(nTE / chunk_size);
    nSamples=5;

    uspio=zeros(nSamples,nChunks);
    uspio_norm=zeros(nSamples,nChunks);
    ftn=zeros(nSamples,nChunks);
    ftn_norm=zeros(nSamples,nChunks);
    chl=zeros(nSamples,nChunks);
    chl_norm=zeros(nSamples,nChunks);
    crb=zeros(nSamples,nChunks);
    crb_norm=zeros(nSamples,nChunks);

    for c = 1:nChunks
        idx_start = (c - 1) * chunk_size + 1;
        % idx_start = 1;
        idx_end = min(c * chunk_size, nTE);    
        snr=load_untouch_nii(fullfile(snr_dir, [dataset{1}, ...
            '_SNR_frequency_Echos_', num2str(idx_start), '_to_', num2str(idx_end), '.nii.gz']));
        roi=load_untouch_nii(fullfile(roi_dir, [dataset{1}, ...
            '_segmentation.nii.gz']));
        snr = single(snr.img);
        roi = single(roi.img);
        for i=1:nSamples
            uspio(i,c) = abs(mean(snr(roi==i)));
            ftn(i,c) = abs(mean(snr(roi==i+5)));
            chl(i,c) = abs(mean(snr(roi==i+10)));
            crb(i,c) = abs(mean(snr(roi==i+15)));
        end
    end
   
    % Normalize SNR by maximum SNR
    for i = 1:nSamples
            uspio_norm(i,:) = uspio(i,:) ./ max(uspio(i,:), [], 2);
            ftn_norm(i,:) = ftn(i,:) ./ max(ftn(i,:), [], 2);
            chl_norm(i,:) = chl(i,:) ./ max(chl(i,:), [], 2);
            crb_norm(i,:) = crb(i,:) ./ max(crb(i,:), [], 2);
    end

    zlabels={'USPIO 180 \mu mol/L', 'USPIO 270 \mu mol/L', 'USPIO 360 \mu mol/L', 'USPIO 450 \mu mol/L', 'USPIO 540 \mu mol/L'};
    figure, hold on
    bar(x_fields, uspio_norm', 0.8, "grouped");
    colororder("meadow")
    hold on
    ylabel('Normalized SNR_\phi');
    yticks([0 .25 .5 .75 1]);
    pbaspect([1 1 1])
    legend(zlabels, 'Location', 'bestoutside'); 
    hold off
%gem, gem12, glow, glow12, dye, earth, meadow, reef, sail.
    saveas(gcf,fullfile(snr_dir,[dataset{1},'_usp_Phase_SNR.png']));

    zlabels={'Ferritin 3.8 mmol/L', 'Ferritin 5.4 mmol/L', 'Ferritin 7.0 mmol/L', 'Ferritin 8.6 mmol/L', 'Ferritin 10.2 mmol/L'};
    figure, hold on
    bar(x_fields, ftn_norm', 0.8, "grouped");
    colororder("dye")
    hold on
    ylabel('Normalized SNR_\phi');
    yticks([0 .25 .5 .75 1]);
    pbaspect([1 1 1])
    legend(zlabels, 'Location', 'bestoutside'); 
    hold off

    saveas(gcf,fullfile(snr_dir,[dataset{1},'_ftn_Phase_SNR.png']));

    zlabels={'CaCl_2 0.9 mol/L', 'CaCl_2 1.8 mol/L', 'CaCl_2 2.7 mol/L', 'CaCl_2 3.6 mol/L', 'CaCl_2 4.7 mol/L'};
    figure, hold on
    bar(x_fields, chl_norm', 0.8, "grouped");
    colororder("reef")
    hold on
    ylabel('Normalized SNR_\phi');
    yticks([0 .25 .5 .75 1]);
    pbaspect([1 1 1])
    legend(zlabels, 'Location', 'bestoutside'); 
    hold off

    saveas(gcf,fullfile(snr_dir,[dataset{1},'_chl_Phase_SNR.png']));    

    zlabels={'CaCO_3 1.0 mol/L', 'CaCO_3 2.0 mol/L', 'CaCO_3 3.0 mol/L', 'CaCO_3 4.0 mol/L', 'CaCO_3 5.0 mol/L'};
    figure, hold on
    bar(x_fields, crb_norm', 0.8, "grouped");
    colororder("sail")
    hold on
    ylabel('Normalized SNR_\phi');
    yticks([0 .25 .5 .75 1]);
    pbaspect([1 1 1])
    legend(zlabels, 'Location', 'bestoutside'); 
    hold off

    saveas(gcf,fullfile(snr_dir,[dataset{1},'_crb_Phase_SNR.png']));   
end
