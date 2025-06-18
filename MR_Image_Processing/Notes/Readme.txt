Readme.txt

%% git clone to Documents folder
Set path_to_data to same path
path_to_data = 'C:\Users\rosly\Documents\QSM_PH\Data\';
%% In MATLAB
Run Wrapper_QSM_Main(path_to_data).
This code will iterate "QSM_Main.m" through "dataset".

%% NIFTI files out:
% (a) Susceptibility maps by infinite parallel cylinder approximation:
%           "dataset_ROMEO" | ROMEO uw -> ROMEO fc -> ipca.
%           "dataset_NLF"   | NLF fc -> ROMEO uw -> ipca.
% (b) Susceptibility maps by dipole inversion:
%           "dataset_L1"    | NLF fc -> ROMEO uw -> MEDI di.
%           "dataset_L1L2"  | NLF fc -> ROMEO uw -> MEDI+0 di.
%           "dataset_L1SMV" | ROMEO uw -> ROMEO fc -> MEDI-SMV di.
% all other steps (masking, background field correction, etc.) kept consistent.
% Abbreviations: unwrapping = uw, fc = field calculation, dipole inversion = di,
% infinite parallel cylinder approximation = ipca

## Open a shell terminal
cd C:\Users\rosly\Documents\QSM_PH\Registration
wsl 
# If not installed ANTS already:
bash installANTs.sh
# Set ANTS to PATH:
sudo nano ~/.bashrc # to apply to wsl shell environment
export PATH=/home/uqphoop1/install/bin:$PATH
# Verify ANTS is set to PATH 
which antsRegistration # if true, provides path variable
# Run command
bash Run_ApplyAntsTransforms.sh