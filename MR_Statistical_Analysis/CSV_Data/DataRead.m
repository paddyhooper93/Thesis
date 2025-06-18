function [Data] = DataRead(param, qsm_dir, roi_dir, hdr)

if nargin < 4
    % Set default params
    hdr = struct();
    hdr.TP9mth_only = false;
    hdr.CorrectNaCl = false;
    hdr.Idpt = false;
end

i = { '3T_BL', '3T_BL_Rep', '3T_9mth', '3T_24mth', '3T_24mth_Rep', ...
     '7T_BL', '7T_BL_Rep', '7T_9mth', '7T_24mth', '7T_24mth_Rep'}; 
x=0;
for dataset = i
    x=x+1;
    qsm=load_untouch_nii(fullfile(qsm_dir, [dataset{1}, '_QSM.nii.gz']));
    roi=load_untouch_nii(fullfile(roi_dir, [dataset{1}(1:2), '_segmentation.nii.gz']));
    if contains(dataset{1}, '7T')
        qsm.img(:,:,1:70)=0;
        roi.img(:,:,1:70)=0;
    end
    qsm = single(qsm.img);
    roi = single(roi.img);

    usp_SD = zeros(10,4);
    usp_Mu = zeros(10,4);
    ftn_SD = zeros(10,4);
    ftn_Mu = zeros(10,4);
    chl_SD = zeros(10,4);
    chl_Mu = zeros(10,4);
    crb_SD = zeros(10,4);
    crb_Mu = zeros(10,4);

    nQuads = 4;
    for q = 1:nQuads
        [usp_SD(x,q), usp_Mu(x,q)]=std(qsm(roi==q));
        [ftn_SD(x,q), ftn_Mu(x,q)]=std(qsm(roi==q+5));
        [chl_SD(x,q), chl_Mu(x,q)]=std(qsm(roi==q+10));
        [crb_SD(x,q), crb_Mu(x,q)]=std(qsm(roi==q+15));
    end
end

% DataRead1 = readtable(strcat('3T_',param,'.csv'), "VariableNamingRule", "preserve");
% DataRead2 = readtable(strcat('7T_',param,'.csv'), "VariableNamingRule", "preserve"); 


% Note on 24mth time-point (Cols 11 to 14):
% ROIs were flipped for USP, FER and swapped for CRB.
% 2 ROIs (i.e., vials) were removed for CHL, 
% so we didn't analyse CHL for 24mth time-point.

if ~hdr.TP9mth_only
    % 24mth ROIs were flipped for USP & FER
    Data.USP_3T = cat(2, DataRead1{2:6, 5:2:9}, flip(DataRead1{12:16, 11:2:13}, 1));
    Data.FER_3T = cat(2, DataRead1{7:11, 5:2:9}, flip(DataRead1{2:6, 11:2:13}, 1));
    Data.CHL_3T = DataRead1{12:16, 5:2:9};
    % 24mth ROIs were swapped for CRB 
    Data.CRB_3T = DataRead1{17:21, 9:2:13};   
    Data.CRB_3T([7 10]) = Data.CRB_3T([10 7]);
    Data.CRB_3T([6 9]) = Data.CRB_3T([9 6]);
    Data.CRB_3T([11 14]) = Data.CRB_3T([14 11]);
    Data.CRB_3T([12 15]) = Data.CRB_3T([15 12]);

    Data.USP_7T = cat(2, DataRead2{2:6, 5:2:9}, flip(DataRead2{12:16, 11:2:13}, 1));
    Data.FER_7T = cat(2, DataRead2{7:11, 5:2:9}, flip(DataRead2{2:6, 11:2:13}, 1));
    Data.CHL_7T = DataRead2{12:16, 5:2:9};
    
    Data.CRB_7T = DataRead2{17:21, 9:2:13};
    Data.CRB_7T([7 10]) = Data.CRB_7T([10 7]);
    Data.CRB_7T([6 9]) = Data.CRB_7T([9 6]);
    Data.CRB_7T([11 14]) = Data.CRB_7T([14 11]);
    Data.CRB_7T([12 15]) = Data.CRB_7T([15 12]);
else
    Data.USP_3T = DataRead1{2:6, 5};
    Data.FER_3T = DataRead1{7:11, 5};
    Data.CHL_3T = DataRead1{12:16, 5};
    Data.CRB_3T = DataRead1{17:21, 5};

    Data.USP_7T = DataRead2{2:6, 5};
    Data.FER_7T = DataRead2{7:11, 5};
    Data.CHL_7T = DataRead2{12:16, 5};
    Data.CRB_7T = DataRead2{17:21, 5};
end

%% Correct for susceptibility of bulk medium (if not already done within Dipole Inversion script)
if hdr.CorrectNaCl
    fields = fieldnames(Data);
    for i = 1:numel(fields)
        fieldName = fields{i};  
        Data.(fieldName) = Data.(fieldName) - 0.1106;
    end
end

end

