function Save_InputData_ForCOSMOS(FS_str, num_orient, output_dir)

% R_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\Matrices';
R_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\FLIRT';
% flirt_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\PDF_Opt';
flirt_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\SNRwAVG_PDF';
% flirt_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\PDF';
% neutral_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\Neutral';
% ants_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\Delta_ANTS';
% reference_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\FermiFilt';
% degibbs_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\deGibbs';

if matches(FS_str, '3T')
    if num_orient == 1
        Registered = {};
    elseif num_orient == 2
        Registered = {'Rot2'};
    elseif num_orient == 3
        % Registered = {'Rot1', 'Rot2'};
        Registered = {'Rot1', 'Rot3'};
    elseif num_orient == 4
        % Registered = {'Rot1', 'Rot2', 'Rot3'};
        Registered = {'Rot1', 'Rot3', 'Rot5'};
    elseif num_orient == 5
        % Registered = {'Rot1', 'Rot2', 'Rot3', 'Rot5'};
        Registered = {'Rot1', 'Rot3', 'Rot5', 'Rot6'};
    elseif num_orient == 6
        Registered = {'Rot1', 'Rot2', 'Rot3', 'Rot5', 'Rot6'};
    end
    
    voxel_size = [1 1 1];
    
    Vol_1 = 'Neutral';
    
    
    %% TODO: Remove 3T_Rot6 from COSMOS Acquisitions due to Low SNR
    
    % tol = 1e-6;
    
    % tol = 4.536e-01;
    
elseif matches(FS_str, '7T')
    if num_orient == 1
        Registered = {};
    elseif num_orient == 2
        Registered = {'Rot4'};
    elseif num_orient == 3
        Registered = {'Rot5', 'Rot3'};
    elseif num_orient == 4
        Registered = {'Rot5', 'Rot3', 'Rot1'};
    elseif num_orient == 5
        Registered = {'Rot5', 'Rot3', 'Rot1', 'Rot4'};
    elseif num_orient == 6
        Registered = {'Rot5', 'Rot3', 'Rot1', 'Rot4', 'Rot2'};
    end
    
    voxel_size = [.75 .75 .75];
    
    Vol_1 = 'Rot6';
    
end

savefile = fullfile( output_dir, [FS_str, '_', 'Num_Orient_', num2str(num_orient), '.txt'] );
fileID = fopen(savefile, 'w');
for i = 1:length(Registered)
    fprintf(fileID, '%s\n', Registered{i});
end
fclose(fileID);



%% Masks don't require concatenating

%CSF_fn = fullfile(neutral_dir, [FS_str, '_', Ref, '_CSF_Mask_FLIRT.nii.gz'] );
%CSF_nii = load_untouch_nii(CSF_fn);
%CSF_Mask = CSF_nii.img;

%BET_fn = fullfile(neutral_dir, [FS_str, '_', Ref, '_BET_Mask_FLIRT.nii.gz'] );
%BET_nii = load_untouch_nii(BET_fn);
%BET_Mask = BET_nii.img;

% Morphological erosion: remove edge voxels
%erode_radius_voxel=round(5 / max(voxel_size)); % 5 mm (converted to voxel units)
%BET_Erode = imerode(BET_Mask, strel('sphere', erode_radius_voxel));

%Q_fn = fullfile(neutral_dir, [FS_str, '_', Ref, '_NLFit_Mask_FLIRT.nii.gz'] );
%Q_nii = load_untouch_nii(Q_fn);
%Q = Q_nii.img;

%M             = Q .* BET_Erode;

%if matches(FS_str, '3T')
% Morphological opening: remove disconnected voxels
%    open_radius_voxel   = round(5 / max(voxel_size)); % 5 mm (converted to voxel units)
%    M = imopen(M, strel('sphere', double(open_radius_voxel)));
%end
mask_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\Brain_ROI_Mask';
M_type = 'BET_Mask_Erode'; % BET_Mask_Erode Mask_Use
M_fn = fullfile(mask_dir, [FS_str, '_Neutral_', M_type '_FLIRT.nii.gz'] );
M_nii = load_untouch_nii(M_fn);
M = M_nii.img;

CSF_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Registered\CSF_Mask';
CSF_fn = fullfile(CSF_dir, [FS_str, '_Neutral_CSF_Mask.nii.gz']);
CSF_nii = load_untouch_nii(CSF_fn);
CSF_Mask = CSF_nii.img;

FOV = [400 400 400].*voxel_size;
[ M ] = pad_or_crop_target_size(M, voxel_size, FOV);
[ CSF_Mask ] = pad_or_crop_target_size(CSF_Mask, voxel_size, FOV);




%% DeltaB, weights, iMag & rotation matrix require concatenating

%Magn_fn = fullfile(neutral_dir, [FS_str, '_', Ref, '_iMag_FLIRT.nii.gz']);
%Magn_nii = load_untouch_nii(Magn_fn);
%Magn = Magn_nii.img;
    
if matches(FS_str, '3T')
    Ref = '';
    R_tot = eye(3);
elseif matches(FS_str, '7T')
    Ref = 'Neutral_to_';
    R_ascii = load(fullfile(R_dir, [FS_str, '_', Ref, Vol_1, '_FLIRT.mat']), '-ascii');
    R_tot = R_ascii(1:3,1:3);
end

B_fn = fullfile(flirt_dir, [FS_str, '_', Ref, Vol_1, '_Delta_FLIRT.nii.gz'] );
B_nii = load_untouch_nii(B_fn);
B = B_nii.img;

W_fn = fullfile(flirt_dir, [FS_str, '_', Ref, Vol_1, '_weights_FLIRT.nii.gz'] );
W_nii = load_untouch_nii(W_fn);
W = W_nii.img;

Ref = 'Neutral_to_';

for i = Registered
    B_fn = fullfile(flirt_dir, [FS_str, '_', Ref, i{1}, '_Delta_FLIRT.nii.gz']);
    B_nii = load_untouch_nii(B_fn);
    B = cat(4, B, B_nii.img);
    
    W_fn = fullfile(flirt_dir, [FS_str, '_', Ref, i{1}, '_weights_FLIRT.nii.gz'] );
    W_nii = load_untouch_nii(W_fn);
    W = cat(4, W, W_nii.img);
    
    %Magn_fn = fullfile(flirt_dir, [FS_str, '_', Ref, '_to_', i{1}, '_iMag_FLIRT.nii.gz']);
    %Magn_nii = load_untouch_nii(Magn_fn);
    %Magn = cat(4, Magn, Magn_nii.img);
    
    R_fn = fullfile(R_dir, [FS_str, '_', Ref, i{1}, '_FLIRT.mat']);
    % Load the entire transformation matrix
    R_ascii  = load(R_fn, '-ascii');
    % The rotation matrix is the first 3x3 elements of the matrix
    R_tot    = single(cat(3, R_tot, R_ascii(1:3,1:3)));
end

% %% Resample from [1 1 1] to [.75 .75 .75]
% if matches(FS_str, '3T')
%     old_voxel_size = voxel_size;
%     new_voxel_size = [.75 .75 .75];
%     voxel_size = new_voxel_size;
%     interpMethod_binary = 'nearest';
%     M = resample_volumes(M, old_voxel_size, new_voxel_size, interpMethod_binary);
%     interpMethod_scalar = 'spline';
%     B = resample_volumes(B, old_voxel_size, new_voxel_size, interpMethod_scalar);
%     W = resample_volumes(W, old_voxel_size, new_voxel_size, interpMethod_scalar);
% end



%% Zero-padding
% FOV = [170 170 170];
% FOV = [210, 240, 192]; % in millimeters
% FOV = [256 256 256]; % in millimeters


% Apply quality mask to B before COSMOS reconstruction -> reduces Gibbs
% Ringing
[ B ] = pad_or_crop_target_size(B, voxel_size, FOV) .* M;
[ W ] = pad_or_crop_target_size(W, voxel_size, FOV) .* M;


% [ Magn ] = single(pad_or_crop_target_size(Magn, voxel_size, FOV));
% [ CSF_Mask ] = single(pad_or_crop_target_size(CSF_Mask, voxel_size, FOV));
% [ BET_Mask ] = single(pad_or_crop_target_size(BET_Mask, voxel_size, FOV));
%% Save to MAT file
savefile = fullfile(output_dir, [FS_str, '_COSMOS_', num2str(num_orient), '_inputVars.mat']);
% if matches(FS_str, '3T')
%     save(savefile, "CSF_Mask", "M", '-append');
%     return
% end
    save(savefile, "M", "W", "B", "R_tot", "voxel_size" , "CSF_Mask");
end