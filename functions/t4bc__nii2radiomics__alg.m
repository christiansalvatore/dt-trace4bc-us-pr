function [data, N, batch, varargout] = t4bc__nii2radiomics__alg(path, ...
    img__type, pathology, singlesubject)

%     if strcmp(img__type, 'RETINOGRAPHY')
        img__string = '';
%     elseif strcmp(pathology, 'other')
%         img__string = img__type;
%     elseif strcmp(img__type, 'CT') || strcmp(img__type, 'TC')
%         img__string = 'TC';
%     elseif strcmp(img__type, 'CYBERKNIFE')
%         img__string = '';
%     end

    if singlesubject == 0

        files = dir(fullfile(path));

        % Remove non-folder occurrencies
        files = files([files.isdir]);

        % Initialize index
        index__include = zeros(1,size(files,1)); 

        % Find
        % (1) files ending with "-radiomics"
        % (2) files ending with "-radiomics-biobanca"
        % (3) files ending with "-radiomics-biobank"
        for j = 1:size(files,1)
            try

                if endsWith(files(j).name,'-radiomics')
                    index__include(1,j) = 1;
                end

                if endsWith(files(j).name,'-radiomics-biobanca')
                    index__include(1,j) = 1;
                end

                if endsWith(files(j).name,'-radiomics-biobank')
                    index__include(1,j) = 1;
                end

            catch

                % Error in the previous statements
                index__include(1,j) = 0;

            end
        end

        % Populate subdir (cell)
        counter = 1;
        for i = 1:size(index__include,2)
            if index__include(1,i)
                directories{counter} = fullfile(files(i).folder, files(i).name);
                counter = counter + 1;
            end
        end    

        % Perform nii2radiomics for each directory resulting from the previous
        % selection
        sample_counter = 1;
        for n = 1:size(directories,2)

            % Define NIfTI-volume and -mask paths
            [vol, mask, patient__root] = fetch__niftipaths(directories{n},...
                img__string, img__type);

            % Load scan-type information (for batch harmonization)
            header = load_nii_hdr(vol);

            % Extract radiomic features
            racat__features = racat_simplefeatextraction(vol, mask,...
                img__type, patient__root);

            current__features = double((cell2mat(racat__features(:,11)))');
            racat__featspecs = racat__features(:, [1:10 12]);
            
            % Check if features are not NaN or Inf and proceed with
            % variable assignment
            if isequal( (sum(sum(isnan(current__features))) + ...
                    sum(sum(isinf(current__features)))) , 0)
                % Assign features to output matrix
                data(sample_counter,:) = current__features;

                % Vol and mask (paths)
                vol__{sample_counter} = vol;
                mask__{sample_counter} = mask; 
                
                % Batch
                batch{sample_counter} = header.hist.descrip;                 
                
                sample_counter = sample_counter + 1;
            end

        end

        N = size(data,1);
        
    elseif singlesubject == 1
        
        N = 1;
        
        if contains(path, [img__string '_VOL']) && endsWith(path, '.nii') || ...
                contains(path, [img__string 'vol']) && endsWith(path, '.nii') || ...
                contains(path, 'vol.nii')
            
            % Define patient root
            [patient__root, ~, ~] = fileparts(path);
            
            % Define NIfTI-volume and -mask paths
            vol = path;
            temp__files = dir(patient__root);
            % Find
            % .nii files containing "SUV_MASK" or "TC_MASK"
            for j = 1:size(temp__files,1)
                try
                    if contains(temp__files(j).name,[img__string '_MASK'])
                        temp__niftimask = fullfile(temp__files(j).folder, ...
                            temp__files(j).name);
                        break
                    end
                    if contains(temp__files(j).name,[img__string 'mask']) || ...
                            contains(temp__files(j).name, 'mask')
                        temp__niftimask = fullfile(temp__files(j).folder, ...
                            temp__files(j).name);
                        break
                    end 
                    if strcmp(temp__files(j).name, 'mask.nii')
                        temp__niftimask = fullfile(temp__files(j).folder, ...
                            temp__files(j).name);
                        break
                    end                     
                catch
                    % Error in the previous statements
                    index__temp(1,j) = 0;
                end
            end                         
            mask = temp__niftimask; clear temp__niftimask
                
        elseif isfolder(path)
            
            % Define NIfTI-volume and -mask paths
            [vol, mask, patient__root] = fetch__niftipaths(path, ...
                img__string, img__type);
                
        else
            
            error('The path specified is not valid.');
            
        end
        
        try
            
            % Load scan-type information (for batch harmonization)
            header = load_nii_hdr(vol);
            batch = header.hist.descrip;        

            % Extract radiomic features
            racat__features = racat_simplefeatextraction(vol, mask,...
                img__type, patient__root);

            % Assign features to output matrix
            data(1,:) = double((cell2mat(racat__features(:,11)))');
            racat__featspecs = racat__features(:, [1:10 12]);
            
            % Vol and mask (paths)
            vol__{1} = vol;
            mask__{1} = mask;              
            
        catch
            
            ...
                
        end
            
    end
    
    % Varargout
    varargout{1} = vol__;
    varargout{2} = mask__;  
    varargout{3} = racat__featspecs;

end

function [temp__niftivol, temp__niftimask, patient__root] = ...
    fetch__niftipaths(path, img__string, img__type)

    if endsWith(path,'-radiomics-biobank')
        temp__folder = path;
    elseif endsWith(path,'-radiomics-biobanca')
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

                if endsWith(subfolders(j).name,'-radiomics-biobanca')
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
    end
    patient__root = temp__folder;

    % Find NIfTI files: CT (vol/mask) or PET (vol/mask)
        temp__files = dir(temp__folder);
        % Find
        % (1) .nii files containing "SUV_VOL" or "TC_VOL"
        % (2) .nii files containing "SUV_MASK" or "TC_MASK"
        for j = 1:size(temp__files,1)
            try
%                 if contains(temp__files(j).name,[img__string '_VOL'])
%                     temp__niftivol = fullfile(temp__files(j).folder, temp__files(j).name);
%                     break
%                 end
%                 if strcmp(img__type, 'RETINOGRAPHY') & contains(temp__files(j).name,[img__string 'vol'])
%                     temp__niftivol = fullfile(temp__files(j).folder, temp__files(j).name);
%                     break
%                 end
                if strcmp(temp__files(j).name, 'vol.nii')
                    temp__niftivol = fullfile(temp__files(j).folder, temp__files(j).name);
                    break
                end                
            catch
                % Error in the previous statements
                index__temp(1,j) = 0;
            end
        end 

        for j = 1:size(temp__files,1)
            try
%                 if contains(temp__files(j).name,[img__string '_MASK'])
%                     temp__niftimask = fullfile(temp__files(j).folder, temp__files(j).name);
%                     break
%                 end
%                 if strcmp(img__type, 'RETINOGRAPHY') & contains(temp__files(j).name,[img__string 'mask'])
%                     temp__niftimask = fullfile(temp__files(j).folder, temp__files(j).name);
%                     break
%                 end    
                if strcmp(temp__files(j).name, 'mask.nii')
                    temp__niftimask = fullfile(temp__files(j).folder, temp__files(j).name);
                    break
                end                
            catch
                % Error in the previous statements
                index__temp(1,j) = 0;
            end
        end             

end
