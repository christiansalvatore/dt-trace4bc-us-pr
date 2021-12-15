function output = identify_load_file(app)
    % recuperare: immagine/volume, pix dim (dx,dy,dz), manuf,oppure file
    %input:
    % app.file          (nome file selezionato)
    % app.path          (percorso file selezionato)
    % app.dimension     (2, 3) 
    % app.data_mod      (t1, t2, adc,....) solo per dicomdir
    % app.output_req    (volume, nii, ...)

    %output:
    output.volume = [];     %se carico volume
    output.dx = [];         %se carico volume
    output.manuf = [];      %se carico volume
    output.info = [];       %se carico volume
    output.path = [];       %se converto in nifti, percordo del file nifti
    output.name = [];       %se converto in nifti, nome del file nifti
    warning off
    if strcmpi(app.file, 'DICOMDIR')
        output.errore = 0;
        try detailsStruct = images.dicom.parseDICOMDIR(fullfile(app.path,app.file));
        catch
        end
        tot_mod = 0;
        series_index = [];

        try series = length(detailsStruct.Patients.Studies.Series);
            for i = 1 : series %check series identified with T1
                desc = detailsStruct.Patients.Studies.Series(i).Payload.SeriesDescription;
        %         k = strfind (desc, 't1');
        %         if ~isempty(k) 
                if contains(desc, app.data_mod)
                    tot_mod = tot_mod + 1;
                    series_index = [series_index i];
                end
            end

            if tot_mod > 1 %if more than 1 series of that modality, report error
                output.errore = 1;
            elseif tot_mod == 0 %if no series of that modality, report error
                output.errore = 2;
            else
                series_path = detailsStruct.Patients.Studies.Series(series_index).Images(2).Payload.ReferencedFileID;
                k = strfind(series_path, '\');
                series_path = series_path(1:k(end)-1);
                series_path = fullfile(app.path,series_path);
                list_files = dir(series_path);
                list_files(1:2) = [];
                delete_list = [];
                sID = [];
                for i = 1:length(list_files)
                    temp_f = fullfile(list_files(i).folder, list_files(i).name);
                    try info_t = dicominfo(temp_f);
                        if isempty(sID)
                            info = dicominfo(temp_f);
                            sID = info.SeriesInstanceUID;
                        else
                            if strcmp(info_t.SeriesInstanceUID, sID)
                            else
                                delete_list = [delete_list, i];
                            end
                        end
                    catch
                        delete_list = [delete_list, i];
                    end
                end
                list_files(delete_list) = [];
                output.path = list_files(1).folder;
                output.name = list_files(1).name;
                if strcmp (app.output_req, 'volume')
                    [output.volume, output.manuf, output.dx, output.info] = dicom2volume(list_files);
                elseif strcmp(app.output_req, 'nii')
                    nifti_path = strcat(list_files(1).folder,'\nifti');
                    mkdir__ifnotexist(nifti_path);
                    dicm2nii(series_path, nifti_path, 0);
                    lista_nifti = dir(fullfile(nifti_path,'*.nii'));
                    if isempty(lista_nifti)
                        output.path = [];
                        output.name = [];
                    else
                        [~,idx] = sort([lista_nifti.datenum]);
                        output.path = nifti_path;
                        output.name = lista_nifti(idx(end)).name;
                    end
                else
                end
            end
        catch
            %data modality not recognized
        end
    elseif endsWith(app.file, '.nii','IgnoreCase',true)
        if strcmp(app.output_req, 'volume')
            vol = load_nii(fullfile(app.path,app.file));
            output.info = vol.hdr;
            output.volume = vol.img;
%             try if isempty(output.info.hist.rot_orient)
%                 else
                    output.volume1 = zeros(size(output.volume,2),size(output.volume,1),size(output.volume,3));
                    for j=1:size(output.volume,3)
                        fetta = output.volume(:,:,j);
                        output.volume1(:,:,size(output.volume,3)-j+1)=rot90(fliplr(fetta(:,:)),-1);
                    end
                    tipo = class(output.volume);
                    output.volume = output.volume1;
                    [output.volume, ~] = chance_datatype(output.volume,tipo);
%                 end
%             catch
%             end
            
            try
                output.dx = vol.hdr.dime.pixdim(2:4);
            catch
                %error pix size
                output.dx = [1,1,1];
            end
            try
                if ~isempty(vol.hdr.hist.descrip) && contains(vol.hdr.hist.descrip,'___')%%####nifti files don't have machine infos usually
                    output.manuf = vol.hdr.hist.descrip;
                else
                    output.manuf = 'unknown';
                end
            catch
                output.manuf = 'unknown';
            end
        elseif strcmp(app.output_req, 'nii') %sposta file?
%             nifti_path = strcat(app.path,'\nifti');
%             mkdir__ifnotexist(nifti_path);
            output.path = app.path;
            output.name = app.file;
        else
            %other
        end
        
    elseif endsWith(app.file, '.nrrd','IgnoreCase',true)
        hdr = nhdr_nrrd_read(fullfile(app.path,app.file), true);
        output.volume = hdr.data;
        output.info = hdr;
        if output.info.sizes(1) == 3
            output.volume1 = permute(output.volume,[3 2 1]);
            output.volume = output.volume1(:,:,1);
%             temp = output.info.sizes;
%             try output.info.sizes = [temp(3) temp(2) temp(1) temp(4)];
%             catch
%                 output.info.sizes = [temp(3) temp(2) temp(1)];
%             end
        end
        try
            output.dx = [hdr.spacedirections_matrix(1,1)...
                hdr.spacedirections_matrix(2,2)...
                hdr.spacedirections_matrix(3,3)];
        catch 
            output.dx = [1,1,1];
        end
        
        output.manuf = 'unknown';%####NRRD files don't have machine infos
        if strcmp(app.output_req, 'nii')
            nifti_path = strcat(app.path,'\nifti');
            mkdir__ifnotexist(nifti_path);
            
            output.volume1 = zeros(size(output.volume,2),size(output.volume,1),size(output.volume,3));
            for j=1:size(output.volume,3)
                fetta = output.volume(:,:,j);
                output.volume1(:,:,size(output.volume,3)-j+1)=rot90(fliplr(fetta(:,:)),-1);
            end
            tipo = class(output.volume);
            output.volume = output.volume1;
            [output.volume, ~] = chance_datatype(output.volume,tipo);
            
            
            H = size(output.volume, 1);
            W = size(output.volume, 2);
            N = size(output.volume, 3);
            if N <= 1
                output.dx(3) = output.dx(1);
            end
            nii = make_nii(output.volume, [output.dx(1) output.dx(2) output.dx(3)], [H/2 W/2 ceil(N/2)],...
                [], output.manuf);
            k = strfind(app.file,'.');
            nifti_path_complete = strcat(nifti_path,'\',app.file(1:k(end)-1),'.nii');
            save_nii(nii, nifti_path_complete);
            
            output.path = nifti_path;
            output.name = strcat(app.file(1:k(end)-1),'.nii');
            
            output.volume = [];
            output.dx = [];
            output.manuf = [];
            output.info = [];
        else
            
        end
        
    elseif endsWith(app.file, '.jpg','IgnoreCase',true) || endsWith(app.file, '.jepg','IgnoreCase',true)
        output.volume = imread(fullfile(app.path, app.file));
        output.manuf = 'unknown';
        output.dx = [0.5,0.5,1];
        output.info = [];
        if strcmp(app.output_req, 'nii')
            nifti_path = strcat(app.path,'\nifti');
            mkdir__ifnotexist(nifti_path);
            try output.volume = rgb2gray(output.volume);
            catch
            end
            output.volume = (output.volume./max(max(output.volume)))*100;
            
            output.volume1 = zeros(size(output.volume,2),size(output.volume,1),size(output.volume,3));
            for j=1:size(output.volume,3)
                fetta = output.volume(:,:,j);
                output.volume1(:,:,size(output.volume,3)-j+1)=rot90(fliplr(fetta(:,:)),-1);
            end
            tipo = class(output.volume);
            output.volume = output.volume1;
            [output.volume, ~] = chance_datatype(output.volume,tipo);
            
            H = size(output.volume, 1);
            W = size(output.volume, 2);

            nii = make_nii(output.volume, [output.dx(1) output.dx(1) output.dx(1)], [H/2 W/2 0],...
                [], output.manuf);
            k = strfind(app.file,'.');
            nifti_path_complete = strcat(nifti_path,'\',app.file(1:k(end)-1),'.nii');
            save_nii(nii, nifti_path_complete);
            
            output.path = nifti_path;
            output.name = strcat(app.file(1:k(end)-1),'.nii');
            
            output.volume = [];
            output.dx = [];
            output.manuf = [];
            output.info = [];
        else

        end
    else %dicom [object, datatype] = chance_datatype(object,tipo)
        if app.dimension == 3 
            try info = dicominfo(fullfile(app.path, app.file));
                sID = info.SeriesInstanceUID;
                list_files = dir(app.path);
                list_files(1:2) = [];
                delete_list = [];
                for i = 1:length(list_files)
                    temp_f = fullfile(list_files(i).folder, list_files(i).name);
                    try info_t = dicominfo(temp_f);
                        if strcmp(info_t.SeriesInstanceUID, sID)
                        else
                            delete_list = [delete_list, i];
                        end
                    catch
                        delete_list = [delete_list, i];
                    end
                end
                list_files(delete_list) = [];
                if strcmp(app.output_req, 'volume')
                    [output.volume, output.manuf, output.dx, output.info] = dicom2volume(list_files);
                elseif strcmp(app.output_req, 'nii')
                    nifti_path = strcat(list_files(1).folder,'\nifti');
                    mkdir__ifnotexist(nifti_path);
                    dicm2nii(app.path, nifti_path, 0);
                    lista_nifti = dir(fullfile(nifti_path,'*.nii'));
                    if isempty(lista_nifti)
                        output.path = [];
                        output.name = [];
                    else
                        [~,idx] = sort([lista_nifti.datenum]);
                        output.path = nifti_path;
                        output.name = lista_nifti(idx(end)).name;
                    end
                else
                    %other
                end
            catch
                %data modality not recognized
            end
        else
            whole_path = [];
            try output.info = dicominfo(fullfile(app.path, app.file));
                whole_path = fullfile(app.path, app.file);
            catch
                try output.info = dicominfo(fullfile(app.file));
                    whole_path = app.file;
                catch
                end
            end
            if ~isempty(whole_path)
                if strcmp(app.output_req, 'volume')
                    output.volume = dicomread(whole_path);
                    try output.dx(1,1)=output.info.PixelSpacing(1);
                        output.dx(1,2)=output.info.PixelSpacing(2);
                        try output.dx(1,3)=output.info.SliceThickness;
                        catch
                            output.dx(1,3)=1;
                        end
                    catch
                        try output.dx(1,1) = output.info.SequenceOfUltrasoundRegions.Item_1.PhysicalDeltaX;
                            output.dx(1,2) = output.info.SequenceOfUltrasoundRegions.Item_1.PhysicalDeltaX;
                            try output.dx(1,3)=output.info.SliceThickness;
                            catch
                                output.dx(1,3) = 1;%hdr.SequenceOfUltrasoundRegions.Item_1.PhysicalDeltaX;
                            end
                        catch
                            %voxel size not fount
                        end
                    end
                    try output.manuf = strcat(output.info.Manufacturer,'___',output.info.ManufacturerModelName);
                    catch
                        output.manuf = 'unknown';
                    end

                elseif strcmp(app.output_req, 'nii')
                    nifti_path = strcat(app.path,'\nifti');
                    mkdir__ifnotexist(nifti_path);
                    dicm2nii(fullfile(app.path, app.file), nifti_path, 0);
                    lista_nifti = dir(fullfile(nifti_path,'*.nii'));
                    if isempty(lista_nifti)
                        output.path = [];
                        output.name = [];
                    else
                        [~,idx] = sort([lista_nifti.datenum]);
                        output.path = nifti_path;
                        output.name = lista_nifti(idx(end)).name;
                    end
                else
                    %other save
                end
            end
        end
    end
end


function [volume1, manuf, dx, info]=dicom2volume(files_in_folder)

    vettore_index=zeros(length(files_in_folder),3);

    for k=1:length(files_in_folder)
        file_nome=files_in_folder(k).name;
        dicP=strcat(files_in_folder(k).folder,'\',files_in_folder(k).name);
        check_data=0;
        info = dicominfo(dicP);
        anon1 = 0;
        try nameP=strcat(info.PatientName.FamilyName, '_',...
                info.PatientName.GivenName);
        catch
            try nameP=strcat(info.PatientName.FamilyName);
            catch
                nameP=strcat(info.PatientName);
            end
        end

        if isempty(nameP) || strcmp(nameP, '-') ||...
                strcmp(nameP, '-_-') || strcmp(nameP, '') ||...
                strcmp(nameP, '_')
        else
            B = regexp(nameP,'\d*','Match');
            if isempty(B)
                anon1=1;
            end
        end
        try birth=info.PatientBirthDate;
        catch
        end

        if isempty(birth) || strcmp(birth, '-') || strcmp(birth, '')
        else
            anon1 = 1;
        end

        if anon1
            try
                info2a = dicominfo(dicP);
                info2a.PatientName = '';
                info2a.PatientBirthDate = '';
                imP=dicomread(dicP);
                new_name=strcat(files_in_folder(k).folder,'\an_',file_nome);
                dicomwrite(imP,new_name,info2a,'CreateMode', 'copy');
%                 files_in_folder(k).name = strcat('\an_',file_nome);
                delete(dicP);
                movefile(new_name,dicP);
            catch
                check_data = 1;
            end
        end

    end

    pause(0.1);

    if check_data == 1
        msgbox(sprintf('Something went wrong during data upolad,\nplease, check folder content'), 'Error','error');
        volume1 = [];
%         inizio = [];
%         fine = [];
        manuf = [];
        dx = [];
%         zMin = [];
%         zMax = [];
        info = [];
%         vettore_posizione = [];
    else
%         files_in_folder=dir(dicomIMpath);
%         files_in_folder(1:2)=[];
        j=0;
        vettore_posizione=zeros(length(files_in_folder),1);
        for i=1:length(files_in_folder)
            try info=dicominfo(strcat(files_in_folder(i).folder,'\',files_in_folder(i).name));
                info_ok=1;
            catch
                info_ok=0;
            end
            if info_ok==1
                j=j+1;
                vettore_index(i,1)=(i);
                vettore_index(i,2)=(info.InstanceNumber);
                try vettore_index(i,3)=(info.SliceLocation);
                catch
                    vettore_index(i,3)=(info.ImagePositionPatient(3));
                end
                vettore_posizione(i,1)=info.ImagePositionPatient(3);
                fetta=dicomread(strcat(files_in_folder(i).folder,'\',files_in_folder(i).name));
                tipo = class(fetta);
                fetta = double(fetta);
                try slope=info.RescaleSlope;

                catch
                    slope=1;
                end
                try intercept=info.RescaleIntercept;
                catch
                    intercept=0;
                end

                fetta=fetta.*slope+intercept;
        %         fetta=imresize(fetta, 4,'method','bicubic');
                if j==1
                   volume1=zeros(size(fetta,1),size(fetta,2),length(files_in_folder)); 
                   try manuf=strcat(info.Manufacturer,'___',info.ManufacturerModelName);
                   catch
                       manuf = 'unknown';
                   end
                end
                volume1(:,:,j)=fetta;
            end
        end
        [volume1, ~] = chance_datatype(volume1,tipo);
        volume1(:,:,j+1:length(files_in_folder))=[];
        [a1,b1]=find(vettore_index==0);
        a1(b1==2)=[];
        b1(b1==2)=[];
        a1(b1==3)=[];
        vettore_index(a1(:),:)=[];
        [~,idx]=sort(vettore_index(:,2));
        vettore_index = vettore_index(idx,:);
%         vettore_posizione = vettore_posizione(idx);
        volume_temp=volume1;
%         zMin=min(min(min(volume1)));
%         zMax=max(max(max(volume1)));
        for i=1:j
            volume1(:,:,i)=volume_temp(:,:,idx(i));
            vett_position(i)=vettore_index(i,3);
        end
        
        try dx(1,1)=info.PixelSpacing(1);
            dx(1,2)=info.PixelSpacing(2);
            try dx(1,3)=info.SliceThickness;
                dx3_check=abs(vett_position(2)-vett_position(1));
                if dx(1,3)~=dx3_check
                    msgbox('Mismatch between slice thickness and slice position!', 'Warning','warn');
                end
            catch
                dx(1,3)=vett_position(2)-vett_position(1);
            end
        catch
            try dx(1,1) = hdr.SequenceOfUltrasoundRegions.Item_1.PhysicalDeltaX;
                dx(1,2) = hdr.SequenceOfUltrasoundRegions.Item_1.PhysicalDeltaX;
    %             dx(1,3) = hdr.SequenceOfUltrasoundRegions.Item_1.PhysicalDeltaX;
                try dx(1,3)=info.SliceThickness;
                    dx3_check=abs(vett_position(2)-vett_position(1));
                    if dx(1,3)~=dx3_check
                        msgbox('Mismatch between slice thickness and slice position!', 'Warning','warn');
                    end
                catch
                    dx(1,3)=vett_position(2)-vett_position(1);
                end
            catch
                %voxel size not fount
            end
        end
    end
end
