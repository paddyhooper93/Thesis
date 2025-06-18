%% Compute map of Phase_SNR in radians

clc
clear

i = {'3T_Neutral',  '7T_Neutral'}; %

output_dir='C:\Users\rosly\Documents\Valerie_PH\Analysis\SNR_phase';
data_dir='C:\Users\rosly\Documents\Valerie_PH\Data\Padded\SDC';
csf_dir='C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\CSF_Mask';

for dataset = i
    data_fn=fullfile(data_dir, [dataset{1}, '_forQSM.mat']);
    load(data_fn, 'Magn', 'Phs', 'Mask_Use');
    if contains(dataset{1}, '7T')
        vsz= [.75 .75 .75];
        Phs=-1*Phs;
    else
        vsz=[1 1 1];
    end
    TE=(3:3:21)./1000;
    delta_TE = TE(2)-TE(1);
    fov = [210 240 192];
    fov_pad = [400 400 400].*min(vsz);
    
    csf_nii=load_untouch_nii(fullfile(csf_dir, [dataset{1}, '_CSF_Mask.nii.gz']));
    csf_mask=pad_or_crop_target_size(csf_nii.img, vsz, fov_pad);

    
    Magn=pad_or_crop_target_size(Magn, vsz, fov_pad);
    Phs=pad_or_crop_target_size(Phs, vsz, fov_pad);
    Mask=pad_or_crop_target_size(Mask_Use, vsz, fov_pad);
    Magn_E1=Magn(:,:,:,1);

    % Erode mask
    e_mm = 2;
    e_vox = round(e_mm / min(vsz));
    Mask = imerode(Mask, strel('sphere', e_vox));    
    
    nChunks = 3;
    
    for c = 2:nChunks
        idx_start = 1;
        if c == 1
            % idx_start = 1;
            idx_end = 3;
        elseif c == 2
            % idx_start = 3;
            idx_end = 5;
        else
            % idx_start = 5;
            idx_end = 7;
        end
        echo_range = idx_start:idx_end;
        
        Magn_chunk = Magn(:,:,:,echo_range);
        Phs_chunk = Phs(:,:,:,echo_range);
        TE_chunk = TE(echo_range);
        TE_4D = match_dims(TE_chunk, Magn_chunk);
        
        epsilon = zeros(size(Magn_E1));
        epsilon(Magn_E1 < 10) = 1;
        epsilon(Magn_E1 == 0) = 0;
        epsilon = std(Magn_E1(epsilon>0), 'omitmissing') / sqrt(2);
        
        [iFreq, N_std]   = Fit_ppm_complex(Magn_chunk.*exp(-1i*Phs_chunk));
        % [iFreq]      = unwrapping_gc(iFreq, Magn_E1, vsz, 2);
        [iFreq] = UnwrapSingleTE_ROMEO(iFreq, Magn_E1, Mask, vsz, output_dir);
        iFreq        = iFreq / (2*pi*delta_TE); % Hz
        
        % Referencing
        iFreq = iFreq - mean(iFreq(csf_mask>0));
        export_nii(iFreq, fullfile(output_dir, [dataset{1}, '_iFreq']), vsz);
        
        % Remove background fields
        iFreq(isnan(iFreq)) = 0;
        iFreq(isinf(iFreq)) = 0;
        B0_dir = [0 0 1];
        n_CG = 30;
        tol = 0.1;
        space = 'imagespace';
        n_pad = 40;
        % iFreq = pad_or_crop_target_size(iFreq, vsz, fov_pad);
        % Mask2 = pad_or_crop_target_size(Mask, vsz, fov_pad);
        % N_std = pad_or_crop_target_size(N_std, vsz, fov_pad);
        N = size(Mask);
        RDF = PDF(iFreq, N_std, Mask, N, vsz, B0_dir, tol, ...
            n_CG, space, n_pad);
        
        % Referencing
        RDF = RDF - mean(RDF(csf_mask>0));
        export_nii(RDF, fullfile(output_dir, [dataset{1}, '_RDF']), vsz);
        
        % Compute phase SNR
        SNR_f = 2*pi*RDF ./ (sqrt(sum(1 ./ (Magn_chunk .* TE_4D).^2, 4)) * epsilon); % rad

        % Crop to original FOV
        SNR_f = pad_or_crop_target_size(SNR_f, vsz, fov);       
        
        outname = fullfile(output_dir, ...
            sprintf('%s_SNR_frequency_Echos_%d_to_%d', dataset{1}, idx_start, idx_end));
        export_nii(SNR_f, outname, vsz);
        % export_nii(SNR_f_w, [outname, '_weighted'], vsz);
    end
end


%% Plot Phase_SNR, normalized to max(Phase_SNR)

clc
clear
close all
i = {'3T_Neutral', '7T_Neutral'}; %

snr_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\SNR_Phase';
roi_dir = 'C:\Users\rosly\Documents\Valerie_PH\ROIs';
x_fields={'TE_{1to3}', 'TE_{3to5}', 'TE_{5to7}'};   
nChunks = 3;
nSamples=6;
for dataset = i

    phs_SNR=zeros(nSamples,nChunks);
    phs_SNR_norm=zeros(nSamples,nChunks);

    for c = 1:nChunks
        idx_start = 1;
        if c == 1
            % idx_start = 1;
            idx_end = 3;
        elseif c == 2
            % idx_start = 3;
            idx_end = 5;
        else
            % idx_start = 5;
            idx_end = 7;
        end
        fs_str=dataset{1}(1:2);
        snr=load_untouch_nii(fullfile(snr_dir, [dataset{1}, ...
            '_SNR_frequency_Echos_', num2str(idx_start), '_to_', num2str(idx_end), '.nii.gz']));
        roi=load_untouch_nii(fullfile(roi_dir, [fs_str, ...
            '_ROIs_Use.nii.gz']));
        snr = single(snr.img);
        roi = single(roi.img);
        for i=1:nSamples
            phs_SNR(i,c) = abs(mean(snr(roi==i)));
        end
    end
   
    % Normalize SNR by maximum SNR
    for i = 1:nSamples
            phs_SNR_norm(i,:) = phs_SNR(i,:) ./ max(phs_SNR(i,:), [], 2);
    end

    zlabels={'Straw Parallel', 'Straw Transverse', 'Ellipsoid Ca High', 'Ellipsoid Ca Low', ...
        'Ellipsoid Fe Low', 'Ellipsoid Fe High'};
    figure, hold on
    bar(x_fields, phs_SNR_norm', 0.8, "grouped");
    colororder("earth")
    hold on
    ylabel('Normalized SNR_\phi');
    yticks([0 .25 .5 .75 1]);
    pbaspect([1 1 1])
    legend(zlabels, 'Location', 'best'); 
    hold off

    saveas(gcf,fullfile(snr_dir,[dataset{1},'_Phase_SNR.png']));
end