function results = process__2didentify(input)
% TRACE4BC © 2019 DeepTrace Technologies S.R.L.
% Load VOL + SEGMENTATION

%input image
%input mask
%input modality

    volume__pathfile = input.img;
    mask__pathfile = input.mask;
    patient__name = input.pid;
    
    % Assign variables and parameters
    endout = regexp(volume__pathfile,filesep,'split');
    temp__path = endout{1,1};
    for i = 2:(size(endout,2)-1)
        temp__path = strcat(temp__path,'/',endout{1,i});
    end
    drive__root = temp__path;
    file__name = endout{1,end};
    
    inp.file = file__name;
    inp.path = drive__root;
    inp.dimension = 2;
    inp.output_req = 'volume';
    data = identify_load_file(inp);
    
    if ~isempty(data.path)
        drive__root = data.path;
%         dicomRoot = fullfile(data.path, data.name);
        file__name = data.name;
    else
%         dicomRoot = strcat(drive__root,'/',endout{1,end});
    end

    
    endout = regexp(mask__pathfile,filesep,'split');
    temp__path = endout{1,1};
    for i = 2:(size(endout,2)-1)
        temp__path = strcat(temp__path,'/',endout{1,i});
    end
    drive__root_mask = temp__path;
    file__name_mask = endout{1,end};
    
    inp.file = file__name_mask;
    inp.path = drive__root_mask;
    inp.dimension = 2;
    inp.output_req = 'volume';
    data_mask = identify_load_file(inp);
    
    
%     manual = input.manual__segmentation;
%     lesion = input.lesion;
    radiomicsmapping = input.radiomicsmapping;
    try
        if size(data.volume,1) == size(data_mask.volume,1) && size(data.volume,2) == size(data_mask.volume,2)
            if length(unique(data_mask.volume)) == 2
                volume_ok=1;
            else
                volume_ok = 0;
                results = 2;
            end   
        else
            volume_ok = 0;
            results = 1;
        end
    catch
        volume_ok = 0;
        results = 1;
    end
    if volume_ok == 1

        try % Save NIfTI
            vol = data.volume;
            info.dx = data.dx;
            info.manufacturer = data.manuf;
            mask = data_mask.volume;
            out = save__finalnifti(info, vol, mask, drive__root);

            % Extract RADIOMIC features
            nonsegmented__vol = out.vol;
            mask = out.mask;

            [total_feat, total_feat_values] =...
                main__Radiomics_Extraction_2D_309(drive__root, ...
                input.modality, patient__name);

            class_input.dir.model = input.model_path;
            class_input.dir.save = drive__root;
            class_input.model = input.model;
            class_input.features = cell2mat(total_feat(:,3));
            class_input.manuf = data.manuf;

            results.results = t4bc__test__alg_integrato(class_input);%manda tutto all'interfaccia risultato

            % Assign variables to input__report strucuture
            input__report.us.patient__id = file__name;
            input__report.us.features = total_feat;
            input__report.us.drive = drive__root;

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

        catch

            results = [];
            % try rmdir(targetfolder,'s'); end

        end
    else
        
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


            Ox = size(crop__img,1)/2;
            Oy = size(crop__img,2)/2;
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
%         nii = anonymize(nii, [], 'nifti');
        out.hdr = nii.hdr;
        out.vol = nii.img;

        save_nii(nii, new__img);

    % Save mask
        new__mask = fullfile(mkdir__ifnotexist(fullfile(...
            path, 'volumes')), 'mask.nii');

        nii = make_nii(crop__mask, [dx(1) dx(2) dx(3)], [Ox Oy Oz],...
            64, manufacturer);

        % Anonymize NIfTI
%         nii = anonymize(nii, [], 'nifti');
        out.mask = nii.img;

        save_nii(nii, new__mask);

end
