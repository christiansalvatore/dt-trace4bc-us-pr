function computeRadiomics_AllPatients(pathRead,pathSave,nameRead,nameROI,nameSet,imParams,roiType,roiType_label)
% -------------------------------------------------------------------------
% AUTHOR(S): 
% - Martin Vallieres <mart.vallieres@gmail.com>
% -------------------------------------------------------------------------
% HISTORY:
% - Creation: April 2017
% -------------------------------------------------------------------------
% DISCLAIMER:
% "I'm not a programmer, I'm just a scientist doing stuff!"
% -------------------------------------------------------------------------
% STATEMENT:
% This file is part of <https://github.com/mvallieres/radiomics-develop/>, 
% a private repository dedicated to the development of programming code for
% new radiomics applications.
% --> Copyright (C) 2017  Martin Vallieres
%     All rights reserved.
%
% This file is written on the basis of a scientific collaboration for the 
% "radiomics-develop" team.
%
% By using this file, all members of the team acknowledge that it is to be 
% kept private until public release. Other scientists willing to join the 
% "radiomics-develop" team is however highly encouraged. Please contact 
% Martin Vallieres for this matter.
% -------------------------------------------------------------------------

startpath = pwd;

nPatient = 1;

% COMPUTATION
fprintf('\n')
for p = 1:nPatient
    fprintf('\n*********************** COMPUTING FEATURES ***********************');
    tStart = tic;
    
    % Initialization
    cd(pathRead)
    try
        load(nameRead) % Variable 'sData' now in MATLAB Workspace;
    catch
        fprintf('\nERROR LOADING PATIENT')
        continue
    end
    scanType = sData{2}.type;
    imParamScan = imParams.(scanType);
    if strcmp(scanType,'PTscan') % MOVE THIS IN THE READING DATA PART AND ALSO APPLY PVE CORRECTIONS AND DENOISING (for MRI(N3/N4 method) and CT too)?  FUTURE WORK ON ITS WAY (image post-processing)?
        try
            if isfield(sData{2},'nii')
                if max(sData{2}.nii.volume.data(:)) > 100 % Otherwise, we can safely assume that the data is already in SUV format.
                    sData{2}.nii.volume.data = computeSUVmap(single(sData{2}.nii.volume.data),sData{3}(1));
                end
            elseif isfield(sData{2},'nrrd')
                if max(sData{2}.nrrd.volume.data(:)) > 100 % Otherwise, we can safely assume that the data is already in SUV format.
                    sData{2}.nrrd.volume.data = computeSUVmap(single(sData{2}.nrrd.volume.data),sData{3}(1));
                end
            elseif isfield(sData{2},'img')
                if max(sData{2}.img.volume.data(:)) > 100 % Otherwise, we can safely assume that the data is already in SUV format.
                    sData{2}.img.volume.data = computeSUVmap(single(sData{2}.img.volume.data),sData{3}(1));
                end
            else
                if max(sData{2}.scan.volume.data(:)) > 100 % Otherwise, we can safely assume that the data is already in SUV format.
                    sData{2}.scan.volume.data = computeSUVmap(single(sData{2}.scan.volume.data),sData{3}(1));
                end
            end
        catch
            fprintf('\nERROR COMPUTING SUV MAP - SOME FEATURES WILL BE INVALID')
            continue
        end
    end
    patientID = sData{3}(1).PatientID; % DICOM MUST BE PRESENT
    voxDim = [sData{2}.scan.volume.spatialRef.PixelExtentInWorldX,sData{2}.scan.volume.spatialRef.PixelExtentInWorldY,sData{2}.scan.volume.spatialRef.PixelExtentInWorldZ]; % DICOM MUST BE PRESENT
    
    % Computation of ROI mask
    tic, fprintf('\n--> Computation of ROI mask: ')
    boxString = 'full'; % Safer to use a full box here.
    errorROI = false;
    try
        contourString = findContour(sData,nameROI{p},nameSet{p}); % OUTPUT IS FOR EXAMPLE '3' or '1-3+2'
        if isfield(sData{2},'nii')
            [volObjInit,roiObjInit] = getMask(sData,contourString,'nii',boxString); % This function uses the spatialRef calculated from the DICOM data. DICOM MUST BE PRESENT.
        elseif isfield(sData{2},'nrrd')
            [volObjInit,roiObjInit] = getMask(sData,contourString,'nrrd',boxString); % This function uses the spatialRef calculated from the DICOM data. DICOM MUST BE PRESENT.
        elseif isfield(sData{2},'img')
            [volObjInit,roiObjInit] = getMask(sData,contourString,'img',boxString); % This function uses the spatialRef calculated from the DICOM data. DICOM MUST BE PRESENT.
        else
            [volObjInit,roiObjInit] = getROI(sData,contourString,boxString); % This takes care of the "Volume resection" step as well using the argument "box". No fourth argument means 'interp' by default.
        end
        clear sData % Clear up RAM
    catch
        fprintf('\nPROBLEM WITH ROI')
        continue
    end
    toc
    
    % Computing radiomics features
    try 
        boxString = 'box10'; % 10 voxels in all three dimensions are added to the smallest bounding box. This setting is used to speed up interpolation processes (mostly) prior to the computation of radiomics features. Optional argument in the function computeRadiomics.
        [radiomics] = computeRadiomics(volObjInit,roiObjInit,imParamScan,boxString);
    catch
        fprintf('\nERROR IN RADIOMICS FEATURE COMPUTATION')
        continue
    end
    radiomics.imParam.roiType = roiType;
    radiomics.imParam.patientID = patientID;
    radiomics.imParam.voxDim = voxDim;
    
    % Saving radiomics structure
    indDot = strfind(nameRead,'.');
    nameSave = [nameRead(1:(indDot(1)-1)),'(',roiType_label,')',nameRead(indDot(1):end)];
    cd(pathSave), save(nameSave,'radiomics') % IMPORTANT: HERE, WE COULD ADD SOME CODE TO APPEND A NEW "radiomics" STRUCTURE TO AN EXISTING ONE WITH THE SAME NAME IN "pathSave"
    time = toc(tStart);
    fprintf('TOTAL TIME: %.2f seconds\n',time)
end

cd(startpath)
end