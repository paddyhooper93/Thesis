function Wrapper_COSMOS_Recon(num_orient, input_dir, FS_str, isNewFile)
% B = Registered tissue fields (concatenated along dim4)
% W = Weights (concatenated along dim4)
% D = Dipole kernel (concatenated along dim4)
% R_tot = 3x3 rotation matrices (concatenated along dim3)
% B0_dir = 1x3 column vectors (concatenated along dim 2)
% M = Brain ROI Mask (reference orientation)
% voxel_size = resolution (mm per vox)

% clearvars
close all

% InitiateParallelComputing();

if 7~=exist("input_dir", "dir")
    mkdir(input_dir);
    cd(input_dir);
end

%% Boolean parameters
% Set flag to save and load new parameters ("M", "W", "B", "R_tot", "voxel_size")
if 1~=exist("isNewFile", "var")
    isNewFile = true;
end
% Set flag to visualize images during reconstruction
if 1~=exist("flag_viewimg", "var")
    flag_viewimg = false;
end
% Set flag to run MEDI
if 1~=exist("flag_runMEDI", "var")
    flag_runMEDI = false;
end
% Set flag to optimize MEDI
if 1~=exist("flag_optMEDI", "var")
    flag_optMEDI = false;
end
% Set flag to solve for chi by solving an optimization problem with LSQR
if 1~=exist("flag_useLSQR", "var")
    flag_useLSQR = false;
end
% Set flag to optimize the LSQR tolerance parameter
if 1~=exist("flag_optLSQR", "var")
    flag_optLSQR = false;
end
% Set flag to apply low-pass filtering (within k-space) to B before COSMOS recon
if 1~=exist("flag_lowpass", "var")
    flag_lowpass = false;
end
% Set flag to apply Gaussian filtering (within image-space) to B before COSMOS recon
if 1~=exist("flag_Gaussian", "var")
    flag_Gaussian = false;
end
% NSet number of orientations to include in COSMOS reconstruction
if 1~=exist("num_orient", "var")
    num_orient = 6;
end



for i = FS_str %{'3T', '7T'}
    
    
    % Set value for num_orient
    % if 1~=exist("num_orient", "var")
    % num_orient = idx;
    % end
    
    output_dir = fullfile(input_dir, [ 'Num_Orient_', num2str(num_orient)] );
    
    % Make new dir for output files
    if 7~=exist("output_dir", "dir")
        mkdir(output_dir);
    end
    
    
    
    % This code searches for a text file matching a pattern - if not found, then create a new MAT file.
    pattern = [FS_str, '_Num_Orient_',num2str(num_orient),'.txt'];
    txt_file = dir(fullfile(output_dir, pattern));
    
    if isNewFile
        cd(output_dir);
        delete(pattern);
        pause(1);
    end
    
    pause(1); % Ensure file operations complete before IF statement
    
    if isempty(txt_file)
        Save_InputData_ForCOSMOS(FS_str, num_orient, output_dir);
    end
    
    % Load vars from MAT file
    matfile = fullfile(output_dir, [FS_str, '_COSMOS_',num2str(num_orient),'_inputVars.mat'] );
    load(matfile, "M", "W", "B", "R_tot", "voxel_size", "CSF_Mask"); 
    
    % View loaded vols
    if flag_viewimg
        plot_axialSagittalCoronal(mean(W, 4), 2, [0, 1], 'SNR weighting map');
        plot_axialSagittalCoronal(M, 4, [0, 1], 'Brain ROI mask');
        plot_axialSagittalCoronal(mean(B, 4), 6, [-.05,.05], 'Average Tissue Phase');
    end
    %% Obtain axial rotations (Theta_x, Theta_y), net rotation (Theta_B0)
    [Theta_x, Theta_y, Theta_B0] = ObtainRotationAngles(R_tot, num_orient);
    for dir_idx = 1:num_orient
        fprintf('\n Acquisition %i : %.1f %.1f %.1f deg \n', dir_idx, ...
            rad2deg(Theta_x(dir_idx)), rad2deg(Theta_y(dir_idx)), ...
            rad2deg(Theta_B0(dir_idx)) );
    end
    
    %% View kernel and B in k-space
    [B0dir] = ObtainFieldDirection(R_tot, num_orient);
    N = size(M);
    [D, kappa] = kernel_COSMOS(N, voxel_size, num_orient, B0dir, flag_viewimg); % 'B0_dir', B0_dir,
    fprintf('\n Condition number (Kappa) : %.1f \n', kappa);
    
    % (optional) apply filter to reduce high frequency noise.
    if flag_lowpass
        B_Fermi = zeros(size(B));
        for dir_idx = 1:num_orient
            [B_Fermi(:,:,:,dir_idx), ~, ~ ] = FermiFilter(B(:,:,:,dir_idx));
        end
        B = B_Fermi; clear B_Fermi
    end
    
    if flag_Gaussian
        B_Gaussian = zeros(size(B));
        SD = 1.2/2.355; % FHWM = 1.2 voxels (SD = FWHM/2.355)
        for dir_idx = 1:num_orient
            [~, B_Gaussian(:,:,:,dir_idx), ~] = smooth3(B(:,:,:,dir_idx), 'gaussian', 3, SD); % kernel 3x3x3 voxels
        end
        B = B_Gaussian; clear B_Gaussian
    end
    
    
    
    ksp_B = log( fftshift(abs(fftn(mean(B,4)))) );
    scale_log = [2, 6.5];
    figure(31);
    tiledlayout(1,3, 'Padding', 'compact', 'TileSpacing', 'compact');
    
    nexttile; imagesc( ksp_B(:,:,1+end/2), scale_log ), axis square off, colormap gray
    nexttile; imagesc( squeeze(ksp_B(:,1+end/2,:)), scale_log ), axis square off, colormap gray
    nexttile; imagesc( squeeze(ksp_B(1+end/2,:,:)), scale_log ), axis square off, colormap gray; colorbar;
    saveas(gcf,fullfile(output_dir,[FS_str,'_B_ksp_', num2str(num_orient),'_Orient.png']));
    
    
    %% COSMOS reconstruction with closed-form solution    (MskBeforeFFT)
    D2 = sum(abs(D).^2, 4);


    
    chi_CF = real( ifftn( sum(D .* fftn(B), 4) ./ (eps + D2) ) ) ;
    chi_CF = chi_CF - mean(chi_CF(CSF_Mask>0));
    chi_CF_rs = (chi_CF + -0.1106) .* M;
    chi_CF_rs = pad_or_crop_target_size( chi_CF_rs, voxel_size);
    
    export_nii(chi_CF_rs, fullfile(input_dir, [ FS_str, '_chi_CF_', num2str(num_orient), '_Orient']), voxel_size);
    if flag_viewimg
        plot_axialSagittalCoronal(chi_CF, 24, [-.5,.5], 'COSMOS via closed form solution')
    end
    ksp_CF = log( fftshift(abs(fftn(chi_CF_rs))) );
    scale_log = [2, 9.5];
    figure(33);
    tiledlayout(1,3, 'Padding', 'compact', 'TileSpacing', 'compact');
    nexttile; imagesc( ksp_CF(:,:,1+end/2), scale_log ), axis square off, colormap gray
    nexttile; imagesc( squeeze(ksp_CF(:,1+end/2,:)), scale_log ), axis square off, colormap gray
    nexttile; imagesc( squeeze(ksp_CF(1+end/2,:,:)), scale_log ), axis square off, colormap gray; colorbar;
    saveas(gcf,fullfile(output_dir,[FS_str,'_CF_ksp_', num2str(num_orient),'_Orient.png']));
    
    if flag_runMEDI
        
        QSM = zeros(size(B));
        
        for dir_idx = 1:num_orient
            
            %% Preparation of input arguments for MEDI_L1.m function
            
            % MEDI expects MATLAB variable names to be specified using their syntax
            matrix_size = N;
            
            Mask_CSF = CSF_Mask;
            iFreq = [];
            Mask = M;
            weights = W(:,:,:,dir_idx);
            RDF = B(:,:,:,dir_idx);
            B0_dir = B0dir(:,dir_idx); % Idx to Dim2
            iMag = Magn(:,:,:,dir_idx);
            
            if matches(FS_str, '3T')
                CF                          = 42.6*2.89*10^6; % in units MHz
                % lambda = 10^1.5;
                % lambda = 10^2;
                lam_CSF = 10^2;
                if dir_idx == 1
                    lambda = 10^1.75;
                elseif dir_idx == 4
                    lambda = 10^3.5;
                else
                    lambda = 10^2.5;
                end
                
            elseif matches(FS_str, '7T')
                CF                          = 42.6*7.00*10^6;
                % lambda = 10^3.5;
                % lambda = 10^4;
                lam_CSF = 10^1;
                if dir_idx == 1
                    lambda = 10^3.25;
                else
                    lambda = 10^3.75;
                end
            end
            
            
            % MEDI expects local field in radians:
            % RDF is currently in ppm.
            RDF = RDF .* (CF/10^6); % Converting back from ppm to Hz.
            delta_TE = 3./1000; % echo spacing in secs
            RDF = RDF .* (2*pi*delta_TE); % Converting from Hz to radians.
            
            % MEDI requires noise map (the inverse of the weights map)
            N_std = (1 ./ weights) .* Mask;
            N_std(isnan(N_std)) = 0;
            N_std(isinf(N_std)) = 0;
            N_std = N_std / norm(N_std(Mask > 0));
            
            % MAT file to be read within MEDI_L1.m variable parsing function.
            tmp_output_dir              = [pwd filesep];
            tmp_filename                = [tmp_output_dir 'tmp_RDF.mat'];
            
            save(tmp_filename, 'iFreq', 'RDF', 'N_std', 'iMag', ...
                'Mask', 'matrix_size', 'voxel_size', 'delta_TE', ...
                'CF', 'B0_dir', 'Mask_CSF');
            
            if exist(fullfile('.','results'),'dir')
                isResultDirMEDIExist = true;
            else
                isResultDirMEDIExist = false;
            end
            
            % Parameters to be parsed directly into MEDI_L1.m function
            
            wData = true;
            wGrad = true;
            isMerit = true;
            pad = 0;
            percentage = 0.3;
            
            
            if flag_optMEDI && dir_idx == 1 %&& matches(FS_str,'7T')
                
                %     param_flag = 'pc';
                %     [ ~, paramOpt_idx_1, ~, chiOpt_Morozov_idx_1] = ParamOpt_MEDI(...
                %         param_flag, FS_str, output_dir, iFreq, RDF, ...
                % N_std, iMag, Mask, matrix_size, voxel_size, ...
                % delta_TE, CF, B0_dir, Mask_CSF, dir_idx );
                
                
                
                %     percentage = paramOpt_Morozov;
                %
                %
                
                % QSM(:,:,:,dir_idx) = zeros(size(RDF));
                
                % [filename, flag, FS, idx_dir, RDF, lambda, percentage]
                
                cd(output_dir);
                
                FS = FS_str;
                
                param_flag = 'lam_csf';
                [ ~, ~, ~, qsm] = ParamOpt_MEDI('filename', tmp_filename, 'flag', param_flag, ...
                    'FieldStrength', FS, 'idx_dir', dir_idx, 'lambda', lambda );
                
                QSM(:,:,:,dir_idx) = (qsm + -0.1106) .* Mask;
                %
                % else
                %
                %lambda = 2680;
                
                % qsm = MEDI_L1('filename',tmp_filename,'lambda',lambda,'data_weighting',wData,'gradient_weighting',wGrad,...
                % 'merit',isMerit,'zeropad',pad,'lambda_CSF',lam_CSF,'percentage',percentage);
                %
                % qsm = (qsm + -0.1106) .* Mask;
                %
                % QSM(:,:,:,dir_idx) = qsm;
                %
                % end
                
                %
                %     lambda = paramOpt_Morozov;
                %
                % param_flag = 'lam_csf';
                % [ ~, ~, ~, qsm] = ParamOpt_MEDI('filename', tmp_filename, 'param_flag', param_flag, ...
                %     'FS_str', FS_str, 'dir_idx', dir_idx, 'output_dir', output_dir, 'lambda', lambda);
                %
                % QSM(:,:,:,2) = (qsm + -0.1106) .* Mask;
                
                % elseif dir_idx == 2 && flag_optMEDI
                
                %     param_flag = 'pc';
                %     [ ~, percentage_idx_2, ~, chiOpt_Morozov_idx_2] = ParamOpt_MEDI(...
                %         param_flag, FS_str, output_dir, iFreq, RDF, ...
                % N_std, iMag, Mask, matrix_size, voxel_size, ...
                % delta_TE, CF, B0_dir, Mask_CSF, dir_idx );
                
                %     percentage = paramOpt_Morozov;
                %
                %
                %
                %     param_flag = 'lam';
                %     [ ~, paramOpt_idx_2, ~, chiOpt_Morozov_idx_2] = ParamOpt_MEDI(...
                %         param_flag, FS_str, output_dir, iFreq, RDF, ...
                % N_std, iMag, Mask, matrix_size, voxel_size, ...
                % delta_TE, CF, B0_dir, Mask_CSF, dir_idx );
                %
                %     QSM(:,:,:,dir_idx) = (chiOpt_Morozov_idx_2 + -0.1106) .* Mask;
                
                % qsm = MEDI_L1('filename',tmp_filename,'lambda',lambda,'data_weighting',wData,'gradient_weighting',wGrad,...
                % 'merit',isMerit,'zeropad',pad,'lambda_CSF',lam_CSF,'percentage',percentage);
                %
                % qsm = (qsm + -0.1106) .* Mask;
                %
                % QSM(:,:,:,dir_idx) = qsm;
                
                %     lambda = paramOpt_Morozov;
                %
                %     param_flag = 'csf';
                %     [ ~ , ~ , ~, ~] = ParamOpt_MEDI(...
                %         param_flag, FS_str, output_dir, iFreq, RDF, ...
                % N_std, iMag, Mask, matrix_size, voxel_size, ...
                % delta_TE, CF, B0_dir, Mask_CSF, dir_idx, lambda );
                
                
                
            else
                
                
                qsm = MEDI_L1('filename',tmp_filename,'lambda',lambda,'data_weighting',wData,'gradient_weighting',wGrad,...
                    'merit',isMerit,'zeropad',pad,'lambda_CSF',lam_CSF,'percentage',percentage);
                
                qsm = (qsm + -0.1106) .* Mask;
                
                QSM(:,:,:,dir_idx) = qsm;
                
                
                
                % clean up MEDI output and temp files
                delete(tmp_filename);
                if isResultDirMEDIExist
                    fileno=getnextfileno(['results' filesep],'x','.mat') - 1;
                    resultsfile=strcat(['results' filesep 'x'],sprintf('%08u',fileno), '.mat');
                    delete(resultsfile)
                else
                    rmdir(fullfile(pwd,'results'),'s');
                end
                
            end
            
            
            
        end
        
        % paramOpt = mean([paramOpt_idx_1, paramOpt_idx_2]);
        
        
        
        QSM = pad_or_crop_target_size(QSM, voxel_size);
        QSM_str = [FS_str, '_chi_MEDI_', num2str(num_orient), '_Orient_lambda', num2str(round(lambda)), '_lamCSF_', num2str(round(lam_CSF))];
        export_nii(QSM, fullfile(input_dir, QSM_str), voxel_size);
        
    end
    
    
    
    %% COSMOS reconstruction with LSQR solver
    if flag_useLSQR
        
        % Optimize flag, if TRUE, optimize LSQR tolerance using L-curve maximum
        % curvature, if FALSE, then parse through preset LSQR tolerance
        if flag_optLSQR
            
            param = logspace(-12, -1, 12);
            
            chi_WLS = LCurve_LSQR_COSMOS(param, FS_str, B, W, M, D, chi_CF);
            
            fprintf('\n Optimal lam_CSF: %.3e \n', param_Opt);
            tic
            chi_WLS = (chi_WLS + -0.1106) .* M;
            chi_WLS = pad_or_crop_target_size(chi_WLS, voxel_size);
            toc
            
            export_nii(chi_WLS, fullfile(output_dir, [FS_str, '_chi_LSQR_Opt']), voxel_size);
            if flag_viewimg
                plot_axialSagittalCoronal(chi_WLS, 26, [-.5,.5], 'COSMOS with lsqr solver, Optimal')
            end
        else
            
            
            % Parse through TOL and x0 (initial guess)
            tic
            [chi_WLS] = COSMOS_nonlinear(B, D, W, M, CSF_Mask, 'x0', chi_CF);
            chi_WLS = chi_WLS - mean(chi_WLS(CSF_Mask>0));
            chi_WLS = (chi_WLS + -0.1106) .* M;
            chi_WLS = pad_or_crop_target_size(chi_WLS, voxel_size);
            toc
            
            export_nii(chi_WLS, fullfile(input_dir, [FS_str, '_chi_LSQR_', num2str(num_orient), '_Orient']), voxel_size);
            if flag_viewimg
                plot_axialSagittalCoronal(chi_WLS, 22, [-.5,.5], 'COSMOS with lsqr solver')
            end
        end
        
        %% k-space picture
        
        
        ksp_WLS = log( fftshift(abs(fftn(chi_WLS))) );
        
        figure(35);
        tiledlayout(1,3, 'Padding', 'compact', 'TileSpacing', 'compact');
        nexttile; imagesc( ksp_WLS(:,:,1+end/2), scale_log ), axis square off, colormap gray
        nexttile; imagesc( squeeze(ksp_WLS(:,1+end/2,:)), scale_log ), axis square off, colormap gray
        nexttile; imagesc( squeeze(ksp_WLS(1+end/2,:,:)), scale_log ), axis square off, colormap gray; colorbar;
        saveas(gcf,fullfile(output_dir,[FS_str,'_WLS_ksp_', num2str(num_orient),'_Orient.png']));
    end
    
end







