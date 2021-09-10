function results = process__2d(input)
% TRACE4BC © 2019 DeepTrace Technologies S.R.L.
% Load VOL + SEGMENTATION

    % Assign variables and parameters
    volume__path = input.volume__path;
    mask__path = input.mask__path;
    manual = input.manual__segmentation;
    lesion = input.lesion;
    radiomicsmapping = input.radiomicsmapping;
    
    % Split path into drive and last folder
    endout = regexp(volume__path,filesep,'split');
    temp__path = endout{1,1};
    for i = 2:(size(endout,2)-1)
        temp__path = strcat(temp__path,'/',endout{1,i});
    end
    drive__root = temp__path;
    file__name = endout{1,end};
    patient__name = file__name(1:strfind(file__name,'.')-1);
    
    try
    if strcmp(input.modality, 'PET-CT')
        
        ...
            
    elseif strcmp(input.modality, 'MAMMOGRAPHY')
        
        switch input.format
            
            case 'nifti'
                
                % Load volume
                vol = load_nii(volume__path);
                hdr = vol.hdr;
                vol = vol.img;

                % Load mask
                mask = load_nii(mask__path);
                mask = mask.img;

                % Check header fields and information
                	% Dim
                    try
                        info.origin = hdr.hist.originator(1:3);
                    end
                    
                    % dx
                    try
                        info.dx = hdr.dime.pixdim(2:4);
                    end

                    % Manufacturer
                    try
                        if ~isempty(hdr.hist.descrip)
                            info.manufacturer = hdr.hist.descrip;
                        end
                    end                    
                    
            case 'nrrd'
                
                % Load volume
                hdr = nhdr_nrrd_read(volume__path, true);
                vol = hdr.data;

                % Load mask
                mask = nhdr_nrrd_read(mask__path, true);
                mask = mask.data;

                % Check header fields and information
                	% Dim
                    try
                        info.origin = hdr.spaceorigin;
                    end
                    
                    % dx
                    try
                        info.dx = [hdr.spacedirections_matrix(1,1)...
                            hdr.spacedirections_matrix(2,2)...
                            hdr.spacedirections_matrix(3,3)];
                    end

                    % Manufacturer
                    try
                        ...
                    end    
                    
            case 'dicom'
                
                
                % Load volume
                vol = dicomread(volume__path);
                hdr = dicominfo(volume__path);
%                 vol = vol.img;
                try vol=rgb2gray(vol);end
                % Load mask
                mask = dicomread(mask__path);
%                 mask = mask.img;

                % Check header fields and information
                	% Dim
                    try
                        info.origin = hdr.hist.originator(1:3);
                    end
                    
                    % dx
                    try
                        info.dx = hdr.PixelSpacing(1:2);
                    catch
                        info.dx(1) = hdr.SequenceOfUltrasoundRegions.Item_1.PhysicalDeltaX;
                        info.dx(2) = hdr.SequenceOfUltrasoundRegions.Item_1.PhysicalDeltaX;
                        info.dx(3) = hdr.SequenceOfUltrasoundRegions.Item_1.PhysicalDeltaX;
                    end
                    try
                        info.manufacturer = hdr.Manufacturer;
                    end
                        
                % Check header fields and information
%                 try
%                     info.manufacturer = strcat(hdr.Manufacturer, ...
%                         '___', app.temp.info.ManufacturerModelName);
%                 catch
%                     manufacturer = 'unknown';
%                 end            
                    
        end
        
        % Save NIfTI
        out = save__finalnifti(info, vol, mask, drive__root);

        % Extract RADIOMIC features
        nonsegmented__vol = out.vol;
        mask = out.mask;
        
%         [total_feat, total_feat_values] =...
%             main__Radiomics_RaCat_mam(drive__root, ...
%             input.modality, patient__name);
        [total_feat, total_feat_values] =...
            main__Radiomics_Extraction_2D_309(drive__root, ...
            input.modality, patient__name);

        % Assign variables to input__report strucuture
        input__report.mam.patient__id = file__name;
        input__report.mam.features = total_feat;
        input__report.mam.drive = drive__root;
        % input__report.ct.global =...
        %     strcat(dicomRoot,'/temp/ct_slice.png');

        % Crop the volume and the mask around the ROI
            [ytemp, xtemp] = find(mask > 0);

            xmin = max(min(xtemp) - 20, 1);
            xmax = min(max(xtemp) + 20, size(mask, 2));
            ymin = max(min(ytemp) - 20, 1);
            ymax = min(max(ytemp) + 20, size(mask, 1));
            
            nonsegmented__vol = ...
                squeeze(nonsegmented__vol(ymin:ymax, xmin:xmax));
            mask = squeeze(mask(ymin:ymax, xmin:xmax));
        
        % Segment volume
        segmented__vol = nonsegmented__vol;
        segmented__vol(mask == 0) = 0;
        nonsegmented__volume.mam = nonsegmented__vol;
        segmented__volume.mam.volume = segmented__vol;
        segmented__volume.mam.mask = mask;

        % Compute features for local single-lesion differences (Habitat)
        if radiomicsmapping
            hdr__temp = out.hdr;
            pixel__w = hdr__temp.dime.pixdim(2);
            if ~isequal(pixel__w, hdr__temp.dime.pixdim(3))
                warning('Warning: pixel width along x and y directions are not equal.');
            end
            slice__s = hdr__temp.dime.pixdim(4);
            if strcmp(input.modality, 'MAMMOGRAPHY')
                [habitat.mam] = localhabitat__2d(nonsegmented__volume.mam,...
                segmented__volume.mam.mask, 'MAM', pixel__w,...
                slice__s, drive__root);
            elseif strcmp(input.modality, 'US')
                [habitat.mam] = localhabitat__2d(nonsegmented__volume.mam,...
                segmented__volume.mam.mask, 'US', pixel__w,...
                slice__s, drive__root);
            end
            
        else
            habitat.mam = [];
        end

        % Define texture cell vector
        tx__features.mam = total_feat_values;

        results.mam__features = tx__features.mam;
        results.mamreport = input__report;        
        
        % Assigning results to corresponding variables
        results.nonsegmentedvolume = nonsegmented__volume;
        results.volume = segmented__volume;
        if radiomicsmapping == 1
            results.habitat = habitat;
        else
            results.habitat = [];
        end

        % Save extracted features in .mat file
        saving__path = mkdir__ifnotexist(fullfile(drive__root, 'results'));
        savingpath__mamfeat = fullfile(saving__path, '__mam-features.mat');

        features = tx__features.mam;
        save(savingpath__mamfeat,'features');      
    elseif strcmp(input.modality, 'US')
        
        switch input.format
            
            case 'nifti'
                
                % Load volume
                vol = load_nii(volume__path);
                hdr = vol.hdr;
                vol = vol.img;

                % Load mask
                mask = load_nii(mask__path);
                mask = mask.img;

                % Check header fields and information
                	% Dim
                    try
                        info.origin = hdr.hist.originator(1:3);
                    end
                    
                    % dx
                    try
                        info.dx = hdr.dime.pixdim(2:4);
                    end

                    % Manufacturer
                    try
                        if ~isempty(hdr.hist.descrip)
                            info.manufacturer = hdr.hist.descrip;
                        end
                    end                    
                    
            case 'nrrd'
                
                % Load volume
                hdr = nhdr_nrrd_read(volume__path, true);
                vol = hdr.data;

                % Load mask
                mask = nhdr_nrrd_read(mask__path, true);
                mask = mask.data;

                % Check header fields and information
                	% Dim
                    try
                        info.origin = hdr.spaceorigin;
                    end
                    
                    % dx
                    try
                        info.dx = [hdr.spacedirections_matrix(1,1)...
                            hdr.spacedirections_matrix(2,2)...
                            hdr.spacedirections_matrix(3,3)];
                    end

                    % Manufacturer
                    try
                        ...
                    end    
                    
            case 'dicom'
                
                
                % Load volume
                vol = dicomread(volume__path);
                hdr = dicominfo(volume__path);
%                 vol = vol.img;
                try vol=rgb2gray(vol);end
                % Load mask
                mask = dicomread(mask__path);
%                 mask = mask.img;

                % Check header fields and information
                	% Dim
                    try
                        info.origin = hdr.hist.originator(1:3);
                    end
                    
                    % dx

                    try
                        info.dx = hdr.PixelSpacing(1:2);
                    catch
                        info.dx(1) = hdr.SequenceOfUltrasoundRegions.Item_1.PhysicalDeltaX;
                        info.dx(2) = hdr.SequenceOfUltrasoundRegions.Item_1.PhysicalDeltaX;
                        info.dx(3) = hdr.SequenceOfUltrasoundRegions.Item_1.PhysicalDeltaX;
                    end
                    try
                        info.manufacturer = hdr.Manufacturer;
                    end
                        
                % Check header fields and information
%                 try
%                     info.manufacturer = strcat(hdr.Manufacturer, ...
%                         '___', app.temp.info.ManufacturerModelName);
%                 catch
%                     manufacturer = 'unknown';
%                 end            
                    
        end
        
        % Save NIfTI
        out = save__finalnifti(info, vol, mask, drive__root);

        % Extract RADIOMIC features
        nonsegmented__vol = out.vol;
        mask = out.mask;
        
%         [total_feat, total_feat_values] =...
%             main__Radiomics_RaCat_mam(drive__root, ...
%             input.modality, patient__name);
        [total_feat, total_feat_values] =...
            main__Radiomics_Extraction_2D_309(drive__root, ...
            input.modality, patient__name);

        % Assign variables to input__report strucuture
        input__report.us.patient__id = file__name;
        input__report.us.features = total_feat;
        input__report.us.drive = drive__root;
        % input__report.ct.global =...
        %     strcat(dicomRoot,'/temp/ct_slice.png');

        % Crop the volume and the mask around the ROI
            [ytemp, xtemp] = find(mask > 0);

            xmin = max(min(xtemp) - 20, 1);
            xmax = min(max(xtemp) + 20, size(mask, 2));
            ymin = max(min(ytemp) - 20, 1);
            ymax = min(max(ytemp) + 20, size(mask, 1));
            
            nonsegmented__vol = ...
                squeeze(nonsegmented__vol(ymin:ymax, xmin:xmax));
            mask = squeeze(mask(ymin:ymax, xmin:xmax));
        
        % Segment volume
        segmented__vol = nonsegmented__vol;
        segmented__vol(mask == 0) = 0;
        nonsegmented__volume.us = nonsegmented__vol;
        segmented__volume.us.volume = segmented__vol;
        segmented__volume.us.mask = mask;

        % Compute features for local single-lesion differences (Habitat)
        if radiomicsmapping
            hdr__temp = out.hdr;
            pixel__w = hdr__temp.dime.pixdim(2);
            if ~isequal(pixel__w, hdr__temp.dime.pixdim(3))
                warning('Warning: pixel width along x and y directions are not equal.');
            end
            slice__s = hdr__temp.dime.pixdim(4);
            if strcmp(input.modality, 'MAMMOGRAPHY')
                [habitat.mam] = localhabitat__2d(nonsegmented__volume.mam,...
                segmented__volume.mam.mask, 'MAM', pixel__w,...
                slice__s, drive__root);
            elseif strcmp(input.modality, 'US')
                [habitat.us] = localhabitat__2d(nonsegmented__volume.us,...
                segmented__volume.us.mask, 'US', pixel__w,...
                slice__s, drive__root);
            end
            
        else
            habitat.us = [];
        end

        % Define texture cell vector
        tx__features.us = total_feat_values;

        results.us__features = tx__features.us;
        results.usreport = input__report;        
        
        % Assigning results to corresponding variables
        results.nonsegmentedvolume = nonsegmented__volume;
        results.volume = segmented__volume;
        if radiomicsmapping == 1
            results.habitat = habitat;
        else
            results.habitat = [];
        end

        % Save extracted features in .mat file
        saving__path = mkdir__ifnotexist(fullfile(drive__root, 'results'));
        savingpath__usfeat = fullfile(saving__path, '__us-features.mat');

        features = tx__features.us;
        save(savingpath__usfeat,'features');
    end
    catch
        
        results = [];
        % try rmdir(targetfolder,'s'); end

    end
                                                                            
end

function out = save__finalnifti(info, vol, mask, path)


    five__percrow = round(size(mask, 1) * 0.05);
    five__perccol = round(size(mask, 2) * 0.05);

    [r, c] = find(mask > 0);

    colmin = min(min(c)) - five__perccol;
    rowmin = min(min(r)) - five__percrow;
    colmax = max(max(c)) + five__perccol;
    rowmax = max(max(r)) + five__percrow;
    if colmin <= 0
        colmin = 1;
    end
    if rowmin <= 0
        rowmin = 1;
    end
    if colmax > size(mask, 2)
        colmax = size(mask, 2);
    end
    if rowmax > size(mask, 1)
        rowmax = size(mask, 1);
    end
    
    
    crop__img = double(squeeze(vol(rowmin:rowmax, colmin:colmax)));
    crop__mask = double(squeeze(mask(rowmin:rowmax, colmin:colmax)));


            Ox = size(vol,1)/2;
            Oy = size(vol,2)/2;
            Oz = 0;

        % dx
        try
            dx = info.dx;
        catch
            errordlg('Pixel dimensions not found! Please, check the input file.');
        end
        if length(dx)==2
            dx(3)=dx(1);
        end
        % Manufacturer
        try
            manufacturer = info.manufacturer;
        catch
            manufacturer = 'unknown';
        end

    % Save img
        new__img = fullfile(mkdir__ifnotexist(fullfile(...
            path, 'volumes')), 'vol.nii');

        nii = make_nii(crop__img, [dx(1) dx(2) dx(3)], [Ox Oy Oz],...
            64, manufacturer);

        % Anonymize NIfTI
        nii = anonymize(nii, [], 'nifti');
        out.hdr = nii.hdr;
        out.vol = nii.img;

        save_nii(nii, new__img);

    % Save mask
        new__mask = fullfile(mkdir__ifnotexist(fullfile(...
            path, 'volumes')), 'mask.nii');

        nii = make_nii(crop__mask, [dx(1) dx(2) dx(3)], [Ox Oy Oz],...
            64, manufacturer);

        % Anonymize NIfTI
        nii = anonymize(nii, [], 'nifti');
        out.mask = nii.img;

        save_nii(nii, new__mask);

end
