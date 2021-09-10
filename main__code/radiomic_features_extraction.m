function output = radiomic_features_extraction(input)

volume = input.volume;
mask = input.mask;
pix = input.pix;
img__type = input.img__type;
is3D = input.is3D;

if input.rad_settings.out_pix_dim == 0
    if is3D
        input.rad_settings.out_pix_dim = max(pix);
    else
        input.rad_settings.out_pix_dim = max(pix(1:2));
    end
end

rad_settings = input.rad_settings;

volObjInit.data = squeeze(volume);
roiObjInit.data = squeeze(mask);
if ~is3D
    try volObjInit.data=rgb2gray(volObjInit.data);
        roiObjInit.data=rgb2gray(roiObjInit.data);
    catch
    end
%     if max(max(volObjInit.data)) == 255
%         try volObjInit.data = uint8(volObjInit.data);
%         catch
%         end
%     end
end
volObjInit.data = single(volObjInit.data);
roiObjInit.data = single(roiObjInit.data);
isthemask = unique(roiObjInit.data);
if sum(size(isthemask))==2
    output = [];
    return
end

[volObjInit.data, roiObjInit.data] = crop_to_mask(volObjInit, roiObjInit, pix, is3D);

if ~is3D || numel(size(volObjInit.data)) == 2
    temp = cat(3, volObjInit.data, volObjInit.data);
    volObjInit.data = temp;

    temp = cat(3, roiObjInit.data, roiObjInit.data);
    roiObjInit.data = temp;
    
    volObjInit.spatialRef = imref3d(size(volObjInit.data),pix(1),pix(2),rad_settings.out_pix_dim./2);
    roiObjInit.spatialRef = imref3d(size(volObjInit.data),pix(1),pix(2),rad_settings.out_pix_dim./2);
elseif is3D || numel(size(volObjInit.data)) == 3
    volObjInit.spatialRef = imref3d(size(volObjInit.data),pix(1),pix(2),pix(3));
    roiObjInit.spatialRef = imref3d(size(volObjInit.data),pix(1),pix(2),pix(3));
end

imParamScan = Init_param_per_scan(rad_settings);
% imParamScan = Init_param_per_scan(header.dime.pixdim(2),set_to_1);

% Extract radiomic features
boxString = 'full';

if is3D
    morpho_struct = [];
else
    morpho_struct = morph2Dfeatures(volume,mask,rad_settings.out_pix_dim);
end

[radiomics,scaleName] = computeRadiomics(volObjInit,roiObjInit,imParamScan,boxString,is3D);
[radiomics_out,~] = structure2array(radiomics,scaleName,is3D);

racat__features = structure_radiomics(morpho_struct,radiomics_out,img__type,is3D,rad_settings);
%             racat__features = racat_simplefeatextraction(vol, mask,...
%                 img__type, patient__root);
output = racat__features;


% current__features = double((cell2mat(racat__features(:,11)))');
% racat__featspecs = racat__features(:, [1:10 12]);



