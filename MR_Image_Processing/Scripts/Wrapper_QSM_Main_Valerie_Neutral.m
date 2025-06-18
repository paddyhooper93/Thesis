function [hdr] = Wrapper_QSM_Main_Valerie_Neutral(hdr)
%
% clear cmd window, wkspace, figures window
% clc
% clear
% close all

%% Set directory for data input
hdr.path_to_data = 'C:\Users\rosly\Documents\Valerie_PH\Data\SDC\';
eval(strcat('cd', 32, hdr.path_to_data));

%% Set and write directory for processing & output
% hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\MCPC\tmp_NLFit_RESHARP_TE1to4\';
if 7~=exist(hdr.output_dir, 'dir')
    eval(strcat('mkdir', 32, hdr.output_dir));
end

%% Loop through QSM_Main
i = {'3T_Neutral', '7T_Neutral'};

for dataset = i
    QSM_Main_Valerie(dataset{1}, hdr);
    fprintf('Processed Dataset %s \n', dataset{1});
end

%% unix("bash Run_antsApplyTransforms.sh")

% Since I'm using Windows, I added a breakpoint to the next line of code.
% bourne-again shell script ("Run_antsApplyTransforms.sh") through a terminal in a WSL environment.

% After running the Shell script, the registered volumes will be exported to
% the following directory, relative to hdr.output_dir: "..\rgst\".