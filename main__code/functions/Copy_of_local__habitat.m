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
    elseif contains(scantype,'CT')
        dim = 5;
    end
    central__dim = floor(dim/2);
    step = 1;    
    
    % Masking volume
    volume = volume.*mask;
    
    % Adding a bounding 2-slices volume (zeros) around the original volume (in order to perform local habitat extraction also in the external slices)
    extended__volume = zeros(size(volume,1) + (dim-1), size(volume,2) +...
        (dim-1), size(volume,3) + (dim-1));
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
        disp([num2str(i) '/' num2str(size(volume,1)-dim)]);
        for j = 1:step:size(volume,2)-dim
            for k = 1:step:size(volume,3)-dim
                if mask(i+central__dim, j+central__dim,...
                    k+central__dim) == 1
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
                        habitat.energy(i+central__dim, j+central__dim,...
                            k+central__dim) = feat(1);
                        habitat.contrast(i+central__dim, j+central__dim,...
                            k+central__dim) = feat(2);
                        habitat.entropy(i+central__dim, j+central__dim,...
                            k+central__dim) = feat(3);
                        habitat.homogeneity(i+central__dim,...
                            j+central__dim, k+central__dim) = feat(4);                     
                    end
                end
            end
        end
    end
    
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

function feat = computing__haralick_new(volume, mask, scantype,...
    pixel__w, slice__s, input__report_drive)
    
    % Prepare parameters
    if strcmp(scantype,'PET')
%         scantype = 'PETscan';
        grey__levels = 64;
    elseif strcmp(scantype,'CT')
%         scantype = 'Other';
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
    entropy__norm = log2(grey__levels^2);
    contrast__norm = (grey__levels - 1)^2;
    habitat_path=strcat(input__report_drive,'\temp_habitat');
    %create temp folder
    mkdir__ifnotexist(habitat_path);
    %save nifti
    newdirectoryRisultati=strcat(habitat_path,'\vol_hab.nii');
    W=size(volume,1);
    H=size(volume,2);
    nii = make_nii(volume, [pixel__w pixel__w slice__s], [W/2 H/2 size(volume,3)/2], 64);
    save_nii(nii, newdirectoryRisultati)
    newdirectoryRisultati=strcat(habitat_path,'\mask_hab.nii');
    W=size(volume,1);
    H=size(volume,2);
    nii = make_nii(mask, [pixel__w pixel__w slice__s], [W/2 H/2 size(volume,3)/2], 64);
    save_nii(nii, newdirectoryRisultati)
    %call racat code
    [GLCM__features]=main__Radiomics_RaCat_habitat(habitat_path, scantype);
    try rmdir(habitat_path,'s'); end
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

    % GLCM-feature labels
    GLCM__labels = {'Energy', 'Contrast', 'Entropy', 'Homogeneity'};
    
    % Final assignations
    feat = GLCM__features;
%     lab = GLCM__labels;

end

function feat = computing__haralick(volume, mask, scantype,...
    pixel__w, slice__s, input__report_drive)
    
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
    entropy__norm = log2(grey__levels^2);
    contrast__norm = (grey__levels - 1)^2;

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
