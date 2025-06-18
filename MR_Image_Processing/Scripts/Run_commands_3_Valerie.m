function Run_commands_3_Valerie()

% clc
% close all
% 
% Wrapper_SDC()
% 
% clc
% close all
% 
% SDCMAT_for_QSM()
% 
% clc
% close all

%% NLFit + GC + LBV
%% Troubleshooting weights calculation: Turn off weight modulation
hdr.RelativeResidualWeighting = 0; hdr.NLFitWeighting = 0;
hdr.saveWorkspace = 1; hdr.BFCMethod = 'LBV';
hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Precursor_Steps\NLFit_GC_LBV\';
Wrapper_QSM_Main_Valerie(hdr);

%% NLFit + GC + RESHARP
%% Troubleshooting weights calculation: Turn off weight modulation
hdr.RelativeResidualWeighting = 0; hdr.NLFitWeighting = 0;
hdr.saveWorkspace = 1; hdr.BFCMethod = 'RESHARP';
hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Precursor_Steps\NLFit_GC_RESHARP\';
Wrapper_QSM_Main_Valerie(hdr);

%% NLFit + GC + PDF
%% Troubleshooting weights calculation: Turn off weight modulation
hdr.RelativeResidualWeighting = 0; hdr.NLFitWeighting = 0;
hdr.saveWorkspace = 1; hdr.BFCMethod = 'PDF';
hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Precursor_Steps\NLFit_GC_PDF\';
Wrapper_QSM_Main_Valerie(hdr);

%% NLFit + GC + VSH12 (STI)
hdr.RelativeResidualWeighting = 0; hdr.NLFitWeighting = 0; 
hdr.saveWorkspace = 1; hdr.BFCMethod = 'V-SHARP 12SMV STI';
hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Precursor_Steps\NLFit_GC_VSH12_STI\';
Wrapper_QSM_Main_Valerie(hdr);

%% NLFit + GC + VSH12 (SEPIA)
%% Troubleshooting weights calculation
hdr.RelativeResidualWeighting = 0; hdr.NLFitWeighting = 0;
hdr.saveWorkspace = 1; hdr.BFCMethod = 'V-SHARP 12SMV SEPIA';
hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Precursor_Steps\NLFit_GC_VSH12_SEPIA\';
Wrapper_QSM_Main_Valerie(hdr);

% hdr.saveWorkspace = 1; hdr.RelativeResidualWeighting = 0; hdr.NLFitWeighting = 1;
% hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Precursor_Steps\NLFit_GC_VSH8_NLFitWeights\';
% Wrapper_QSM_Main_Valerie(hdr);
% 
% hdr.saveWorkspace = 1; hdr.RelativeResidualWeighting = 1; hdr.NLFitWeighting = 0;
% hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Precursor_Steps\NLFit_GC_VSH8_RRWeights\';
% Wrapper_QSM_Main_Valerie(hdr);

% %% NLFit + GC + RESHARP
% hdr.BFCMethod = 'RESHARP';
% hdr.saveWorkspace = 1; hdr.saveInfCyl = 1; hdr.RelativeResidualWeighting = true;
% hdr.output_dir = 'C:\Users\rosly\Documents\Valerie_PH\Analysis\Precursor_Steps\NLFit_GC_RESHARP\';
% Wrapper_QSM_Main_Valerie(hdr)

end