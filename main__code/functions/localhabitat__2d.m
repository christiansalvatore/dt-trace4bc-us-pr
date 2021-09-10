function [habitat, labels] = localhabitat__2d(volume, mask, scantype,...
    pixel__w, slice__s, input__report_drive)
    
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
        % Step
        step = 1;
    elseif contains(scantype,'CT')
        dim = 5;
        volume = round(volume);
        % Step
        step = 1;
    elseif contains(scantype,'MAM')
        dim = 7;
        volume = round(volume);
        % Step
        step = 1;
    elseif contains(scantype,'US')
        dim = 7;
        volume = round(volume);
        % Step
        step = 1;
    elseif contains(scantype,'RX')
        dim = 7;
        volume = round(volume);
        % Step
        step = 1; 
    end
    central__dim = floor(dim/2);
    
    
    if step > dim
        step = dim;
    end
    if mod(step, 2)
        step = step - 1;
    end
    if step == 0
        step = 1;
    end
    
    % Masking volume
    
    
    % Adding a 4-slices bounding volume (zeros) around the original volume
    % (in order to perform local habitat extraction also in the external
    % slices)
    extended__volume = zeros(size(volume,1) + (dim-1), size(volume,2) + ...
        (dim-1));
    if contains(scantype,'MAM')
        % extended__volume(extended__volume==0)=-1001;
    end
    extended__volume(1+floor(dim/2):end-floor(dim/2), ...
        1+floor(dim/2):end-floor(dim/2)) = volume;
    volume = extended__volume;

    % Do the same for the mask
    extended__mask = zeros(size(mask,1) + (dim-1), size(mask,2) + ...
        (dim-1));
    extended__mask(1+floor(dim/2):end-floor(dim/2), ...
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
%         disp([num2str(i) '/' num2str(size(volume,1) - dim)]);
        j = 1;
        while j <= size(volume,2)-dim
%         for j = 1:step:size(volume,2)-dim
            if mask(i+central__dim, j+central__dim) == 1
                temp__mask = zeros(size(mask));
                temp__mask(i:i+dim-1, j:j+dim-1) = 1;
                temp__mask(mask == 0) = 0;
                new_mask = zeros(dim, dim);
                new_mask(:,:) = temp__mask(i:i+dim-1, j:j+dim-1);
                new_vol = zeros(dim, dim);
                new_vol(:,:) = volume(i:i+dim-1, j:j+dim-1);
                if sum(sum(new_mask)) > 2
                    isthemask = unique(new_mask);
                    if sum(size(isthemask))==2
                        step = 4;
                    else
                        step = 1;
                    end
                    try
                        feat = computing__haralick(new_vol, new_mask,...
                            scantype, pixel__w, slice__s, ...
                            input__report_drive);
                    catch
                        feat(1:4) = NaN;
                    end
                    
                    if step > 1
                        s = floor(step / 2);
                        i__1 = i + central__dim - s;
                        i__2 = i + central__dim + s;
                        j__1 = j + central__dim - s;
                        j__2 = j + central__dim + s;
                        habitat.energy(i__1 : i__2, j__1 : j__2) ...
                            = feat(1);
                        habitat.contrast(i__1 : i__2, j__1 : j__2) ...
                            = feat(2);
                        habitat.entropy(i__1 : i__2, j__1 : j__2) ...
                            = feat(3);
                        habitat.homogeneity(i__1 : i__2, j__1 : j__2) ...
                            = feat(4);  
                    else
                        habitat.energy(i+central__dim, j+central__dim) ...
                            = feat(1);
                        habitat.contrast(i+central__dim, j+central__dim) ...
                            = feat(2);
                        habitat.entropy(i+central__dim, j+central__dim) ...
                            = feat(3);
                        habitat.homogeneity(i+central__dim, j+central__dim) ...
                            = feat(4);                          
                    end
                end
            end
            j = j + step;
        end
    end
    
    % Applying mask back again
    if step > 1
        habitat.energy(isnan(mask)) = nan;
        habitat.contrast(isnan(mask)) = nan;
        habitat.entropy(isnan(mask)) = nan;
        habitat.homogeneity(isnan(mask)) = nan;
    end
    
    % Cutting the external 2-slices volumes added at the beginning
    habitat.energy = habitat.energy(1+floor(dim/2):end-floor(dim/2),...
        1+floor(dim/2):end-floor(dim/2));
    habitat.contrast = habitat.contrast(1+floor(dim/2):end-floor(dim/2),...
        1+floor(dim/2):end-floor(dim/2));
    habitat.entropy = habitat.entropy(1+floor(dim/2):end-floor(dim/2),...
        1+floor(dim/2):end-floor(dim/2));
    habitat.homogeneity = habitat.homogeneity(1+floor(dim/2):end-floor(dim/2),...
        1+floor(dim/2):end-floor(dim/2));

    % Final assignations
    labels = {'Energy', 'Contrast', 'Entropy', 'Homogeneity'};
 
end

function feat = computing__haralick(volume, mask, scantype,...
    pixel__w, slice__s, input__report_drive)
    
    % Prepare parameters
%     if strcmp(scantype,'PET')
%         grey__levels = 64;
%     elseif contains(scantype,'MAM') 
%         grey__levels = 64;
%     elseif contains(scantype,'US') 
%         grey__levels = 64;
%     elseif contains(scantype,'RX') 
    grey__levels = 64; 
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
%     elseif strcmp(scantype,'CT')
%         min_hu = min(min(volume));
%         if min_hu < -1000
%             min_hu = -1000;
%         end
%         max_hu = max(max(volume));
%         if max_hu > 400
%             max_hu = 400;
%         end
%         range = max_hu - min_hu + 1;
%         grey__levels = ceil(range/25);        
%     end
    
    % Define normalization parameters
    energy__norm = 1;
    homogeneity__norm = 1;
    entropy__norm = log2(grey__levels^2);
    contrast__norm = (grey__levels - 1)^2;
    habitat_path = strcat(input__report_drive, '\temp_habitat');
    
   rad_settings = load(fullfile(input.save, 'src__trace4bc','main__code','tool_radfeatures','default_settings',filename_set), 'rad_settings');
    rad_settings = rad_settings.rad_settings;
    
    
    input.volume = volume;
    input.pix = [pixel__w pixel__w slice__s];
    input.mask = mask;

    input.img__type = scantype;
    input.rad_settings = rad_settings;
    GLCM__features = radiomic_features_extraction_habitat(input);
    
%     % Call RaCat
%     [GLCM__features] = main__Radiomics_RaCat_habitat(habitat_path, ...
%         scantype, '2d');

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
    
    for i = 1:length(GLCM__features)
        if GLCM__features(i) > 1
            GLCM__features(i) = 1;
        end
    end
    
    try rmdir(habitat_path,'s'); end
    
    % GLCM-feature labels
    GLCM__labels = {'Energy', 'Contrast', 'Entropy', 'Homogeneity'};
    
    % Final assignations
    feat = GLCM__features;

end

function output = t4bc__logtransform__alg(input)
    alpha = 1e-6;
    
    output = (log(input + alpha) - log(alpha)) / ...
        (log(1 + alpha) - log(alpha));
end
