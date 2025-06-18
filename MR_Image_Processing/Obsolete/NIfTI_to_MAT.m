dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\NC\';
if 7~=exist(dir, 'dir')
    eval(strcat('mkdir', 32, dir));
end

eval(strcat('cd', 32, dir));


% QA_Required: '3T_Rot1', '7T_Rot2', '7T_Rot3' '7T_Rot5',

i = {'7T_Rot6'};

% i = {'7T_Neutral', '7T_Rot1', '7T_Rot4', '3T_Neutral', '3T_Rot2', ...
%  '3T_Rot3', '3T_Rot4', '3T_Rot5', '3T_Rot6'};
% i = {'3T_Rot1', '7T_Rot2', '7T_Rot3' '7T_Rot5'};

for dataset = i

    Magn_fn = strcat(dataset{1}, '_Magn.nii.gz');
    Magn_nii = load_untouch_nii(Magn_fn);
    Magn = double(Magn_nii.img);

    Mask_fn = strcat(dataset{1}, '_Mask.nii.gz');
    Mask_nii = load_nii(Mask_fn);
    Mask_Use = double(Mask_nii.img);

    Magn = Magn .* Mask_Use;

    n_TE                = 7;
    TE                  = (3:3:n_TE*3)./1000;
    
    savefile = strcat(dataset{1}, '_forNLLS.mat');
    save(savefile, "Magn", "Mask_Use", "TE");

    Phs_fn = strcat(dataset{1}, '_Phs.nii.gz');
    Phs_nii = load_untouch_nii(Phs_fn);
    Phs = double(Phs_nii.img);

    Phs = Phs .* Mask_Use;

    savefile = strcat(dataset{1}, '_NC.mat');
    save(savefile, "Magn", "Phs", "Mask_Use");    

end

%% QA of NC datasets

dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\NC\';
if 7~=exist(dir, 'dir')
    eval(strcat('mkdir', 32, dir));
end
    eval(strcat('cd', 32, dir));


i = {'7T_Rot6'};

for dataset = i

    Magn_fn = strcat(dataset{1}, '_Magn.nii.gz');
    Magn_nii = load_untouch_nii(Magn_fn);
    Magn = double(Magn_nii.img);

    Mask_fn = strcat(dataset{1}, '_Mask.nii.gz');
    Mask_nii = load_untouch_nii(Mask_fn);
    Mask_Use = double(Mask_nii.img);

    Phs_fn = strcat(dataset{1}, '_Phs.nii.gz');
    Phs_nii = load_untouch_nii(Phs_fn);
    Phs = double(Phs_nii.img);

    savefile = strcat(dataset{1}, '_NC.mat');
    save(savefile, "Magn", "Phs", "Mask_Use");

end