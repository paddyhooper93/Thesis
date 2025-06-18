%% Wrapper_Morozov_Cyl

dir='C:\Users\rosly\Documents\QSM_PH\Analysis\Morozov';
output_dir='C:\Users\rosly\Documents\QSM_PH\Analysis\Morozov_2';
idx={'3T_9mth'}; % , '7T_9mth'
for dataset=idx
    matfile=fullfile(dir, [dataset{1}, '_workspace.mat']);
    load(matfile, "RDF", "hdr", "iFreq", "weights");
    if contains(dataset{1}, '3T')
        hdr.fov=[192 192 104];
        x=5;         
    else
        hdr.fov=[238 272 160].*hdr.voxel_size;
        x=[2, 2.5:.5:5];
    end
    lam_range=10.^(x);
    hdr.noDipoleInversion=false;
    hdr.isCSF=false;
    hdr.useQualityMask=true;
    hdr.param_opt=true;
    cost_data=[];
    for lam=lam_range
        hdr.lambda=lam;
        hdr.QSM_Prefix=[num2str(lam), '_Lambda_QSM'];
        [c_d_m, ~] = DipoleInversion(weights, RDF, hdr);
        cost_data=[cost_data; c_d_m];
    end
    % matfile=fullfile(output_dir, [dataset{1}(1:2), '_Vars.mat']);
    % save(matfile, "lam_range", "cost_data");
end
%%
hdr.path_to_data='C:\Users\rosly\Documents\QSM_PH\Data\Quad-AfterSDC-Cplx';
hdr.output_dir='C:\Users\rosly\Documents\QSM_PH\Analysis\Morozov';
idx={'3T_24mth', '7T_24mth'};
for dataset=idx
    matfile=fullfile(dir, [dataset{1}, '.mat']);
    load(matfile, 'Phs', 'Magn', 'Mask_Use', 'R2s');
    QSM_Main(dataset{1}, hdr);
end
