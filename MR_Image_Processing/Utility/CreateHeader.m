function [hdr] = CreateHeader(hdr)
% Argin: "hdr" structure, used to parse variables
% Argout: "hdr" structure, variables parsed
% Adjust parameters here.
% Useage: Boolean. 

% Do not adjust "hdr.excludeDistal".
hdr.excludeDistal = true; % Excludes erroneous voxels at distal slices.

% Turn on automatic CSF referencing (MEDI+0)
% hdr.isLambdaCSF = false;

% Use RTS for dipole inversion
% hdr.isRTS = false;

% Turn all these to true to export masks.
hdr.saveMaskUse = false; % Exports NIfTI file of Mask_Use
hdr.saveQSMMask = false; % Export NIfTI file of QSM_Mask
hdr.saveComplementMask = false; % Export NIfTI file of Complement_Mask
hdr.saveErodedComplementMask = false; % Export NIfTI file of Eroded_Complement_Mask

% Turn all these to true to export earlier steps only.
% hdr.noDipoleInversion = true; % Turns off dipole inversion (saves a lot of processing time).
% hdr.saveInfCyl = true; % Exports NIfTI file of susceptibility map (in ppm), calculated by infinite cylinder model
% hdr.saveFieldMap = false; % Exports NIfTI file of field map (in Hz)