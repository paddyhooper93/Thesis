%% Wrapper_fansi_metrics_PcRange.m

dir_medi = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\MEDI_pc-range';
dir_cosmos = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\COSMOS_SNRwAVG_PDF\deGibbs';

for dataset = {'3T_Rot5'}
    
        fn_medi = [dataset{1}(1:2), '_Neutral_to_', dataset{1}(4:7), '_QSM_Pc0_3_FLIRT.nii.gz'];
        nii_medi=load_untouch_nii(fullfile(dir_medi, fn_medi));
        pc_03_3T=single(nii_medi.img);

        fn_medi = [dataset{1}(1:2), '_Neutral_to_', dataset{1}(4:7), '_QSM_Pc0_9_FLIRT.nii.gz'];
        nii_medi=load_untouch_nii(fullfile(dir_medi, fn_medi));
        pc_09_3T=single(nii_medi.img);
    
end



for dataset = {'7T_Rot5'}
    
    fn_medi = [dataset{1}(1:2), '_Neutral_to_', dataset{1}(4:7), '_QSM_Pc0_3_FLIRT.nii.gz'];
    nii_medi=load_untouch_nii(fullfile(dir_medi, fn_medi));
    pc_03_7T=single(nii_medi.img);

    fn_medi = [dataset{1}(1:2), '_Neutral_to_', dataset{1}(4:7), '_QSM_Pc0_9_FLIRT.nii.gz'];
    nii_medi=load_untouch_nii(fullfile(dir_medi, fn_medi));
    pc_09_7T=single(nii_medi.img);
    
end

nii_cosmos_3T = load_untouch_nii(fullfile(dir_cosmos, '3T_chi_CF_6_Orient.nii.gz'));
qsm_cosmos_3T = single(nii_cosmos_3T.img);
nii_cosmos_7T = load_untouch_nii(fullfile(dir_cosmos, '7T_chi_CF_5_Orient.nii.gz'));
qsm_cosmos_7T = single(nii_cosmos_7T.img);

%%
dir_msk = 'C:\Users\rosly\Documents\Valerie_PH\ROIs';
nii_msk_3T = load_untouch_nii(fullfile(dir_msk, '3T_ROIs_Use.nii.gz' ));
msk_3T = single(nii_msk_3T.img > 0);
nii_msk_7T = load_untouch_nii(fullfile(dir_msk, '7T_ROIs_Erode1vox.nii.gz' ));
msk_7T = single(nii_msk_7T.img > 0);    
%%
orientations = 1;
for i = orientations
    [ metrics_03_3T.('nomask') ] = compute_metrics( pc_03_3T(:,:,:,i), qsm_cosmos_3T ); 
    [ metrics_03_7T.('nomask') ] = compute_metrics( pc_03_7T(:,:,:,i), qsm_cosmos_7T ); 
    [ metrics_09_3T.('nomask') ] = compute_metrics( pc_09_3T(:,:,:,i), qsm_cosmos_3T);
    [ metrics_09_7T.('nomask') ] = compute_metrics( pc_09_7T(:,:,:,i), qsm_cosmos_7T );     
    [ metrics_03_3T.('mask') ] = compute_metrics( pc_03_3T(:,:,:,i), qsm_cosmos_3T, msk_3T ); 
    [ metrics_03_7T.('mask') ] = compute_metrics( pc_03_7T(:,:,:,i), qsm_cosmos_7T, msk_7T ); 
    [ metrics_09_3T.('mask') ] = compute_metrics( pc_09_3T(:,:,:,i), qsm_cosmos_3T, msk_3T);
    [ metrics_09_7T.('mask') ] = compute_metrics( pc_09_7T(:,:,:,i), qsm_cosmos_7T, msk_7T );   
end