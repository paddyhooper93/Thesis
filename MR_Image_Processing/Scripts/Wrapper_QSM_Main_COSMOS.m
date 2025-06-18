function Wrapper_QSM_Main_COSMOS(hdr, dataset)

%% Set directory for data input
% cd(hdr.path_to_data);

%% Set and write directory for processing & output

if 7~=exist(hdr.output_dir, 'dir')
    mkdir(hdr.output_dir);
end
    
    QSM_Main_Valerie(dataset, hdr);
    %% MEDI only
    % workspace_fn = strcat(dataset, '_workspace.mat');
    % load(workspace_fn, 'iFreq', 'weights', 'RDF', 'hdr');
    % DipoleInversion(iFreq, weights, RDF, hdr);
    fprintf('Processed Dataset %s \n', dataset);
% end

%% Open a Bash Shell Terminal in WSL then,: bash antsRegistration_Valerie.sh
%% Since I'm using Windows, I added a breakpoint to the next line of code.
%% Then, COSMOS_Recon.m via its wrapper function Wrapper_COSMOS_Recon.m
