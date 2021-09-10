function [habitat, labels] = local__habitat_other(volume, mask, scantype,...
    pixel__w, slice__s,input__report_drive)
    
    %
    % This function computes features for local single-lesion
    % differences (Habitat)
    %
    % "img" should be a masked volume (PET or CT)
    %
    
    % Define the dimensions of an isotropic sliding window to calculate
    % local features
    
    if contains(scantype,'DWI') || contains(scantype,'ADC')
        dim = 5;
%         volume(mask==0)=0;
    elseif contains(scantype,'CT')
        dim = 5;
        volume=round(volume);
%         volume(mask==0)=-1001; 
    else
        dim = 11;
    end
    
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
        dim = 5;
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
%     fallimenti=[];
%     fallimenti_locali=[];
%     fallimenti_locali3=[];
%     fail=0;
%     fail2=0;
%     fail3=0;
    for i = 1:step:size(volume,1)-dim
        disp([num2str(i) '/' num2str(size(volume,1)-dim)]);
        for j = 1:step:size(volume,2)-dim
            for k = 1:stepz:size(volume,3)-dim
                if mask(i+central__dim, j+central__dim,...
                    k+central__dim) == 1
                    temp__mask = zeros(size(mask));
                    temp__mask(i:i+dim-1, j:j+dim-1, k:k+dim-1) = 1;
                    temp__mask(mask == 0) = 0;
					new_mask=zeros(dim, dim, dim);
					new_mask(:,:,:)=temp__mask(i:i+dim-1, j:j+dim-1, k:k+dim-1);
					new_vol=zeros(dim, dim, dim);
					new_vol(:,:,:)=volume(i:i+dim-1, j:j+dim-1, k:k+dim-1);
%                     if sum(sum(sum(new_mask))) > 2
% %                         i
% %                         j
%                         try
%                             feat = computing__haralick(new_vol, new_mask,...
%                                 scantype, pixel__w, slice__s,input__report_drive);
%                         catch
%                             feat(1:4) = NaN;
% %                             fail=fail+1;
% %                             names{1,fail} = (strcat('s',num2str(fail)));
% %                             fallimenti.(names{fail}).coord = [i,j,k];  % Assign index
% %                             fallimenti.(names{fail}).volume=new_vol;
% %                             fallimenti.(names{fail}).mask=new_mask;
%                         end
%                         habitat.energy(i+central__dim, j+central__dim,...
%                             k+central__dim) = feat(1);
%                         habitat.contrast(i+central__dim, j+central__dim,...
%                             k+central__dim) = feat(2);
%                         habitat.entropy(i+central__dim, j+central__dim,...
%                             k+central__dim) = feat(3);
%                         habitat.homogeneity(i+central__dim,...
%                             j+central__dim, k+central__dim) = feat(4);
                        
                        
                        
                        
                        
                        
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
%                         b=isnan(feat);
%                         c=sum(b);
%                         if c>0 && c<4
% %                             fallimenti_locali
%                             fail2=fail2+1;
%                             names2{1,fail2} = (strcat('s',num2str(fail2)));
%                             fallimenti_locali.(names2{fail2}).coord = [i,j,k];  % Assign index
%                             fallimenti_locali.(names2{fail2}).volume=new_vol;
%                             fallimenti_locali.(names2{fail2}).mask=new_mask;
%                             fallimenti_locali.(names2{fail2}).feat=feat;
%                         end
%                         b1=find(feat>1);
%                         if ~isempty(b1)
%                             fail3=fail3+1;
%                             names3{1,fail3} = (strcat('s',num2str(fail3)));
%                             fallimenti_locali3.(names3{fail3}).coord = [i,j,k];  % Assign index
%                             fallimenti_locali3.(names3{fail3}).volume=new_vol;
%                             fallimenti_locali3.(names3{fail3}).mask=new_mask;
%                             fallimenti_locali3.(names3{fail3}).feat=feat;
%                         end
                        
%                     end
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
    
%     if ~isempty(fallimenti)
% %         output_name2 =strcat(output_path,'\',nome(9:end),'_',im_type,'_features.mat');
%         save('C:\Users\Matteo\Desktop\fail_test\fallimenti.mat', 'fallimenti');
%     end
%     if ~isempty(fallimenti_locali)
% %         output_name2 =strcat(output_path,'\',nome(9:end),'_',im_type,'_features.mat');
%         save('C:\Users\Matteo\Desktop\fail_test\fallimenti_locali.mat', 'fallimenti_locali');
%     end
%     if ~isempty(fallimenti_locali3)
% %         output_name2 =strcat(output_path,'\',nome(9:end),'_',im_type,'_features.mat');
%         save('C:\Users\Matteo\Desktop\fail_test\fallimenti_locali3.mat', 'fallimenti_locali3');
%     end
    % Final assignations
    labels = {'Energy', 'Contrast', 'Entropy', 'Homogeneity'};
    
end

function feat = computing__haralick(volume, mask, scantype,...
    pixel__w, slice__s, input__report_drive)
    
    % Prepare parameters
    if strcmp(scantype,'CT')
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
    else
        grey__levels = 64;
    end
    
    % Define # grey levels
    
%     for ii=1:dim
%         
%         name1=strcat('C:\Users\Matteo\Desktop\controllo_volumetti\box\reg_',num2str(i1),'-',num2str(j1),'-',num2str(k1),'-',num2str(ii),'.png');
%         hhh=figure('visible', 'off');
%         imagesc(volume(:,:,ii));
%         colormap('jet')
% %         nome_fronte = strcat(dicomRoot,'/temp_check/preprocessing_last.png');
%         export_fig(hhh,name1, '-m2');
%         
%         name2=strcat('C:\Users\Matteo\Desktop\controllo_volumetti\mask\reg_',num2str(i1),'-',num2str(j1),'-',num2str(k1),'-',num2str(ii),'.png');
%         hhh=figure('visible', 'off');
%         imagesc(mask(:,:,ii));
% %         colormap('jet')
% %         nome_fronte = strcat(dicomRoot,'/temp_check/preprocessing_last.png');
%         export_fig(hhh,name2, '-m2');       
%     end
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
    save_nii(nii, newdirectoryRisultati);
%     copyfile(newdirectoryRisultati, strcat('C:\Users\Matteo\Desktop\controllo_volumetti\nifti\vol_hab_',num2str(i1),'-',num2str(j1),'-',num2str(ii),'.nii'));
    newdirectoryRisultati=strcat(habitat_path,'\mask_hab.nii');
    W=size(volume,1);
    H=size(volume,2);
    nii = make_nii(mask, [pixel__w pixel__w slice__s], [W/2 H/2 size(volume,3)/2], 64);
    save_nii(nii, newdirectoryRisultati);
    %call racat code
    [GLCM__features]=main__Radiomics_RaCat_habitat_other(habitat_path, scantype);
    
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
try rmdir(habitat_path,'s'); 
catch
end
%                         b=isnan(GLCM__features);
%                         c=sum(b);
%                         if c>0 && c<4
% %                             fallimenti_locali
%                                 check_norm=1;
% %                             fail2=fail2+1;
% %                             names2{1,fail2} = (strcat('s',num2str(fail2)));
% %                             fallimenti_locali.(names2{fail2}).coord = [i,j,k];  % Assign index
% %                             fallimenti_locali.(names2{fail2}).volume=new_vol;
% %                             fallimenti_locali.(names2{fail2}).mask=new_mask;
% %                             fallimenti_locali.(names2{fail2}).feat=feat;
%                         end
%                         b1=find(GLCM__features>1);
%                         if ~isempty(b1)
%                             
%                             check_norm=1;
% %                             fail3=fail3+1;
% %                             names3{1,fail3} = (strcat('s',num2str(fail3)));
% %                             fallimenti_locali3.(names3{fail3}).coord = [i,j,k];  % Assign index
% %                             fallimenti_locali3.(names3{fail3}).volume=new_vol;
% %                             fallimenti_locali3.(names3{fail3}).mask=new_mask;
% %                             fallimenti_locali3.(names3{fail3}).feat=feat;
%                         end
    
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
