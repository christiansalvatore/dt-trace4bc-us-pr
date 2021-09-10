function [habitat, labels] = local__habitat(volume, mask, scantype,...
    pixel__w, slice__s,input__report_drive)
    
    %
    % This function computes features for local single-lesion
    % differences (Habitat)
    %
    % "img" should be a masked volume (PET or CT)
    %
    
    % Define the dimensions of an isotropic sliding window to calculate
    % local features
    
    if contains(scantype,'PET')
        dim = 3;
        step = 1;
%         volume(mask==0)=0;
    elseif contains(scantype,'CT')
        dim = 5;
        volume=round(volume);
        step = 3;
%         volume(mask==0)=-1001;
    elseif contains(scantype,'CYBERKNIFE')
        dim = 9;
        j=1;
        for i=1:size(mask,3)
            if max(max(mask(:,:,i)))>0
                fette(j)=i;
                j=j+1;
            end
        end
        volume_temp=volume;
        mask_temp=mask;
        if fette(1)>3 && fette(end)<size(mask,3)-2
            gap=3;
        else
            dist(1,1)=fette(1);
            dist(1,2)=size(mask,3)-fette(end);
            gap=min(dist);
        end
%         volume=zeros(size(volume_temp,1),size(volume_temp,2),length(fette)+(gap*2));
%         mask=volume;
        volume=volume_temp(:,:,(fette(1)-gap):(fette(end)+gap));
        mask=mask_temp(:,:,(fette(1)-gap):(fette(end)+gap));
        habitat.gap=gap;
        habitat.fetta1=fette(1);
        habitat.fetta2=fette(end);
        step = 5;%%%%%
    end
    central__dim = floor(dim/2);
%     step = 3;
    stepz = 1;
    
    
    % Masking volume
    
    
    % Adding a bounding 2-slices volume (zeros) around the original volume (in order to perform local habitat extraction also in the external slices)
    extended__volume = zeros(size(volume,1) + (dim-1), size(volume,2) +...
        (dim-1), size(volume,3) + (dim-1));
    if contains(scantype,'CT')
        extended__volume(extended__volume==0)=-1001;
    end
    extended__volume(1+floor(dim/2):end-floor(dim/2),...
        1+floor(dim/2):end-floor(dim/2),...
        1+floor(dim/2):end-floor(dim/2)) = volume;
    volume = extended__volume;

    % Do the same for the mask
    extended__mask = zeros(size(mask,1) + (dim-1), size(mask,2) +...
        (dim-1), size(mask,3) + (dim-1));
    extended__mask(1+floor(dim/2):end-floor(dim/2),...
        1+floor(dim/2):end-floor(dim/2),...
        1+floor(dim/2):end-floor(dim/2)) = mask;
    mask = extended__mask;   
    
    % Prepare habitat matrix
    habitat.energy = nan(size(mask));
    habitat.contrast = nan(size(mask));
    habitat.entropy = nan(size(mask));
    habitat.homogeneity = nan(size(mask));
        
    % Compute local GLCM (Haralick) features using a sliding-window
    % approach
    for i = 1:step:size(volume,1)-dim
%         disp([num2str(i) '/' num2str(size(volume,1)-dim)]);
        for j = 1:step:size(volume,2)-dim
            for k = 1:stepz:size(volume,3)-dim
                if mask(i+central__dim, j+central__dim,...
                    k+central__dim) > 0
                    temp__mask = zeros(size(mask));
                    temp__mask(i:i+dim-1, j:j+dim-1, k:k+dim-1) = 1;
                    temp__mask(mask == 0) = 0;
					new_mask=zeros(dim, dim, dim);
					new_mask(:,:,:)=temp__mask(i:i+dim-1, j:j+dim-1, k:k+dim-1);
					new_vol=zeros(dim, dim, dim);
					new_vol(:,:,:)=volume(i:i+dim-1, j:j+dim-1, k:k+dim-1);
                    if sum(sum(sum(new_mask))) > 2
                        try
                            feat = computing__haralick(new_vol, new_mask,...
                                scantype, pixel__w, slice__s,input__report_drive);
                        catch
                            feat(1:4) = NaN;
                        end
                        
                        if step > 1
                            s = floor(step / 2);
                            i__1 = i + central__dim - s;
                            i__2 = i + central__dim + s;
                            j__1 = j + central__dim - s;
                            j__2 = j + central__dim + s;
                            
                            habitat.energy(i__1 : i__2, j__1 : j__2, k+central__dim) ...
                                = feat(1);
                            habitat.contrast(i__1 : i__2, j__1 : j__2, k+central__dim) ...
                                = feat(2);
                            habitat.entropy(i__1 : i__2, j__1 : j__2, k+central__dim) ...
                                = feat(3);
                            habitat.homogeneity(i__1 : i__2, j__1 : j__2, k+central__dim) ...
                                = feat(4);  
                        else
                            habitat.energy(i+central__dim, j+central__dim, k+central__dim) ...
                                = feat(1);
                            habitat.contrast(i+central__dim, j+central__dim, k+central__dim) ...
                                = feat(2);
                            habitat.entropy(i+central__dim, j+central__dim, k+central__dim) ...
                                = feat(3);
                            habitat.homogeneity(i+central__dim, j+central__dim, k+central__dim) ...
                                = feat(4);                          
                        end                    
                    end
                end
            end
        end
    end
    
    % CHS
%         habitat.energy = habitat.energy ./ max(max(max(habitat.energy)));
%         habitat.contrast = habitat.contrast ./ max(max(max(habitat.contrast)));
%         habitat.entropy = habitat.entropy ./ max(max(max(habitat.entropy)));
%         habitat.homogeneity = habitat.homogeneity ./ max(max(max(habitat.homogeneity)));
    % SUBSTITUTE FOR
    % LICENSE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    % GRADIENTE
%         gradient = nan(size(volume));
%         gradient__dir = nan(size(volume));
%         for ii = 1:size(volume,3)
%              [gradient(:,:,ii), gradient__dir(:,:,ii)] = imgradient(squeeze(volume(:,:,ii)));        
%         end
%         % gradient(mask == 0) = NaN;
%         % gradient__dir(mask == 0) = NaN;
%         gradient(mask == 0) = NaN;
%         gradient__dir(mask == 0) = NaN; 

%         habitat.energy = gradient ./ max(max(max(gradient)));
%         habitat.contrast = (gradient__dir + 180) / 360;

        % habitat.energy(habitat.energy == 0) = 0.01;
        % habitat.contrast(habitat.contrast == 0) = 0.01;
    
    % Cutting the external 2-slices volumes added at the beginning
    habitat.energy = habitat.energy(1+floor(dim/2):end-floor(dim/2),...
        1+floor(dim/2):end-floor(dim/2),...
        1+floor(dim/2):end-floor(dim/2));
    habitat.contrast = habitat.contrast(1+floor(dim/2):end-floor(dim/2),...
        1+floor(dim/2):end-floor(dim/2),...
        1+floor(dim/2):end-floor(dim/2));
    habitat.entropy = habitat.entropy(1+floor(dim/2):end-floor(dim/2),...
        1+floor(dim/2):end-floor(dim/2),...
        1+floor(dim/2):end-floor(dim/2));
    habitat.homogeneity = habitat.homogeneity(1+floor(dim/2):end-floor(dim/2),...
        1+floor(dim/2):end-floor(dim/2),...
        1+floor(dim/2):end-floor(dim/2));

    % Final assignations
    labels = {'Energy', 'Contrast', 'Entropy', 'Homogeneity'};
    
end

function feat = computing__haralick(volume, mask, scantype,...
    pixel__w, slice__s, input__report_drive)

        grey__levels = 64;

  
    energy__norm = 1;
    homogeneity__norm = 1;
    entropy__norm = log2(grey__levels^2);
    contrast__norm = (grey__levels - 1)^2;



    
    p = mfilename('fullpath');
    endout = regexp(p, filesep, 'split');
    for i = 1:size(endout,2)-4
        if i == 1
            input.save = endout{1,1};
        else
            input.save = strcat(input.save, '/' ,endout{1,i});
        end  
    end
    input.is3D = 1;
    if strcmpi(scantype,'ct')
        filename_set = 'CT_3D_defSetting_1mm.mat';
    elseif strcmpi(scantype,'pet')
        filename_set = 'PET_3D_defSetting_maxSize.mat';
    elseif strcmpi(scantype,'T2') || strcmpi(scantype,'adc')...
            || strcmpi(scantype,'mri')
        filename_set = 'MRI_3D_defSetting_maxSize.mat';
    else
        filename_set = 'image_2D_defSetting_pixSize.mat';
        
        input.is3D = 0;
    end

    rad_settings = load(fullfile(input.save, 'src__trace4bc','main__code','tool_radfeatures','default_settings',filename_set), 'rad_settings');
    rad_settings = rad_settings.rad_settings;
    
    
    input.volume = volume;
    input.pix = [pixel__w pixel__w slice__s];
    input.mask = mask;

    input.img__type = scantype;
    input.rad_settings = rad_settings;
    GLCM__features = radiomic_features_extraction_habitat(input);
    
%     [total_feat, total_feat_values] = feature_extraction_from_segmentation(vol,mask,app.imtype,rad_settings);




%     [GLCM__features] = main__Radiomics_RaCat_habitat(habitat_path, ...
%         scantype);
%     try rmdir(habitat_path,'s'); end
    %save important info
    %delete everything
    
    
%     scale = max(pixel__w, slice__s);
%     
%     % Prepare volume
%     [ROIonlyM,levelsM,~,~] = prepareVolume(volume, mask, scantype,...
%         pixel__w, slice__s, 1, scale, 'Matrix', 'Uniform', grey__levels);
    
    % Compute GLCM matrix
%     GLCM__matrix = getGLCM(ROIonlyM,levelsM);
%     
%     % Get GLCM features
%     GLCM__features = getGLCMtextures(GLCM__matrix);
%     
%     % We are interested in Energy, Entropy, Homogeneity and Contrast
%     % Cut the unnecessary features
    GLCM__features = [(GLCM__features.Energy)/energy__norm...
        (GLCM__features.Contrast)/contrast__norm...
        (GLCM__features.Entropy)/entropy__norm...
        (GLCM__features.Homogeneity)/homogeneity__norm];
    
    % Apply log transformation to "expand" the scale for visualization
    % purposes (only for Energy and Contrast)
    % Energy
    GLCM__features(1) = t4bc__logtransform__alg(GLCM__features(1));
    % Contrast
    GLCM__features(2) = t4bc__logtransform__alg(GLCM__features(2));
    for i=1:length(GLCM__features)
        if GLCM__features(i)>1
            GLCM__features(i)=1;
        end
    end
    
    try rmdir(habitat_path,'s'); end
    
    % GLCM-feature labels
%     GLCM__labels = {'Energy', 'Contrast', 'Entropy', 'Homogeneity'};
    
    % Final assignations
    feat = GLCM__features;
%     lab = GLCM__labels;

end

function feat = computing__haralick_ORIGINAL(volume, mask, scantype,...
    pixel__w, slice__s, ~)
    
    % Prepare parameters
    if strcmp(scantype,'PET')
        scantype = 'PETscan';
        grey__levels = 64;
    elseif strcmp(scantype,'CT')
        scantype = 'Other';
        min_hu=min(min(min(volume)));
        if min_hu<-1000
            min_hu=-1000;
        end
        max_hu=max(max(max(volume)));
        if max_hu>400
            max_hu=400;
        end
        range=max_hu-min_hu+1;
        grey__levels = ceil(range/25);
    end
    
    % Define # grey levels
    
    
    % Define normalization parameters
    energy__norm = 1;
    homogeneity__norm = 1;
    entropy__norm = 1;
    contrast__norm = 1;
%     entropy__norm = log2(grey__levels^2);   CHS
%     contrast__norm = (grey__levels - 1)^2;     CHS

    scale = max(pixel__w, slice__s);
    
    % Prepare volume
    [ROIonlyM,levelsM,~,~] = prepareVolume(volume, mask, scantype,...
        pixel__w, slice__s, 1, scale, 'Matrix', 'Uniform', grey__levels);
    
    % Compute GLCM matrix
    GLCM__matrix = getGLCM(ROIonlyM,levelsM);
    
    % Get GLCM features
    GLCM__features = getGLCMtextures(GLCM__matrix);
    
    % We are interested in Energy, Entropy, Homogeneity and Contrast
    % Cut the unnecessary features
    GLCM__features = [(GLCM__features.Energy)/energy__norm...
        (GLCM__features.Contrast)/contrast__norm...
        (GLCM__features.Entropy)/entropy__norm...
        (GLCM__features.Homogeneity)/homogeneity__norm];
    
    % Apply log transformation to "expand" the scale for visualization
    % purposes (only for Energy and Contrast)
    % Energy
    GLCM__features(1) = t4bc__logtransform__alg(GLCM__features(1));
    % Contrast
    GLCM__features(2) = t4bc__logtransform__alg(GLCM__features(2));

    % GLCM-feature labels
    GLCM__labels = {'Energy', 'Contrast', 'Entropy', 'Homogeneity'};
    
    % Final assignations
    feat = GLCM__features;
    lab = GLCM__labels;

end

function output = t4bc__logtransform__alg(input)
    alpha = 1e-6;
    
    output = (log(input + alpha) - log(alpha)) / ...
        (log(1 + alpha) - log(alpha));
end
