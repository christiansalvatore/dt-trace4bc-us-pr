function results = t4gc__processecography(input__name,...
    radiomicsmapping, modality, draw_jpg, model_path, model, n_subj, tot_subj, varargin)
% TRACE4GC © 2019 DeepTrace Technologies S.R.L.

%                                                                             prog = 0;
%                                                                             hprog = waitbar(prog,'Processing...');

    % Split path into drive and last folder
    endout = regexp(input__name,filesep,'split');
    temp__path = endout{1,1};
    for i = 2:(size(endout,2)-1)
        temp__path = strcat(temp__path,'/',endout{1,i});
    end
    anon1=0;
    drive__root = temp__path;
    file__name = endout{1,end};
    
    
    
    
    
    
%     patient__path = drive__root(1:strfind(drive__root,'.')-1);
%     if isempty(patient__path)
%         patient__path=drive__root;
%     end
%     patient__name = file__name(1:end-4);
% p__i = input.us.patient__id;
    k = strfind(file__name,'.');
    if length(k)>1
        patient__name = file__name(1:k(end)-1);
    else
        patient__name = file__name;
    end
    
    try temp_dx = varargin{1};
    catch
        temp_dx = 0.5;
    end
%     patient__name = file__name(1:strfind(file__name,'.')-1);
%     patient__path = fullfile(drive__root,patient__name);
%     upload_ok=0;
    if draw_jpg == 1
        try jpg_name = varargin{2};
            upload_ok=1;
        catch
            upload_ok=0;
        end

    else
        upload_ok=1;
    end
    
    if upload_ok==1
        
        input.file = file__name;
        input.path = drive__root;
        input.dimension = 2;
        input.output_req = 'volume';
        input.dx = temp_dx;
        data = identify_load_file(input);
        
        if ~isempty(data.path)
            drive__root = data.path;
            dicomRoot = fullfile(data.path, data.name);
            file__name = data.name;
        else
            dicomRoot = strcat(drive__root,'/',endout{1,end});
        end

        if anon1 == 0

            % Segmentation (manual)
            % aggiungere HOLD
            if draw_jpg == 1
                output_vol = segmentation__2deco_jpg(dicomRoot, drive__root, radiomicsmapping, modality, data, jpg_name); %DEMO9 Save ROI and BINARY MASK
            else
                output_vol = segmentation__2deco(dicomRoot, drive__root, radiomicsmapping, modality, data); %DEMO9 Save ROI and BINARY MASK
            end
            if ~isempty(output_vol)
                                                                            prog = 0;
                                                                            testo = sprintf('Image %d of %d: proccessing...',n_subj, tot_subj);
                                                                            h = waitbar(prog,testo);
                nonsegmented__vol = output_vol.vol;
                mask = output_vol.mask;
                im_type = 'US';
                [total_feat, total_feat_values] =...
                    main__Radiomics_Extraction_2D_309(drive__root, im_type, patient__name); %DEMO10 Extract 309 2D Radiomic Features
                                                                            try
                                                                            prog = prog + (0.3);
                                                                            waitbar(prog,h);
                                                                            drawnow
                                                                            catch
                                                                            h = waitbar(prog,testo);
                                                                            drawnow
                                                                            end
                class_input.dir.model = model_path;
                class_input.dir.save = drive__root;
                class_input.model = model;
                class_input.features = cell2mat(total_feat(:,3));
                class_input.manuf = data.manuf;

                results.results = t4bc__test__alg_integrato(class_input,h,prog,testo);%manda tutto all'interfaccia risultato

                % Assign variables to input__report strucuture
                input__report.us.patient__id = file__name;
                input__report.us.features = total_feat;
                input__report.us.drive = drive__root;
            %     input__report.us.global =...
            %         strcat(dicomRoot,'/temp/ct_slice.png');

                % Segment volume
                segmented__vol = nonsegmented__vol;
                segmented__vol(mask==0) = 0;
                nonsegmented__volume.us = nonsegmented__vol;
                segmented__volume.us.volume = segmented__vol;
                segmented__volume.us.mask = mask;

                % Compute features for local single-lesion differences (Habitat)
                if radiomicsmapping == 1
                    temp__infile = dir(fullfile(drive__root, 'volumes', 'vol*'));
                    temp__infile = fullfile(temp__infile.folder, temp__infile.name);
                    hdr__temp = load_nii_hdr(temp__infile);
                    pixel__w = hdr__temp.dime.pixdim(2);
                    if ~isequal(pixel__w, hdr__temp.dime.pixdim(3))
                        warning('Warning: pixel width along x and y directions are not equal.');
                    end
                    slice__s = pixel__w;
        %             slice__s = hdr__temp.dime.pixdim(4);
                    [habitat.us] = localhabitat__2d(nonsegmented__volume.us,...
                        segmented__volume.us.mask, 'US', pixel__w,...
                        slice__s, drive__root);
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
            else
                results = [];
            end

        else

            results = [];

        end
    else
        results = [];
    end
                                                                            try %#ok<*TRYNC>
                                                                            waitbar(1,h);
                                                                            close(h);
                                                                            end     
end
