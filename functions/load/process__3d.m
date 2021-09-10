function results = process__3d(input)
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
    
    last__point = strfind(file__name, '.');
%     try
%         patient__name = file__name(1 : last__point(end) - 1);
%     catch
        patient__name = file__name;
%     end
    
    try
    if strcmp(input.modality, 'PET-CT')
        
        ...
            
    elseif strcmp(input.modality, 'CT')
        
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
                hdr = [];
                vol = [];

                % Load mask
                mask = [];

                % Check header fields and information
                % try
                %     manufacturer = strcat(app.temp.info.Manufacturer, ...
                %         '___', app.temp.info.ManufacturerModelname);
                % catch
                %     manufacturer = 'unknown';
                % end            
                    
        end

        % Save NIfTI
        out = save__finalnifti(info, vol, mask, drive__root);

        % Extract RADIOMIC features
        nonsegmented__vol = out.vol;
        mask = out.mask;
        [total_feat, total_feat_values] =...
            main__Radiomics_RaCat(fullfile(drive__root,'volumes'), ...
            input.modality, patient__name, drive__root);

        switch input.modality
            
            case 'PET-CT'
                
                ...
                    
            case 'CT'
                
                % Assign variables to input__report strucuture
                input__report.ct.patient__id = file__name;
                input__report.ct.features = total_feat;
                input__report.ct.drive = drive__root;
                % input__report.ct.global =...
                %     strcat(dicomRoot,'/temp/ct_slice.png');
                
                % Crop the volume and the mask around the ROI
                    [ytemp, xtemp, ztemp] = findND(mask > 0);

                    xmin = max(min(xtemp) - 20, 1);
                    xmax = min(max(xtemp) + 20, size(mask, 2));
                    ymin = max(min(ytemp) - 20, 1);
                    ymax = min(max(ytemp) + 20, size(mask, 1));
                    zmin = max(min(ztemp) - 5, 1);
                    zmax = min(max(ztemp) + 5, size(mask, 3));                    

                    nonsegmented__vol = ...
                        squeeze(nonsegmented__vol(ymin:ymax, xmin:xmax, zmin:zmax));
                    mask = squeeze(mask(ymin:ymax, xmin:xmax, zmin:zmax));                

                % Segment volume
                segmented__vol = nonsegmented__vol;
                segmented__vol(mask == 0) = 0;
                nonsegmented__volume.ct = nonsegmented__vol;
                segmented__volume.ct.volume = segmented__vol;
                segmented__volume.ct.mask = mask;

                % Compute features for local single-lesion differences (Habitat)
                if radiomicsmapping
                    hdr__temp = out.hdr;
                    pixel__w = hdr__temp.dime.pixdim(2);
                    if ~isequal(pixel__w, hdr__temp.dime.pixdim(3))
                        warning('Warning: pixel width along x and y directions are not equal.');
                    end
                    slice__s = hdr__temp.dime.pixdim(4);                     
                    [habitat.ct] = local__habitat(nonsegmented__volume.ct,...
                        segmented__volume.ct.mask, 'CT', pixel__w,...
                        slice__s, input__report.ct.drive);
                else
                    habitat.mam = [];
                end

                % Define texture cell vector
                tx__features.ct = total_feat_values;

                results.ct__features = tx__features.ct;
                results.ctreport = input__report; 
                
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
                savingpath__ctfeat = fullfile(saving__path, '__ct-features.mat');

                features = tx__features.ct;
                save(savingpath__ctfeat,'features');                 
                
        end     
    
    end
    
    catch
        
        results = [];
        % try rmdir(targetfolder,'s'); end

    end
                                                                            
end

function out = save__finalnifti(info, vol, mask, path)
%     five__percrow = round(size(app.temp.mask, 1) * 0.05);
%     five__perccol = round(size(app.temp.mask, 2) * 0.05);
% 
%     [r, c] = find(app.temp.mask > 0);
% 
%     colmin = min(min(c)) - five__perccol;
%     rowmin = min(min(r)) - five__percrow;
%     colmax = max(max(c)) + five__perccol;
%     rowmax = max(max(r)) + five__percrow;
%     if colmin <= 0
%         colmin = 1;
%     end
%     if rowmin <= 0
%         rowmin = 1;
%     end
%     if colmax > size(app.temp.mask, 2)
%         colmax = size(app.temp.mask, 2);
%     end
%     if rowmax > size(app.temp.mask, 1)
%         rowmax = size(app.temp.mask, 1);
%     end
% 
%     crop__img = squeeze(app.temp.image(rowmin:rowmax, colmin:colmax));
%     crop__mask = squeeze(app.temp.mask(rowmin:rowmax, colmin:colmax));

    % Fetch parameters
        % Dim
        try
            origin = info.origin;
            Ox = origin(1);
            Oy = origin(2);
            Oz = origin(3);
        catch
            Ox = size(vol,1)/2;
            Oy = size(vol,2)/2;
            Oz = size(vol,3)/2;
        end

        % dx
        try
            dx = info.dx;
        catch
            errordlg('Pixel dimensions not found! Please, check the input file.');
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
        if isa(vol,'uint16')
            precision = 512;
        elseif isa(vol,'int16')
            precision = 4;
        else 
            precision = 64;
        end
        nii = make_nii(vol, [dx(1) dx(2) dx(3)], [Ox Oy Oz],...
            precision, manufacturer);

        % Anonymize NIfTI
        nii = anonymize(nii, [], 'nifti');
        out.hdr = nii.hdr;
        out.vol = nii.img;

        save_nii(nii, new__img);

    % Save mask
        new__mask = fullfile(mkdir__ifnotexist(fullfile(...
            path, 'volumes')), 'mask.nii');

        nii = make_nii(mask, [dx(1) dx(2) dx(3)], [Ox Oy Oz],...
            precision, manufacturer);

        % Anonymize NIfTI
        nii = anonymize(nii, [], 'nifti');
        out.mask = nii.img;

        save_nii(nii, new__mask);

end