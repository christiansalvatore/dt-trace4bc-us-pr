function identify_save_file(app)


    %input:
    % app.file          (nome file selezionato con percorso)
    % app.volume        (immagine da aggiornare)
    % app.info          (info per salvataggio)
    % app.dx
    % app.manuf
    % app.dimension     (2, 3) 
    % app.data_mod      (t1, t2, adc,....) solo per dicomdir



    if endsWith(app.file, 'DICOMDIR')
%         output.errore = 0;
%         try detailsStruct = images.dicom.parseDICOMDIR(app.file);
%         catch
%         end
%         tot_mod = 0;
%         series_index = [];
% 
%         try series = length(detailsStruct.Patients.Studies.Series);
%             for i = 1 : series %check series identified with T1
%                 desc = detailsStruct.Patients.Studies.Series(i).Payload.SeriesDescription;
%         %         k = strfind (desc, 't1');
%         %         if ~isempty(k) 
%                 if contains(desc, app.data_mod)
%                     tot_mod = tot_mod + 1;
%                     series_index = [series_index i];
%                 end
%             end
% 
%             if tot_mod > 1 %if more than 1 series of that modality, report error
%                 output.errore = 1;
%             elseif tot_mod == 0 %if no series of that modality, report error
%                 output.errore = 2;
%             else
%                 series_path = detailsStruct.Patients.Studies.Series(series_index).Images(2).Payload.ReferencedFileID;
%                 k = strfind(series_path, '\');
%                 series_path = series_path(1:k(end)-1);
%                 series_path = fullfile(app.path,series_path);
%                 list_files = dir(series_path);
%                 list_files(1:2) = [];
%                 delete_list = [];
%                 sID = [];
%                 for i = 1:length(list_files)
%                     temp_f = fullfile(list_files(i).folder, list_files(i).name);
%                     try info_t = dicominfo(temp_f);
%                         if isempty(sID)
%                             info = dicominfo(temp_f);
%                             sID = info.SeriesInstanceUID;
%                         else
%                             if strcmp(info_t.SeriesInstanceUID, sID)
%                             else
%                                 delete_list = [delete_list, i];
%                             end
%                         end
%                     catch
%                         delete_list = [delete_list, i];
%                     end
%                 end
%                 list_files(delete_list) = [];
%                 if strcmp (app.output_req, 'volume')
%                     [output.volume, output.manuf, output.dx, output.info] = dicom2volume(list_files);
%                 elseif strcmp(app.output_req, 'nii')
%                     nifti_path = strcat(list_files(1).folder,'\nifti');
%                     mkdir__ifnotexist(nifti_path);
%                     dicm2nii(series_path, nifti_path, 0);
%                     lista_nifti = dir(fullfile(nifti_path,'*.nii'));
%                     if isempty(lista_nifti)
%                         output.path = [];
%                         output.name = [];
%                     else
%                         [~,idx] = sort([lista_nifti.datenum]);
%                         output.path = nifti_path;
%                         output.name = lista_nifti(idx(end)).name;
%                     end
%                 else
%                 end
%             end
%         catch
%             %data modality not recognized
%         end
    elseif endsWith(app.file, '.nii','IgnoreCase',true)
%         if strcmp(app.output_req, 'volume')


            app.volume1 = zeros(size(app.volume,2),size(app.volume,1),size(app.volume,3));
            for j=1:size(app.volume,3)
                fetta = app.volume(:,:,j);
                app.volume1(:,:,size(app.volume,3)-j+1)=rot90(fliplr(fetta(:,:)),-1);
            end
            tipo = class(app.volume);
            app.volume = app.volume1;
            [app.volume, ~] = chance_datatype(app.volume,tipo);
            H = size(app.volume,1);
            W = size(app.volume,2);
            N = size(app.volume,3);
            if N <= 1
                app.dx(3) = app.dx(1);
            end
            new__img = app.file;
            nii = make_nii(app.volume, [app.dx(1) app.dx(2) app.dx(3)], [H/2 W/2 ceil(size(app.volume,3)/2)],...
                [], app.manuf);
            save_nii(nii, new__img);
        
    elseif endsWith(app.file, '.nrrd','IgnoreCase',true)
        hdr = app.info;
        if hdr.sizes(1) == 3
            vol(:,:,1) = app.volume;
            vol(:,:,2) = app.volume;
            vol(:,:,3) = app.volume;
            app.volume = permute(vol,[3 2 1]);
%             output.volume = output.volume1(:,:,1);
        end
            
        hdr.data = app.volume;
        
        nhdr_nrrd_write(app.file, hdr, 'true')%%%%

    elseif endsWith(app.file, '.jpg','IgnoreCase',true) || endsWith(app.file, '.jepg','IgnoreCase',true)
        
        imwrite(app.volume, app.file)
        
    else %dicom
        if size(app.volume)==3
            try info = dicominfo(app.file);
                sID = info.SeriesInstanceUID;
                k = strfind(app.file,'/');
                app.path = app.file(1:k(end)-1);
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

            volume2dicom(list_files,app.volume)
    %         

            catch
            end
        else
            dicomwrite(app.volume,app.file,app.info,'CreateMode', 'copy');
        end
    end
end



function volume2dicom(files_in_folder, volume)

    vettore_index=zeros(length(files_in_folder),3);
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
        end
    end
    [~,idx]=sort(vettore_index(:,2));
    vettore_index = vettore_index(idx,:);
    files_in_folder = files_in_folder(idx,:);
    for i=1:length(files_in_folder)
        info=dicominfo(strcat(files_in_folder(i).folder,'\',files_in_folder(i).name));
        fetta = double(volume(:,:,i));
        try slope=info.RescaleSlope;
        catch
            slope=1;
        end
        try intercept=info.RescaleIntercept;
        catch
            intercept=0;
        end
        fetta = (fetta-intercept)./slope;
        tipo = class(volume);
        [fetta, ~] = chance_datatype(fetta,tipo);
        dicomwrite(fetta,strcat(files_in_folder(i).folder,'\',files_in_folder(i).name),info,'CreateMode', 'copy');
    end

%         [volume1, ~] = chance_datatype(volume1,tipo);
%         volume1(:,:,j+1:length(files_in_folder))=[];
%         [a1,b1]=find(vettore_index==0);
%         a1(b1==2)=[];
%         b1(b1==2)=[];
%         a1(b1==3)=[];
%         vettore_index(a1(:),:)=[];
%         [~,idx]=sort(vettore_index(:,2));
end
