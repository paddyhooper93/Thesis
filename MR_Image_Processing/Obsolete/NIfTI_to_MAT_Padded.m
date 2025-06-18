function NIfTI_to_MAT_Padded(dataset, input_dir, output_dir)

if nargin < 3
    output_dir = input_dir;
end

%R2s_dir = 'C:\Users\rosly\Documents\Valerie_PH\Data\Padded\R2s\';

Magn_fn = fullfile( input_dir, [dataset, '_Magn_Padded.nii.gz']);
Magn = load_untouch_nii(Magn_fn);
Magn = single(Magn.img);

Phs_fn = fullfile( input_dir, [dataset, '_Phs_Padded.nii.gz']);
Phs = load_untouch_nii(Phs_fn);
Phs = single(Phs.img);

Mask_fn = fullfile( input_dir, [dataset, '_mask.nii.gz'] );
Mask = load_untouch_nii(Mask_fn);
Mask_Use = single(Mask.img);

R2s_fn = fullfile( input_dir, [dataset, '_R2s_Padded.nii.gz'] );
R2s = load_untouch_nii(R2s_fn);
R2s = single(R2s.img);

% if contains(dataset, "3T")
% voxel_size = [1 1 1];
% elseif contains(dataset, "7T")
% voxel_size = [.75 .75 .75];
% end

%R2s_load_fn = fullfile( R2s_dir, [dataset, '_R2s.mat'] );
%load(R2s_load_fn, "R2s");
% R2s_save_fn = fullfile( R2s_dir, [dataset, '_R2s_Padded.nii.gz'] );
% export_nii(R2s, R2s_save_fn, voxel_size);



savefile = fullfile( output_dir, [dataset, '_forQSM.mat'] );
save(savefile, "Magn", "Phs", "Mask_Use", "R2s");

end