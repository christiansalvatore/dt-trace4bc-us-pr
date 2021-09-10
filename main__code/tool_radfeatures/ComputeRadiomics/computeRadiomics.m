function [radiomics,scaleName] = computeRadiomics(volObjInit,roiObjInit,imParamScan,boxString,is3D)
% -------------------------------------------------------------------------
% AUTHOR(S): 
% - Martin Vallieres <mart.vallieres@gmail.com>
% -------------------------------------------------------------------------
% HISTORY:
% - Creation: August 2017
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

% - imParamScan.image: Image processing parameters for the image space.
% - imParamScan.filter: Image processing parameters for filtered image space.
%   If this .filter structure is not present in imParamScan, no wavelet
%   features will be computed.
% - Eventually, "imParam" variable could be better organized, this is confusing.


% PARSING LAST ARGUMENT
if nargin < 4
    boxString = 'full'; % Fourth argument is optional. If not present, we use the full box.
end


% INITIALIZATION
radiomics.image = struct;
scaleNonText = imParamScan.image.interp.scaleNonText; 
volInterp = imParamScan.image.interp.volInterp; roiInterp = imParamScan.image.interp.roiInterp;
glRound = imParamScan.image.interp.glRound;
roiPV = imParamScan.image.interp.roiPV;
range = imParamScan.image.reSeg.range;
outliers = imParamScan.image.reSeg.outliers;
IH = imParamScan.image.discretisation.IH;
IVH = imParamScan.image.discretisation.IVH;
scaleText = imParamScan.image.interp.scaleText; 
algo = imParamScan.image.discretisation.texture.type; 
grayLevels = imParamScan.image.discretisation.texture.val;
nScale = numel(scaleText);
nAlgo = numel(algo);
nGl = numel(grayLevels{1});
nExp = nScale*nAlgo*nGl;
% glcm = cell(nScale,nAlgo,nGl);
% glrlm = cell(nScale,nAlgo,nGl);
% glszm = cell(nScale,nAlgo,nGl);
% ngtdm = cell(nScale,nAlgo,nGl);
% gldzm = cell(nScale,nAlgo,nGl);
% ngldm = cell(nScale,nAlgo,nGl);
% type = imParamScan.image.type;
intensity = imParamScan.image.intensity; % Variable used to determine if there is 'arbitrary' (e.g., MRI) or 'definite' (e.g., CT) intensities.
if isfield(imParamScan.image,'distCorrection')
    distCorrection = imParamScan.image.distCorrection;
else
    distCorrection = false;
end
if isfield(imParamScan.image,'computeDiagFeatures')
    computeDiagFeatures = imParamScan.image.computeDiagFeatures;
else
    computeDiagFeatures = false;
end
if computeDiagFeatures % If computeDiagFeatures is true.
    boxString = 'full'; % This is required for proper comparison.
end

% SETTING UP userSetMinVal
if ~isempty(range)
    userSetMinVal = range(1);
    if userSetMinVal == -Inf
        userSetMinVal = []; % In case no re-seg range is defined for the FBS algorithm, the minimum value of ROI will be used (not recommended).
    end
else
    userSetMinVal = []; % In case no re-seg range is defined for the FBS algorithm, the minimum value of ROI will be used (not recommended).
end

% FILTERS INITIALIZATION
if isfield(imParamScan,'filter')
    filter = true;
    IHfilter = imParamScan.filter.discretisation.IH;
    IVHfilter = imParamScan.filter.discretisation.IVH;
    algoFilter = imParamScan.filter.discretisation.texture.type;
    grayLevelsFilter = imParamScan.filter.discretisation.texture.val;
    nAlgoFilter = numel(algoFilter);
    nGlFilter = numel(grayLevelsFilter{1});
    nExpFilter = nScale*nAlgoFilter*nGlFilter;
    intensityFilter = imParamScan.filter.intensity;
    filtersType = imParamScan.filter.ToCompute;
    nFilters = numel(filtersType);
    for f = 1:nFilters
        if ~isempty(strfind(filtersType{f},'wavelet'))
            ind = strfind(filtersType{f},'_');
            waveletName = filtersType{f}(ind+1:end);
            waveletName = replaceCharacter(waveletName,'.','dot');
            waveletType = {'LLL','LLH','LHL','LHH','HLL','HLH','HHL','HHH'};
            nWav = numel(waveletType);
            for w = 1:nWav
                radiomics.([waveletType{w},'_',waveletName]) = struct;
            end
        else
            radiomics.(filtersType{f}) = struct;
        end
    end
else
    filter = false;
end


%%%%%%%%%%%%%%%%%%%%%%% COMPUTATION OF NON-TEXTURE FEATURES %%%%%%%%%%%%%%%%%%%%%%%
try
    tic, fprintf(['--> Non-texture features: pre-processing (interp + reSeg) for "Scale=',num2str(scaleNonText(1)),'": '])
    scaleName = num2str(scaleNonText(1)); scaleName = replaceCharacter(scaleName,'.','dot'); % Always isotropic resampling, so the first entry is ok.
    scaleName = ['scale',scaleName];
    % STEP 1: INTERPOLATION
    if computeDiagFeatures, type = 'initial';
        [diag] = getDiagFeatures(volObjInit,roiObjInit,roiObjInit,type);
%         radiomics.image.diag.(['scale',num2str(scaleNonText(1))]) = diag;
%         radiomics.image.diag.(['scale',strrep(num2str(scaleNonText(1)),'.','')]) = diag;
        radiomics.image.diag.(scaleName) = diag;
    end
    boxElements.boxString = boxString;
    boxElements.roiObj = roiObjInit;
    [volObj] = interpVolume(volObjInit,scaleNonText,volInterp,glRound,'image',boxElements);
    [roiObj_Morph] = interpVolume(roiObjInit,scaleNonText,roiInterp,roiPV,'roi',boxElements);
    if computeDiagFeatures, type = 'interp'; [diag] = getDiagFeatures(volObj,roiObj_Morph,roiObj_Morph,type);
%         [radiomics.image.diag.(['scale',num2str(scaleNonText(1))])] = concatenateStruct(radiomics.image.diag.(['scale',num2str(scaleNonText(1))]),diag);
        [radiomics.image.diag.(scaleName)] = concatenateStruct(radiomics.image.diag.(scaleName),diag);
    end

    % STEP 2: RE-SEGMENTATION
    roiObj_Int = roiObj_Morph; % Now is the time to create the intensity mask
    roiObj_Int.data = rangeReSeg(volObj.data,roiObj_Int.data,range) & outlierReSeg(volObj.data,roiObj_Int.data,outliers); % TAKING THE INTERSECTION OF THE TWO RE-SEGMENTATION PROCESSES
    if computeDiagFeatures, type = 'reSeg';
        [diag] = getDiagFeatures(volObj,roiObj_Int,roiObj_Morph,type);
%         [radiomics.image.diag.(['scale',num2str(scaleNonText(1))])] = concatenateStruct(radiomics.image.diag.(['scale',num2str(scaleNonText(1))]),diag);
        [radiomics.image.diag.(scaleName)] = concatenateStruct(radiomics.image.diag.(scaleName),diag);
    end
    toc
    
    % STEP 3: COMPUTE ALL NON-TEXTURE FEATURES IN IMAGE SPACE
    tic, fprintf('--> Computation of non-texture features in image space: ')
    [imageStruct] = computeNonTextureFeatures(volObj,roiObj_Int,roiObj_Morph,scaleNonText,intensity,range,userSetMinVal,IH,IVH,is3D);
    [radiomics.image] = concatenateStruct(radiomics.image,imageStruct);
    toc
    
    % STEP 4: COMPUTE ALL NON-TEXTURE FEATURES IN ALL FILTERED SPACES
    if filter
        for f = 1:nFilters
            tic, fprintf('--> Computation of non-texture features in %s space: ',filtersType{f})
            [filterStruct] = computeNonTextureFeatures(volObj,roiObj_Int,roiObj_Morph,scaleNonText,intensityFilter,[],[],IHfilter,IVHfilter,filtersType{f});
            if ~isempty(strfind(filtersType{f},'wavelet'))
                for w = 1:nWav
                    radiomics.([waveletType{w},'_',waveletName]) = concatenateStruct(radiomics.([waveletType{w},'_',waveletName]),filterStruct.([waveletType{w},'_',waveletName]));
                end
            else
                radiomics.(filtersType{f}) = concatenateStruct(radiomics.(filtersType{f}),filterStruct);
            end
            toc
        end
    end
    
catch ME
    disp(ME)
    fprintf('PROBLEM WITH PRE-PROCESSING OF NON-TEXTURE FEATURES')
    radiomics.image.(['scale',replaceCharacter(num2str(scaleNonText(1)),'.','dot')]) = 'ERROR_PROCESSING';
end
% -------------------------------------------------------------------------



%%%%%%%%%%%%%%%%%%%%%%% COMPUTATION OF TEXTURE FEATURES %%%%%%%%%%%%%%%%%%%%%%%
nameTextTypes = {'glcm_3Dmrg','glrlm_3Dmrg','glszm_3D','gldzm_3D','ngtdm_3D','ngldm_3D'};
nTextTypes = numel(nameTextTypes);
for t = 1:nTextTypes
    radiomics.image.texture.(nameTextTypes{t}) = struct;
end
if filter
    for f = 1:nFilters
        if ~isempty(strfind(filtersType{f},'wavelet'))
            for w = 1:nWav
                for t = 1:nTextTypes
                    radiomics.([waveletType{w},'_',waveletName]).texture.(nameTextTypes{t}) = struct;
                end                
            end
        else
            for t = 1:nTextTypes
                radiomics.(filtersType{f}).texture.(nameTextTypes{t}) = struct;
            end
        end
    end
end
countText = 0; countFilt = 0;
for s = 1:nScale
    try
        tic, fprintf(['--> Texture features: pre-processing (interp + reSeg) for "Scale=',num2str(scaleText{s}(1)),'": '])
        % STEP 1: INTERPOLATION
        boxElements.boxString = boxString; boxElements.roiObj = roiObjInit;
        [volObj] = interpVolume(volObjInit,scaleText{s},volInterp,glRound,'image',boxElements);
        [roiObj_Morph] = interpVolume(roiObjInit,scaleText{s},roiInterp,roiPV,'roi',boxElements);

        % STEP 2: RE-SEGMENTATION
        roiObj_Int = roiObj_Morph; % Now is the time to create the intensity mask
        roiObj_Int.data = rangeReSeg(volObj.data,roiObj_Int.data,range) & outlierReSeg(volObj.data,roiObj_Int.data,outliers); % TAKING THE INTERSECTION OF THE TWO RE-SEGMENTATION PROCESSES
        toc
        
        % STEP 3: COMPUTE ALL TEXTURE FEATURES IN IMAGE SPACE
        for a = 1:nAlgo
            for n = 1:nGl
                countText = countText + 1;
                tic, fprintf(['--> Computation of texture features in image space for "Scale=',num2str(scaleText{s}(1)),'", "Algo=',algo{a},'", "GL=',num2str(grayLevels{a}(n)),'" (',num2str(countText),'/',num2str(nExp),'): '])
                [imageStruct] = computeTextureFeatures(volObj,roiObj_Int,roiObj_Morph,scaleText{s},algo{a},grayLevels{a}(n),userSetMinVal,distCorrection);
                for t = 1:nTextTypes
                    [radiomics.image.texture.(nameTextTypes{t})] = concatenateStruct(radiomics.image.texture.(nameTextTypes{t}),imageStruct.(nameTextTypes{t}));
                end
                toc
            end
        end
        
        % STEP 4: COMPUTE ALL TEXTURE FEATURES IN ALL FILTERED SPACES
        if filter
            for f = 1:nFilters
                for a = 1:nAlgoFilter
                    for n = 1:nGlFilter
                        countFilt = countFilt + 1;
                        tic, fprintf(['--> Computation of texture features in ',filtersType{f},' space for "Scale=',num2str(scaleText{s}(1)),'", "Algo=',algoFilter{a},'", "GL=',num2str(grayLevelsFilter{a}(n)),'" (',num2str(countFilt),'/',num2str(nExpFilter),'): '])
                        [filterStruct] = computeTextureFeatures(volObj,roiObj_Int,roiObj_Morph,scaleText{s},algoFilter{a},grayLevelsFilter{a}(n),[],distCorrection,filtersType{f});
                        if ~isempty(strfind(filtersType{f},'wavelet'))
                            for w = 1:nWav
                                for t = 1:nTextTypes
                                    radiomics.([waveletType{w},'_',waveletName]).texture.(nameTextTypes{t}) = concatenateStruct(radiomics.([waveletType{w},'_',waveletName]).texture.(nameTextTypes{t}),filterStruct.([waveletType{w},'_',waveletName]).(nameTextTypes{t}));
                                end
                            end
                        else
                            for t = 1:nTextTypes
                                radiomics.(filtersType{f}).texture.(nameTextTypes{t}) = concatenateStruct(radiomics.(filtersType{f}).texture.(nameTextTypes{t}),filterStruct.(nameTextTypes{t}));
                            end
                        end
                        toc
                    end
                end
            end
        end
        
    catch 
        radiomics.image.(['scale',replaceCharacter(num2str(scaleText{s}(1)),'.','dot')]) = 'ERROR_PROCESSING';
    end
end
% -------------------------------------------------------------------------

radiomics.imParam = imParamScan;
end