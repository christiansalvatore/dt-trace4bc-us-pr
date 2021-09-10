function [habitat, volume_or, mask_or] = local__habitat_impfeat(subj_path,scantype,feat_name,feat_abbr)
    %volume, mask, scantype,pixel__w, slice__s,input__report_drive)
    
    lista_file=dir(fullfile(subj_path,'*.nii'));
    lista_names={lista_file.name};
    index_vol=find(contains(lista_names, 'vol','IgnoreCase',true));
    index_mask=find(contains(lista_names, 'mask','IgnoreCase',true));
    if length(index_vol)>1
        index_type=find(contains(lista_names, scantype,'IgnoreCase',true));
        index_vol=intersect(index_vol,index_type);
        index_mask=intersect(index_mask,index_type);
    end
    
    habitat.total_feat = racat_simplefeatextraction_habitat(fullfile(subj_path,lista_file(index_vol).name),...
        fullfile(subj_path,lista_file(index_mask).name),...
        scantype, subj_path, feat_name, feat_abbr);
    
    all_data_vol=load_nii(fullfile(subj_path,lista_file(index_vol).name));
    all_data_mask=load_nii(fullfile(subj_path,lista_file(index_mask).name));
    nonseg_vol=all_data_vol.img;
    data_type=class(nonseg_vol);
    dx_temp=all_data_vol.hdr.dime.pixdim;
    px(1,1:3)=dx_temp(2:4);
    
    if contains(scantype,'US')
        volume=nonseg_vol;
    else
        volume=zeros(size(nonseg_vol,2),size(nonseg_vol,1),size(nonseg_vol,3));
        for i=1:size(nonseg_vol,3)
            volume(:,:,i)=rot90(fliplr(nonseg_vol(:,:,i)),-1);
        end
    end
    
   
    nonseg_mask=all_data_mask.img;
    
    if contains(scantype,'US')
        mask=nonseg_mask;
    else
        mask=zeros(size(nonseg_mask,2),size(nonseg_mask,1),size(nonseg_mask,3));
        for i=1:size(nonseg_mask,3)
            mask(:,:,i)=rot90(fliplr(nonseg_mask(:,:,i)),-1);
        end
    end
    
    [increase.r1,increase.r2,increase.r3] = ind2sub(size(mask),find(mask>0));
    increase.min_r1=min(min(increase.r1));
    increase.max_r1=max(max(increase.r1));
    increase.min_r2=min(min(increase.r2));
    increase.max_r2=max(max(increase.r2));
    increase.min_r3=min(min(increase.r3));
    increase.max_r3=max(max(increase.r3));
    increase.range_r1=increase.max_r1-increase.min_r1+1;
    increase.range_r2=increase.max_r2-increase.min_r2+1;
    increase.range_r3=increase.max_r3-increase.min_r3+1;
    if increase.range_r1<50
        increase.margin_r1=5;
    else
        increase.margin_r1=round(increase.range_r1/10);
    end
    if increase.range_r2<50
        increase.margin_r2=5;
    else
        increase.margin_r2=round(increase.range_r2/10);
    end
    if size(mask,3)>1
        if increase.range_r3<20
            increase.margin_r3=2;
        else
            increase.margin_r3=round(increase.range_r3/10);
        end
    else
        increase.margin_r3=0;
    end
    increase.new_min_r1=increase.min_r1-increase.margin_r1;
    if increase.new_min_r1<=0
        increase.new_min_r1=1;
    end
    increase.new_min_r2=increase.min_r2-increase.margin_r2;
    if increase.new_min_r2<=0
        increase.new_min_r2=1;
    end
    increase.new_min_r3=increase.min_r3-increase.margin_r3;
    if increase.new_min_r3<=0
        increase.new_min_r3=1;
    end
    increase.new_max_r1=increase.max_r1+increase.margin_r1;
    if increase.new_max_r1>size(mask,1)
        increase.new_max_r1=size(mask,1);
    end
    increase.new_max_r2=increase.max_r2+increase.margin_r2;
    if increase.new_max_r2>size(mask,2)
        increase.new_max_r2=size(mask,2);
    end
    increase.new_max_r3=increase.max_r3+increase.margin_r3;
    if increase.new_max_r3>size(mask,3)
        increase.new_max_r3=size(mask,3);
    end
    new_v=volume(increase.new_min_r1:increase.new_max_r1,...
        increase.new_min_r2:increase.new_max_r2,...
        increase.new_min_r3:increase.new_max_r3);
    new_m=mask(increase.new_min_r1:increase.new_max_r1,...
        increase.new_min_r2:increase.new_max_r2,...
        increase.new_min_r3:increase.new_max_r3);
    volume=new_v;
    mask=new_m;

%     B = cast(A,'like',c)
    volume_or=volume;
    mask_or=mask;
    
    volume = cast(volume,data_type);
    mask = cast(mask,data_type);
    
    pixel__w=px(1,1);
    slice__s=px(1,3);
    if ~isempty(habitat.total_feat)
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
        elseif contains(scantype,'DWI') || contains(scantype,'ADC')
            dim = 3;
            step = 1;
        elseif contains(scantype,'T2') || contains(scantype,'MRI')
            dim = 9;
            step = 3;
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
            step = 3;%%%%%
        elseif contains(scantype,'MAM')
            dim = 7;
            volume = round(volume);
            % Step
            step = 3;
        elseif contains(scantype,'US')
            dim = 15;
            volume = round(volume);
            % Step
            step = 7;
        elseif contains(scantype,'RX')
            dim = 15;
            volume = round(volume);
            % Step
            step = 7; 
        end



        central__dim = floor(dim/2);
    %     step = 3;
        stepz = 1;


        % Masking volume


        % Adding a bounding 2-slices volume (zeros) around the original volume (in order to perform local habitat extraction also in the external slices)
        if size(volume,3)>1
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
        else
            extended__volume = zeros(size(volume,1) + (dim-1), size(volume,2) +...
                (dim-1));
            if contains(scantype,'CT')
                extended__volume(extended__volume==0)=-1001;
            end
            extended__volume(1+floor(dim/2):end-floor(dim/2),...
                1+floor(dim/2):end-floor(dim/2)) = volume;
            volume = extended__volume;

            % Do the same for the mask
            extended__mask = zeros(size(mask,1) + (dim-1), size(mask,2) +...
                (dim-1));
            extended__mask(1+floor(dim/2):end-floor(dim/2),...
                1+floor(dim/2):end-floor(dim/2)) = mask;
            mask = extended__mask;   

            % Prepare habitat matrix
            habitat.energy = nan(size(mask));
        end
    %     habitat.contrast = nan(size(mask));
    %     habitat.entropy = nan(size(mask));
    %     habitat.homogeneity = nan(size(mask));

        % Compute local GLCM (Haralick) features using a sliding-window
        % approach
        volume = cast(volume,data_type);
        mask = cast(mask,data_type);
        for i = 1:step:size(volume,1)-dim
    %         disp([num2str(i) '/' num2str(size(volume,1)-dim)]);
            for j = 1:step:size(volume,2)-dim
                if size(volume,3)>1
                    for k = 1:stepz:size(volume,3)-dim
                        if mask(i+central__dim, j+central__dim,...
                            k+central__dim) > 0
                            temp__mask = zeros(size(mask));
                            temp__mask(i:i+dim-1, j:j+dim-1, k:k+dim-1) = 1;
                            temp__mask(mask == 0) = 0;
                            new_mask=zeros(dim, dim, dim); 
                            new_mask(:,:,:)=temp__mask(i:i+dim-1, j:j+dim-1, k:k+dim-1);
                            new_mask = cast(new_mask,data_type);
                            new_vol=zeros(dim, dim, dim);
                            new_vol(:,:,:)=volume(i:i+dim-1, j:j+dim-1, k:k+dim-1);
                            new_vol = cast(new_vol,data_type);
                            if sum(sum(sum(new_mask))) > 2
                                try
                                    feat = computing__haralick_3D(new_vol, new_mask,...
                                        scantype, pixel__w, slice__s,...
                                        subj_path,feat_name,feat_abbr);
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
                                else
                                    habitat.energy(i+central__dim, j+central__dim, k+central__dim) ...
                                        = feat(1);                        
                                end                    
                            end
                        end
                    end
                else
                    if mask(i+central__dim, j+central__dim) == 1
                        temp__mask = zeros(size(mask));
                        temp__mask(i:i+dim-1, j:j+dim-1) = 1;
                        temp__mask(mask == 0) = 0;
                        new_mask = zeros(dim, dim);
                        new_mask(:,:) = temp__mask(i:i+dim-1, j:j+dim-1);
                        new_mask = cast(new_mask,data_type);
                        new_vol = zeros(dim, dim);
                        new_vol(:,:) = volume(i:i+dim-1, j:j+dim-1);
                        new_vol = cast(new_vol,data_type);
                        if sum(sum(new_mask)) > 2
                            try
                                feat = computing__haralick_2D(new_vol, new_mask,...
                                    scantype, pixel__w, slice__s, ...
                                    subj_path,feat_name,feat_abbr);
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
                            else
                                habitat.energy(i+central__dim, j+central__dim) ...
                                    = feat(1);                         
                            end
                        end
                    end



                end

            end
        end


        % Cutting the external 2-slices volumes added at the beginning
        if size(volume,3)>1
            habitat.energy = habitat.energy(1+floor(dim/2):end-floor(dim/2),...
                1+floor(dim/2):end-floor(dim/2),...
                1+floor(dim/2):end-floor(dim/2));
        else
            habitat.energy = habitat.energy(1+floor(dim/2):end-floor(dim/2),...
                1+floor(dim/2):end-floor(dim/2));
        end
        neg_values=find(habitat.energy<0);
        if ~isempty(neg_values)
            habitat.energy=(habitat.energy-nanmin(nanmin(nanmin(habitat.energy)))+0.0001);
        end
    else
        habitat.energy=[];
        
    end
end

function feat = computing__haralick_3D(volume, mask, scantype,...
    pixel__w, slice__s, subj_path,feat_name,feat_abbr)
    
%     % Prepare parameters
%     if strcmp(scantype,'CT')
% %         scantype = 'Other';
%         min_hu=min(min(min(volume)));
%         if min_hu<-1000
%             min_hu=-1000;
%         end
%         max_hu=max(max(max(volume)));
%         if max_hu>400
%             max_hu=400;
%         end
%         range=max_hu-min_hu+1;
%         grey__levels = ceil(range/25);
%     else%if strcmp(scantype,'PET') || strcmp(scantype,'CYBERKNIFE')
% %         scantype = 'PETscan';
%         grey__levels = 64;
%     end
    
    % Define normalization parameters
    energy__norm = 1;

    habitat_path=strcat(subj_path,'\temp_habitat');
    %create temp folder
    mkdir__ifnotexist(habitat_path);
    %save nifti
    newdirectoryRisultati = strcat(habitat_path,'\vol_hab.nii');
    W=size(volume,1);
    H=size(volume,2);
    nii = make_nii(volume, [pixel__w pixel__w slice__s], [W/2 H/2 size(volume,3)/2]);
    save_nii(nii, newdirectoryRisultati);

    newdirectoryRisultati = strcat(habitat_path,'\mask_hab.nii');
    W = size(volume,1);
    H = size(volume,2);
    nii = make_nii(mask, [pixel__w pixel__w slice__s], [W/2 H/2 size(volume,3)/2]);
    save_nii(nii, newdirectoryRisultati);

    [GLCM__features] = main__Radiomics_RaCat_habitat_impfeat(habitat_path, ...
        scantype,feat_name,feat_abbr);
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
    GLCM__features = (GLCM__features.Energy)/energy__norm;
    
%     % Apply log transformation to "expand" the scale for visualization
%     % purposes (only for Energy and Contrast)
%     % Energy
%     GLCM__features = t4bc__logtransform__alg(GLCM__features(1));
%     % Contrast
%     GLCM__features(2) = t4bc__logtransform__alg(GLCM__features(2));
%     for i=1:length(GLCM__features)
%         if GLCM__features>1
%             GLCM__features=1;
%         end
%     end
    
    try rmdir(habitat_path,'s');
    catch
    end
    
    % GLCM-feature labels
%     GLCM__labels = {'Energy', 'Contrast', 'Entropy', 'Homogeneity'};
    
    % Final assignations
    feat = GLCM__features;
%     lab = GLCM__labels;

end

function feat = computing__haralick_2D(volume, mask, scantype,...
    ~, ~, subj_path,feat_name,feat_abbr)
    
    % Prepare parameters
%     if strcmp(scantype,'PET')
%         grey__levels = 64;
%     elseif contains(scantype,'MAM') 
%         grey__levels = 64;
%     elseif contains(scantype,'US') 
%         grey__levels = 64;
%     elseif contains(scantype,'RX') 
%         grey__levels = 64; 
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

    habitat_path = strcat(subj_path, '\temp_habitat');
    
    % Create temp folder
    mkdir__ifnotexist(habitat_path);
    
    % Save NIfTI
    newdirectoryRisultati = strcat(habitat_path,'\vol_hab.nii');
    W = size(volume,1);
    H = size(volume,2);
    nii = make_nii(volume, [2 2 2], [W/2 H/2 0]);
%     nii = make_nii(volume, [pixel__w pixel__w slice__s], [W/2 H/2 0], 512);
    save_nii(nii, newdirectoryRisultati);

    newdirectoryRisultati = strcat(habitat_path,'\mask_hab.nii');
    W = size(volume,1);
    H = size(volume,2);
    nii = make_nii(mask, [2 2 2], [W/2 H/2 0]);
%     nii = make_nii(mask, [pixel__w pixel__w slice__s], [W/2 H/2 0], 512);
    save_nii(nii, newdirectoryRisultati);
    
    % Call RaCat
    [GLCM__features] = main__Radiomics_RaCat_habitat_impfeat(habitat_path, ...
        scantype,feat_name,feat_abbr, '2d');

    % We are interested in Energy, Entropy, Homogeneity and Contrast
    % Cut the unnecessary features
    GLCM__features = (GLCM__features.Energy)/energy__norm;
    
    % Apply log transformation to "expand" the scale for visualization
    % purposes (only for Energy and Contrast)
%     % Energy
%     GLCM__features(1) = t4bc__logtransform__alg(GLCM__features(1));
%     % Contrast
%     GLCM__features(2) = t4bc__logtransform__alg(GLCM__features(2));
%     
%     for i = 1:length(GLCM__features)
%         if GLCM__features > 1
%             GLCM__features = 1;
%         end
%     end
    
    try rmdir(habitat_path,'s');
    catch
    end
    
    % GLCM-feature labels
%     GLCM__labels = {'Energy', 'Contrast', 'Entropy', 'Homogeneity'};
    
    % Final assignations
    feat = GLCM__features;

end

% 
% function output = t4bc__logtransform__alg(input)
%     alpha = 1e-6;
%     
%     output = (log(input + alpha) - log(alpha)) / ...
%         (log(1 + alpha) - log(alpha));
% end
