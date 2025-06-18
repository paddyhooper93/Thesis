% Wrapper_ForQuadRegistration.m

clc
clear
close all

%%
path_to_data = 'C:\Users\rosly\Documents\QSM_PH\Data\NC\';
eval(strcat('cd', 32, path_to_data));
output_dir = 'C:\Users\rosly\Documents\QSM_PH\Data\NC\tmp\';
if 7~=exist(output_dir, 'dir')
    eval(strcat('mkdir', 32, output_dir));
end

i =      {'3T_24mth', '3T_24mth_Rep'};

for dataset = i
    load(dataset{1}, 'Magn', 'Phs');
    Magn(isnan(Magn(:))) = 0;
    Magn(isinf(Magn(:))) = 0;
    Phs(isnan(Phs(:))) = 0;
    Phs(isinf(Phs(:))) = 0;    
    Phs = DICOM2Radians(Phs);
    CplxNC = Magn.*exp(1i*Phs); 
    RealNC = double(real(CplxNC));
    ImagNC = double(imag(CplxNC));
    export_nii(RealNC, fullfile(output_dir, strcat(dataset{1}, '_Real.nii.gz')));
    export_nii(ImagNC, fullfile(output_dir, strcat(dataset{1}, '_Imag.nii.gz')));
end
% Done = '7T_BL', '7T_BL_Rep', 'TE1to3_9mth', '7T_24mth',  ...   
          % '7T_24mth_Rep', 'TE1to3_24mth', 'TE1to3_24mth_Rep'
%% unix('bash Run_antsApplyTransforms_TimeSeries.sh')

path_to_data = 'C:\Users\rosly\Documents\QSM_PH\Data\Quad-AfterCplx\tmp\';
eval(strcat('cd', 32, path_to_data));
output_dir = 'C:\Users\rosly\Documents\QSM_PH\Data\Quad-AfterCplx\';

i =      {'3T_24mth', '3T_24mth_Rep'};

for dataset = i
    Real_nii = load_untouch_nii(fullfile(path_to_data, strcat(dataset{1},'_Real_Quad.nii.gz')));
    RealNC = Real_nii.img;
    Imag_nii = load_untouch_nii(fullfile(path_to_data, strcat(dataset{1},'_Imag_Quad.nii.gz')));
    ImagNC = Imag_nii.img;    
    Magn = double(sqrt(RealNC.^2 + ImagNC.^2));
    Phs = double(atan2(RealNC, ImagNC));
    export_nii(Magn, fullfile(output_dir, strcat(dataset{1}, '_Magn.nii.gz')));
    export_nii(Phs, fullfile(output_dir, strcat(dataset{1}, '_Phs.nii.gz')));
    mat_fn = fullfile(output_dir, strcat(dataset{1}, '.mat'));
    save(mat_fn, "Phs", "Magn", '-append')
end

%DONE= '7T_BL', '7T_BL_Rep', '7T_9mth', 'TE1to3_9mth', '7T_24mth',  ...   

%%

input_dir = 'C:\Users\rosly\Documents\QSM_PH\Data\R2s\';
output_dir = 'C:\Users\rosly\Documents\QSM_PH\Data\Input\';
i = {'3T_BL', '3T_BL_Rep', '3T_24mth', '3T_24mth_Rep'}; 

for dataset = i
    R2s_fn = fullfile(input_dir, strcat(dataset{1},'_R2s_Quad.nii.gz'));
    R2s_nii = load_untouch_nii(R2s_fn);
    R2s = R2s_nii.img;
    R2s(isnan(R2s))=0;
    R2s(isinf(R2s))=0;
    export_nii(R2s, R2s_fn)
    mat_fn = fullfile(output_dir, strcat(dataset{1},'.mat'));
    save(mat_fn, "R2s", '-append')
end



%%

dir = 'C:\Users\rosly\Documents\QSM_PH\Data\NIfTIs_Quad\';

output_dir = 'C:\Users\rosly\Documents\QSM_PH\Data\Input\';

i =      {'7T_9mth', '7T_BL', '7T_BL_Rep', 'TE1to3_9mth', '7T_24mth',  ...   
          '7T_24mth_Rep', 'TE1to3_24mth', 'TE1to3_24mth_Rep', ...
          '3T_BL', '3T_BL_Rep', '3T_9mth', '3T_24mth', '3T_24mth_Rep', ... 
          'TE1to7_9mth', 'TE1to7_24mth', 'TE1to7_24mth_Rep'};

for dataset = i
    str = dataset{1};
    R2s_fn = fullfile(dir, strcat(str,'_Phs_Quad.nii.gz'));
    R2s_nii = load_untouch_nii(R2s_fn);
    R2s = R2s_nii.img;
    mat_fn = fullfile(output_dir, strcat(str,'.mat'));
    save(mat_fn, "R2s", '-append')
end


%%
path_to_data = 'C:\Users\rosly\Documents\QSM_PH\Data\NIfTIs_Quad\';
eval(strcat('cd', 32, path_to_data));

output_dir = 'C:\Users\rosly\Documents\QSM_PH\Data\Input\';

i =    {'3T_24mth', '3T_24mth_Rep'};

for dataset = i
    R2s_fn = append(dataset{1}, '_Phs_Quad.nii.gz');
    R2s_nii = load_untouch_nii(R2s_fn);
    R2s = R2s_nii.img;
    Magn_fn = append(dataset{1}, '_Magn_Quad.nii.gz');
    Magn_nii = load_untouch_nii(Magn_fn);
    Magn = Magn_nii.img;
    str = fullfile(output_dir, append(dataset{1}, '.mat'));
    save(str,'R2s','-append');
end


%%
% '7T_BL', '7T_BL_Rep', '7T_9mth', 'TE1to3_9mth',


for dataset = i
    R2s_fn = strcat(dataset{1}, '_Phs_Quad.nii.gz');
    R2s_nii = load_untouch_nii(R2s_fn);
    R2s = R2s_nii.img;
    Magn_fn = strcat(dataset{1}, '_Magn_Quad.nii.gz');
    Magn_nii = load_untouch_nii(Magn_fn);
    Magn = Magn_nii.img;
    str = fullfile(output_dir, append(dataset{1}, '.mat'));
    save(str,"R2s")
end


% for dataset = i
%     Phs_nii = load_untouch_nii(strcat(dataset{1},'_Phs_Quad.nii.gz'));
%     Phs = Phs_nii.img;
%     Magn_nii = load_untouch_nii(strcat(dataset{1},'_Magn_Quad.nii.gz'));
%     Magn = Magn_nii.img;
%     save(fullfile(hdr.output_dir, dataset{1}), "Magn", "Phs", '-mat');
% end