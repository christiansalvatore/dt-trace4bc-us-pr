function [data, N, batch, varargout] = t4__vol2radiomicsTOOL__alg(volume, maschera,...
    img__type, header, rad_settings)

    is3D = 0;
    N = 1;

    try
        batch = strcat(header.Manufacturer,'__',header.ManufacturerModelName); 
        isthemask = unique(maschera);
        if sum(size(isthemask))==2
            data = [];
            N = [];
            batch = [];
            return
        end
        try volume = rgb2gray(squeeze(volume));

        catch
            try volume = squeeze(volume);
            catch
                data = [];
                N = [];
                batch = [];
                return
            end
        end
        input.volume = volume;
        input.mask = maschera;

        input.pix(1) = header.SequenceOfUltrasoundRegions.Item_1.PhysicalDeltaX*10;
        input.pix(2) = header.SequenceOfUltrasoundRegions.Item_1.PhysicalDeltaX*10;

        % Load scan-type information (for batch harmonization)
        input.img__type = img__type;
        input.is3D = is3D;
        input.rad_settings = rad_settings;
        % Extract radiomic features
        radiomic_tool__features = radiomic_features_extraction(input);

        % Assign features to output matrix
        data(1,:) = double((cell2mat(radiomic_tool__features(:,11)))');
        radiomic_tool__featspecs = radiomic_tool__features(:, [1:10 12]);

        % Vol and mask (paths)
%         vol__{1} = vol;
%         mask__{1} = mask;              

    catch me
        disp(me)

%         vol__ = [];
%         mask__ = [];
        radiomic_tool__featspecs = [];
        ...

    end

    % Varargout
    varargout{1} = radiomic_tool__featspecs;
%     varargout{2} = mask__;  
%     varargout{3} = radiomic_tool__featspecs;
%     try
%     varargout{4} = out__dir;
%     end

end

function [temp__niftivol, temp__niftimask, patient__root] = ...
    fetch__niftipaths(path, img__string, img__type)

    if endsWith(path,'-radiomics-biobank')
        temp__folder = path;
    elseif endsWith(path,'-radiomics-biobanca')
        temp__folder = path;
    elseif endsWith(path,'biobanca')
        temp__folder = path;
    elseif endsWith(path,'-radiomics')
        subfolders = dir(path);
        % Remove non-folder occurrencies
        subfolders = subfolders([subfolders.isdir]);
        % Find
        % (1) subfolders ending with "-radiomics-biobanca"
        % (2) subfolders ending with "-radiomics-biobank"
        for j = 1:size(subfolders,1)
            try

                if endsWith(subfolders(j).name,'biobanca')
                    index__temp(1,j) = 1;
                end

                if endsWith(subfolders(j).name,'-radiomics-biobank')
                    index__temp(1,j) = 1;
                end

            catch

                % Error in the previous statements
                index__temp(1,j) = 0;

            end
        end

        % Populate subdir (cell)
        temp__counter = 1;
        for i = 1:size(index__temp,2)
            if index__temp(1,i)
                subdir{temp__counter} = fullfile(subfolders(i).folder, subfolders(i).name);
                temp__counter = temp__counter + 1;
            end
        end    
        temp__folder = subdir{1};
        clear subdir
        % # TEMPORARY-UPDATE #
    elseif startsWith(path,'BioUS')
        temp__folder = path;
    end
    temp__folder = path;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    patient__root = temp__folder;

    % Find NIfTI files: CT (vol/mask) or PET (vol/mask)
        temp__files = dir(temp__folder);
        % Find
        % (1) .nii files containing "SUV_VOL" or "TC_VOL"
        % (2) .nii files containing "SUV_MASK" or "TC_MASK"
        for j = 1:size(temp__files,1)
            try
                if contains(temp__files(j).name,[img__string '_VOL'])
                    temp__niftivol = fullfile(temp__files(j).folder, temp__files(j).name);
                    break
                end
                if strcmp(img__type, 'MAMMOGRAPHY') & contains(temp__files(j).name,[img__string 'vol'])
                    temp__niftivol = fullfile(temp__files(j).folder, temp__files(j).name);
                    break
                end
                if strcmp(img__type, 'RETINOGRAPHY') & contains(temp__files(j).name,[img__string 'vol'])
                    temp__niftivol = fullfile(temp__files(j).folder, temp__files(j).name);
                    break
                end
                if strcmp(img__type, 'US') & contains(temp__files(j).name,[img__string 'vol'])
                    temp__niftivol = fullfile(temp__files(j).folder, temp__files(j).name);
                    break
                end
                if strcmp(img__type, 'RX') & contains(temp__files(j).name,[img__string 'vol'])
                    temp__niftivol = fullfile(temp__files(j).folder, temp__files(j).name);
                    break
                end
                if strcmp(img__type, 'CT') & endsWith(temp__files(j).name, 'vol.nii')
                    temp__niftivol = fullfile(temp__files(j).folder, temp__files(j).name);
                    break
                end
                % # TEMPORARY-UPDATE #
                if startsWith(temp__files(j).name, 'BioUS_') && ~endsWith(temp__files(j).name, 'mask.dcm')
                    try dicomread(fullfile(temp__files(j).folder,temp__files(j).name));
                        temp__niftivol = fullfile(temp__files(j).folder, temp__files(j).name);
                        break
                    catch
                    end
                    
                end
            catch
                % Error in the previous statements
                index__temp(1,j) = 0;
            end
        end 

        for j = 1:size(temp__files,1)
            try
                if contains(temp__files(j).name,[img__string '_MASK'])
                    temp__niftimask = fullfile(temp__files(j).folder, temp__files(j).name);
                    break
                end
                if strcmp(img__type, 'MAMMOGRAPHY') & contains(temp__files(j).name,[img__string 'mask'])
                    temp__niftimask = fullfile(temp__files(j).folder, temp__files(j).name);
                    break
                end
                if strcmp(img__type, 'RETINOGRAPHY') & contains(temp__files(j).name,[img__string 'mask'])
                    temp__niftimask = fullfile(temp__files(j).folder, temp__files(j).name);
                    break
                end
%                 if strcmp(img__type, 'US') & contains(temp__files(j).name,[img__string 'mask'])
%                     temp__niftimask = fullfile(temp__files(j).folder, temp__files(j).name);
%                     break
%                 end
                if strcmp(img__type, 'RX') & contains(temp__files(j).name,[img__string 'mask'])
                    temp__niftimask = fullfile(temp__files(j).folder, temp__files(j).name);
                    break
                end
                if strcmp(img__type, 'CT') & endsWith(temp__files(j).name, 'mask.nii')
                    temp__niftimask = fullfile(temp__files(j).folder, temp__files(j).name);
                    break
                end
                % # TEMPORARY-UPDATE #
                if endsWith(temp__files(j).name, 'mask.dcm')
                    temp__niftimask = fullfile(temp__files(j).folder, temp__files(j).name);
                    break
                end
            catch
                % Error in the previous statements
                index__temp(1,j) = 0;
            end
        end             

end
