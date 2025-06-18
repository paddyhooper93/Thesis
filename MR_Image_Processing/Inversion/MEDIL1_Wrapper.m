function [qsm, c_d_m, c_r_m, D] = MEDIL1_Wrapper(RDF, N_std, ...
    Mask, Mask_CSF, CF, hdr, B0_dir)
% Output args: 
% c_d_m = cost_data_medi
% c_r_m = cost_reg_medi

if nargin < 7
    B0_dir = [0 0 1]';
end

% Load initial vars
delta_TE = hdr.delta_TE;
iMag = hdr.iMag;
voxel_size = hdr.voxel_size;
matrix_size = hdr.matrix_size;

% MEDI expects local field in rad
RDF                 = RDF.*(2*pi*delta_TE);

% Save RDF in correct format
tmp_filename                = fullfile(hdr.output_dir, [hdr.dataset '_tmp_RDF.mat']);

iFreq = [];
s = struct("iFreq", iFreq, "RDF", RDF, 'N_std', N_std, 'iMag', iMag, ...
    'Mask', Mask, 'matrix_size', matrix_size, 'voxel_size', voxel_size, ...
    'delta_TE', delta_TE, 'CF', CF, 'B0_dir', B0_dir, 'Mask_CSF', Mask_CSF);

save(tmp_filename, '-fromstruct', s);

if exist(fullfile('.','results'),'dir')
    isResultDirMEDIExist = true;
else
    isResultDirMEDIExist = false;
end

% Algorithm parameters
isSMV = hdr.isSMV;
lambda = hdr.lambda;
lam_CSF = hdr.lam_CSF;
radius = hdr.radius;
isMerit = hdr.isMerit;
wData = hdr.wData;
wGrad = hdr.wGrad;
pad = hdr.pad;
percentage = hdr.percentage;


if isSMV
    [qsm, c_d_m, c_r_m, D] = MEDI_L1('filename',tmp_filename,'lambda',lambda,'data_weighting',wData,'gradient_weighting',wGrad,...
        'merit',isMerit,'smv',radius,'zeropad',pad,'lambda_CSF',lam_CSF,'percentage',percentage);
    SphereK = single(sphere_kernel(matrix_size, voxel_size,radius));
    Mask = SMV(Mask, SphereK)>0.999;
else
    [qsm, c_d_m, c_r_m, D] = MEDI_L1('filename',tmp_filename,'lambda',lambda,'data_weighting',wData,'gradient_weighting',wGrad,...
        'merit',isMerit,'zeropad',pad,'lambda_CSF',lam_CSF,'percentage',percentage);
end

qsm = qsm .* Mask;

% clean up MEDI output and temp files
delete(tmp_filename);
if isResultDirMEDIExist
    fileno=getnextfileno(['results' filesep],'x','.mat') - 1;
    resultsfile=strcat(['results' filesep 'x'],sprintf('%08u',fileno), '.mat');
    delete(resultsfile)
else
    rmdir(fullfile(pwd,'results'),'s');
end
