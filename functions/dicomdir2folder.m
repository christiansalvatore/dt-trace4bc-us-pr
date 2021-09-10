function output = dicomdir2folder(app)
    output.path = [];
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
%                 list_files = dir(series_path);
%                 j = 0;
%                 
%                 while j<=length(list_files)
%                     j=j+1;
%                     try info = dicominfo(fullfile(list_files(j).folder,list_files(j).name));
%                         j = length(list_files)+1;
%                     catch
%                         
%                     end
%                 end


            output.path = series_path;
%                         output.name = lista_nifti(idx(end)).name;
        end
    catch
    end
end