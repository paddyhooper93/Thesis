%% Wrapper_StatisticalAnalysis
% ** Bug Fix ** Use "clear All" when "readtable.m" function gives error.
close all
clear
clc

% Set default params
hdr = struct();
if ~isfield(hdr, 'TP9mth_only')
    hdr.TP9mth_only = false;
end

if ~isfield(hdr, 'CorrectNaCl')
    hdr.CorrectNaCl = false;
end

if ~isfield(hdr, 'doBA')
    hdr.doBA = true;
end

param = 'QSM';
ext = 'SNRwAVG_MEDI+0';
path_to = 'C:\Users\rosly\Documents\QSM_PH\Analysis\VSH8_SEPIA\';
% path_to = 'C:\Users\rosly\Documents\QSM_PH\Analysis\';
% path_to_data = fullfile(path_to, ext, param);
path_to_data = fullfile(path_to, ext);


eval(strcat('cd',32,path_to_data));
[Data] = DataRead(param, hdr);


if ~ hdr.TP9mth_only
    [DataTRR] = ExtractPairsforTRR(Data);
    [DataLDR] = ExtractPairsforLDR(Data);
    [DataFSR] = ExtractPairsforFSR(Data);
    [TRR_ICC, LDR_ICC, FSR_ICC, TV_ICC] = Wrapper_ICC(DataTRR, DataLDR, DataFSR);
    writeICCtoExcel(TRR_ICC, LDR_ICC, FSR_ICC, TV_ICC, strcat(param, '_', ext));
    [Bias] = QSM_Accuracy(DataFSR);
    writeBiastoExcel(Bias, strcat(param, '_', ext));
else
    [DataFSR] = ExtractPairsforFSR(Data, hdr);
    [Bias] = QSM_Accuracy(DataFSR);
    writeBiastoExcel(Bias, strcat(param, '_', ext));
end

if hdr.doBA

corrinfo = {'n','R2','eq'}; % stats to display of correlation scatter plot
BAinfo = {'ks'}; % stats to display on Bland-Altman plot
limits = 'tight'; % how to set the axes limits
colors = 'br'; % colors for the data sets using character codes
title_prefix = 'BA Analysis: ';

% i = {'USP', 'FER', 'CHL', 'CRB'};
i = {'CHL', 'CRB'};
% i = {'FER', 'USP'};

for quad = i
    
    if matches(quad{1}, 'FER')
        c_FER                = transpose(210:90:570) ./ 55.845; %mmol/L
        fer_mol_susc         = 0.0766; % ppm.L/mmol
        fer_vol_susc         = c_FER .* fer_mol_susc .* 1000; % ppb
        data1                = fer_vol_susc;
        % tit = strcat(param, 32, 'after', 32, title_prefix, ': ferritin ROIs');
        tit_fer = strcat(title_prefix, 'ferritin ROIs');
        label = {'Truth', 'Measured', 'ppb'};
        gnames = {label{1}, label{2}};
        
        data2_3T             = DataFSR.FER(:,1).*1000;
        tit = strcat(tit_fer, ', 3T');
        [cr1, fig1, statsStruct1] = BlandAltman(data1, data2_3T, label, tit, gnames, ...
            'corrInfo', corrinfo, 'baInfo', BAinfo, 'axesLimits', limits, ...
            'colors', colors, 'showFitCI', ' on', 'data1Mode', 'Truth');
        
        
        
        data2_7T             = DataFSR.FER(:,2).*1000;
        tit_7T = strcat(tit_fer, ', 7T');
        [cr2, fig2, statsStruct2] = BlandAltman(data1, data2_7T, label, tit_7T, gnames, ...
            'corrInfo', corrinfo, 'baInfo', BAinfo, 'axesLimits', limits, ...
            'colors', colors, 'showFitCI', ' on', 'data1Mode', 'Truth');
        
        data1 = data2_3T;
        data2 = data2_7T;
        label = {'3T', '7T', 'ppb'};
        gnames = {'3 T', '7 T'};
        [cr7, fig7, statsStruct7] = BlandAltman(data1, data2, label, tit_fer, gnames, ...
            'corrInfo', corrinfo, 'baInfo', BAinfo, 'axesLimits', limits, ...
            'colors', colors, 'showFitCI', ' on', 'data1Mode', 'Compare');

        
    elseif matches(quad{1}, 'USP')
        
        c_USP                = transpose(10:5:30) ./ 55.845; %mmol/L
        usp_mol_susc_3T      = 30.8 .* 55.845 ./ 1000; % ppm.L/mmol
        usp_mol_susc_7T      = 13.6 .* 55.845 ./ 1000; % ppm.L/mmol
        data1_3T             = c_USP .* usp_mol_susc_3T .* 1000; % ppb
        data1_7T             = c_USP .* usp_mol_susc_7T .* 1000; % ppb
        tit = strcat(title_prefix, 'USPIO ROIs');
        % tit = strcat(param, 32, 'after', 32, title_prefix, ': USPIO ROIs') ; % 'Reproducibility, USPIO ROIs',
        label = {'Truth', 'Measured', 'ppb'};
        gnames = {label{1}, label{2}};
        
        if exist('hdr', 'var') || hdr.is3T
            data2_3T             = DataFSR.USP(:,1) .* 1000; % ppb
            tit = strcat(tit, ', 3T');
            [cr3, fig3, statsStruct3] = BlandAltman(data1_3T, data2_3T, label, tit, gnames, ...
                'corrInfo', corrinfo, 'baInfo', BAinfo, 'axesLimits', limits, ...
                'colors', colors, 'showFitCI', ' on', 'data1Mode', 'Truth');
        end
        if exist('hdr', 'var') || hdr.is7T
            data2_7T             = DataFSR.USP(:,2) .* 1000; % ppb
            tit_7T = strcat(tit, ', 7T');
            [cr4, fig4, statsStruct4] = BlandAltman(data1_7T, data2_7T, label, tit_7T, gnames, ...
                'corrInfo', corrinfo, 'baInfo', BAinfo, 'axesLimits', limits, ...
                'colors', colors, 'showFitCI', ' on', 'data1Mode', 'Truth');
        end
    elseif matches(quad{1}, 'CHL')
        data1                = DataFSR.CHL(:,1).*1000; % ppb
        data2                = DataFSR.CHL(:,2).*1000; % ppb
        tit = strcat(title_prefix, 'CaCl_2 ROIs');
        label = {'3T', '7T', 'ppb'};
        gnames = {'3 T', '7 T'};
        [cr5, fig5, statsStruct5] = BlandAltman(data1, data2, label, tit, gnames, ...
            'corrInfo', corrinfo, 'baInfo', BAinfo, 'axesLimits', limits, ...
            'colors', colors, 'showFitCI', ' on', 'data1Mode', 'Compare');

        x_chl = transpose((0.1:0.1:0.5)./110.98.*1000); % mol/L
        Chl_mol_susc = -0.687;
        Chl_vol_susc = x_chl .* Chl_mol_susc; 
        data1 = Chl_vol_susc;

        data2_3T             = DataFSR.CHL(:,1).*1000;
        tit_3T = strcat(tit, ', 3T');
        [cr10, fig10, statsStruct10] = BlandAltman(data1, data2_3T, label, tit_3T, gnames, ...
            'corrInfo', corrinfo, 'baInfo', BAinfo, 'axesLimits', limits, ...
            'colors', colors, 'showFitCI', ' on', 'data1Mode', 'Truth');
        
        
        
        data2_7T             = DataFSR.CHL(:,2).*1000;
        tit_7T = strcat(tit, ', 7T');
        [cr20, fig20, statsStruct20] = BlandAltman(data1, data2_7T, label, tit_7T, gnames, ...
            'corrInfo', corrinfo, 'baInfo', BAinfo, 'axesLimits', limits, ...
            'colors', colors, 'showFitCI', ' on', 'data1Mode', 'Truth');

        
    elseif matches(quad{1}, 'CRB')
        data1                = DataFSR.CRB(:,1).*1000; % ppb
        data2                = DataFSR.CRB(:,2).*1000; % ppb
        tit = strcat(title_prefix, 'CaCO_3 ROIs');
        label = {'3T', '7T', 'ppb'};
        gnames = {'3 T', '7 T'};
        [cr6, fig6, statsStruct6] = BlandAltman(data1, data2, label, tit, gnames, ...
            'corrInfo', corrinfo, 'baInfo', BAinfo, 'axesLimits', limits, ...
            'colors', colors, 'showFitCI', ' on', 'data1Mode', 'Compare');

        x_crb = transpose((0.1:0.1:0.5)./100.0869.*1000); % mol/L
        Crb_mol_susc = -0.480;
        Crb_vol_susc = x_crb .* Crb_mol_susc; 
        data1 = Crb_vol_susc;

        data2_3T             = DataFSR.CRB(:,1).*1000;
        tit_3T = strcat(tit, ', 3T');
        [cr30, fig30, statsStruct30] = BlandAltman(data1, data2_3T, label, tit_3T, gnames, ...
            'corrInfo', corrinfo, 'baInfo', BAinfo, 'axesLimits', limits, ...
            'colors', colors, 'showFitCI', ' on', 'data1Mode', 'Truth');
        
        
        
        data2_7T             = DataFSR.CRB(:,2).*1000;
        tit_7T = strcat(tit, ', 7T');
        [cr40, fig40, statsStruct40] = BlandAltman(data1, data2_7T, label, tit_7T, gnames, ...
            'corrInfo', corrinfo, 'baInfo', BAinfo, 'axesLimits', limits, ...
            'colors', colors, 'showFitCI', ' on', 'data1Mode', 'Truth');
    end
    
end

end