function SingleStep(iFreq, hdr)

Mask_Use = hdr.Mask_Use;

%% Step 1: Erode mask by 4 voxels
erode_before_radius = 4; % voxels
SE = strel('sphere', erode_before_radius);
QSM_Mask = imerode(Mask_Use, SE);

%% Step 2: Re-scale total field map to ppm
% Berkin Bilgic's function expects total field in ppm
[~, iFreq_ppm] = CalculateChiMapfromLF(iFreq, hdr.FS);

%% Step 3: Perform SS TGV
QSM = Wrapper_SS_TGV(iFreq_ppm, QSM_Mask, hdr);

%% Step 4: Correct for susceptibility of bulk medium
if hdr.CorrectNaCl
    QSM = QSM + (-0.1106 .* QSM_Mask); % Bulk medium correction
    disp('Correcting for susceptibility of bulk medium.')
end

mosaic( QSM, 12, 12, 13, 'SS TGV QSM-map', [-0.5 0.5] )

% Export QSM as a NIfTI file
export_nii(QSM, strcat(hdr.output_dir, hdr.dataset, '_SS-TGV_QSM'));