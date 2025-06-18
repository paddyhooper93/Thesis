%% Wrapper_fansi_metrics.m

dir_medi = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\MEDI';
dir_medi0 = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\MEDI0';
dir_cosmos = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\COSMOS_SNRwAVG_PDF\deGibbs';

for dataset = {'3T_Neutral', '3T_Rot1', '3T_Rot2', '3T_Rot3', '3T_Rot5', '3T_Rot6'}
    
    if contains(dataset{1}, 'Neutral')
        fn_medi = [dataset{1}, '_QSM_FLIRT.nii.gz'];
        nii_medi=load_untouch_nii(fullfile(dir_medi, fn_medi));
        medi_3T=single(nii_medi.img);
    else
        fn_medi = [dataset{1}(1:2), '_Neutral_to_', dataset{1}(4:7), '_QSM_FLIRT.nii.gz'];
        nii_medi=load_untouch_nii(fullfile(dir_medi, fn_medi));
        medi_3T=cat(4, medi_3T, single(nii_medi.img));
    end

    if contains(dataset{1}, 'Neutral')
        fn_medi = [dataset{1}, '_QSM0_FLIRT.nii.gz'];
        nii_medi=load_untouch_nii(fullfile(dir_medi0, fn_medi));
        medi0_3T=single(nii_medi.img);
    else
        fn_medi = [dataset{1}(1:2), '_Neutral_to_', dataset{1}(4:7), '_QSM0_FLIRT.nii.gz'];
        nii_medi=load_untouch_nii(fullfile(dir_medi0, fn_medi));
        medi0_3T=cat(4, medi0_3T, single(nii_medi.img));
    end
    
end



for dataset = {'7T_Rot6', '7T_Rot1', '7T_Rot2', '7T_Rot3', '7T_Rot4', '7T_Rot5'}
    
    fn_medi = [dataset{1}(1:2), '_Neutral_to_', dataset{1}(4:7), '_QSM_FLIRT.nii.gz'];
    nii_medi=load_untouch_nii(fullfile(dir_medi, fn_medi));
    if contains(dataset{1}, 'Rot6')
        medi_7T=single(nii_medi.img);
    else
        medi_7T=cat(4, medi_7T, single(nii_medi.img));
    end

    fn_medi = [dataset{1}(1:2), '_Neutral_to_', dataset{1}(4:7), '_QSM0_FLIRT.nii.gz'];
    nii_medi=load_untouch_nii(fullfile(dir_medi0, fn_medi));
    if contains(dataset{1}, 'Rot6')
        medi0_7T=single(nii_medi.img);
    else
        medi0_7T=cat(4, medi0_7T, single(nii_medi.img));
    end
    
end

nii_cosmos_3T = load_untouch_nii(fullfile(dir_cosmos, '3T_chi_CF_6_Orient.nii.gz'));
qsm_cosmos_3T = single(nii_cosmos_3T.img);
nii_cosmos_7T = load_untouch_nii(fullfile(dir_cosmos, '7T_chi_CF_5_Orient.nii.gz'));
qsm_cosmos_7T = single(nii_cosmos_7T.img);
% nii_msk_3T = load_untouch_nii(fullfile(dir_msk, '3T_Neutral_Bet_Mask_Erode_FLIRT.nii.gz'));
% msk_3T = single(nii_msk_3T.img);
% nii_msk_7T = load_untouch_nii(fullfile(dir_msk, '7T_Neutral_Bet_Mask_Erode_FLIRT.nii.gz'));
% msk_7T = single(nii_msk_7T.img);
% dir_msk = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\Brain_ROI_Mask';
%%
dir_msk = 'C:\Users\rosly\Documents\Valerie_PH\ROIs';
% msk_fn = 'CSF_Mask'; % 'BET_Mask_Erode_FLIRT'
nii_msk_3T = load_untouch_nii(fullfile(dir_msk, '3T_ROIs_Use.nii.gz' ));
msk_3T = single(nii_msk_3T.img > 0);
nii_msk_7T = load_untouch_nii(fullfile(dir_msk, '7T_ROIs_Erode1vox.nii.gz' ));
msk_7T = single(nii_msk_7T.img > 0);    
%%
orientations = 1:6;
for i = orientations
    [ metrics_3T.(sprintf('Orient_%d', i)) ] = compute_metrics( medi_3T(:,:,:,i), qsm_cosmos_3T, msk_3T ); 
    [ metrics_7T.(sprintf('Orient_%d', i)) ] = compute_metrics( medi_7T(:,:,:,i), qsm_cosmos_7T, msk_7T ); 
    [ metrics0_3T.(sprintf('Orient_%d', i)) ] = compute_metrics( medi0_3T(:,:,:,i), qsm_cosmos_3T, msk_3T);
    [ metrics0_7T.(sprintf('Orient_%d', i)) ] = compute_metrics( medi0_7T(:,:,:,i), qsm_cosmos_7T, msk_7T );     
end