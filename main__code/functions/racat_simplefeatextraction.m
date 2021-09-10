function racat_feat_str = racat_simplefeatextraction(in__file, in__mask,...
    img__type, patient__root)
    
    % Running RaCat
    %  Note: specifing the absolute paths is necessary.
    %  Change it accordingly!
    %
    %  path to .exe compiled RaCat file
    %  --ini = path to configuration file
    %  --img = path to image file (nifti format)
    %  --voi = path to mask file (nifti format)
    %  --out = path to output csv file
    volume = load_nii(in__file);
    dimension = size(volume.img);
    if length(dimension) == 3
        if dimension(3) == 1
            dimensiontemp = dimension(1:2);
            dimension = dimensiontemp;
        end
    end
    p = mfilename('fullpath');
    endout = regexp(p, filesep, 'split');

    for i = 1:size(endout,2)-2
        if i == 1
            path_exe = endout{1,1};
        else
            path_exe = strcat(path_exe, '/' ,endout{1,i});
        end  
    end

    output_path = fullfile(patient__root, 'results');
    mkdir__ifnotexist(output_path);
    output_name = fullfile(output_path, [img__type '_RacatOutput']);
    
    if strcmp(img__type, 'PET')
        in_config = strcat(path_exe,'\RaCat\config__IBSI-C__PET.ini');
        in_paz = strcat(path_exe,'\RaCat\patientInfo.ini');
        command_racat = strcat('"',path_exe,'"', '\RaCat\RaCaT_v1.4.exe --ini ', ...
            {' '}, '"',in_config,'"', ' --img ', {' '},'"', in__file,'"', ' --voi ', ...
            {' '}, '"',in__mask,'"', ' --out ', {' '},'"', output_name,'"', ' --pat ', ...
            {' '}, '"',in_paz,'"');
    elseif strcmp(img__type, 'CT') || strcmp(img__type, 'TC')
        if length(dimension) == 3
            if dimension(3) > 1
            in_config = strcat(path_exe,'\RaCat\config__IBSI-C__CT.ini');
            command_racat = strcat('"',path_exe,'"', '\RaCat\RaCaT_v1.4.exe --ini ', ...
                {' '},'"', in_config,'"', ' --img ', {' '}, '"', in__file, '"', ' --voi ', ...
                {' '}, '"', in__mask, '"', ' --out ', {' '}, '"', output_name, '"');
            else
                in_config = strcat(path_exe,'\RaCat\config__IBSI-B__2D__CT_fbn32.ini');
                command_racat = strcat('"',path_exe,'"', '\RaCat\RaCaT_v1.4.exe --ini ', ...
                    {' '},'"', in_config,'"', ' --img ', {' '}, '"', in__file, '"', ' --voi ', ...
                    {' '}, '"', in__mask, '"', ' --out ', {' '}, '"', output_name, '"');
            end
        else
            in_config = strcat(path_exe,'\RaCat\config__IBSI-B__2D__CT_fbn32.ini');
            command_racat = strcat('"',path_exe,'"', '\RaCat\RaCaT_v1.4.exe --ini ', ...
                {' '},'"', in_config,'"', ' --img ', {' '}, '"', in__file, '"', ' --voi ', ...
                {' '}, '"', in__mask, '"', ' --out ', {' '}, '"', output_name, '"');
        end
    elseif strcmp(img__type, 'MAMMOGRAPHY') || strcmp(img__type, 'RX')
        in_config = strcat(path_exe,'\RaCat\config__IBSI-B__2D__CT.ini');
        command_racat = strcat('"',path_exe,'"', '\RaCat\RaCaT_v1.4.exe --ini ', ...
            {' '},'"', in_config,'"', ' --img ', {' '},'"', in__file,'"', ' --voi ', ...
            {' '},'"', in__mask,'"', ' --out ', {' '},'"', output_name,'"');
    elseif strcmp(img__type, 'CYBERKNIFE') || strcmp(img__type, 'MRI')
        in_config = strcat(path_exe, '\RaCat\config__IBSI-C__MRI.ini');
        command_racat = strcat('"',path_exe,'"', '\RaCat\RaCaT_v1.4.exe --ini ', ...
            {' '},'"', in_config,'"', ' --img ', {' '},'"', in__file,'"', ' --voi ', ...
            {' '},'"', in__mask,'"', ' --out ', {' '},'"', output_name,'"');
    elseif strcmp(img__type, 'ADC')
        in_config = strcat(path_exe, '\RaCat\config__IBSI-C__ADC.ini');
        command_racat = strcat('"',path_exe,'"', '\RaCat\RaCaT_v1.4.exe --ini ', ...
            {' '},'"', in_config,'"', ' --img ', {' '},'"', in__file,'"', ' --voi ', ...
            {' '},'"', in__mask,'"', ' --out ', {' '},'"', output_name,'"');
    elseif strcmp(img__type, 'T2')
        in_config = strcat(path_exe, '\RaCat\config__IBSI-C__T2.ini');
        command_racat = strcat('"',path_exe,'"', '\RaCat\RaCaT_v1.4.exe --ini ', ...
            {' '},'"', in_config,'"', ' --img ', {' '},'"', in__file,'"', ' --voi ', ...
            {' '},'"', in__mask,'"', ' --out ', {' '},'"', output_name,'"');
    elseif strcmp(img__type, 'US') || strcmp(img__type, 'RETINOGRAPHY')
        in_config = strcat(path_exe, '\RaCat\config__IBSI-B__2D__MRI.ini');
        command_racat = strcat('"',path_exe,'"', '\RaCat\RaCaT_v1.4.exe --ini ', ...
            {' '},'"', in_config,'"', ' --img ', {' '},'"', in__file,'"', ' --voi ', ...
            {' '},'"', in__mask,'"', ' --out ', {' '},'"', output_name,'"');
    end

    command_racat = command_racat{1};
    system(command_racat)

    % Loading .csv files and merging features in a .mat cell
    racat_csv = readtable(strcat(output_name,'.csv'));

    % Read RaCat output csv from line 23 to exclude morphological features
    % note that Splitting name and feature values is necessary because table2array does not manage cell and
    % double formats in the same input)
    tot_feat = size(racat_csv,1);
    racat_feat_name = table2array(racat_csv(1:tot_feat,1:2));
    racat_feat_values = table2array(racat_csv(1:tot_feat,3));
    
    for i = 1:tot_feat
        ract_feat{i,1} = racat_feat_name{i,1};
        ract_feat{i,2} = racat_feat_name{i,2};
        ract_feat{i,3} = racat_feat_values(i,1);
    end 
    tot_feat_temp = tot_feat;
    i=1;
    
%     if strcmp(img__type, 'MAMMOGRAPHY') || strcmp(img__type, 'RX') || strcmp(img__type, 'RETINOGRAPHY') || strcmp(img__type, 'US') 
    if length(dimension) == 2
        morpho_struct=morph2Dfeatures(in__file,in__mask,path_exe,img__type);
        if strcmp(img__type, 'RX')
            for kk=1:size(morpho_struct,1)
                morpho_struct{kk,6}='RX';
            end
        elseif strcmp(img__type, 'RETINOGRAPHY')
            for kk=1:size(morpho_struct,1)
                morpho_struct{kk,6}='RT';
            end
        elseif strcmp(img__type, 'US')
            for kk=1:size(morpho_struct,1)
                morpho_struct{kk,6}='US';
            end
        else
            for kk=1:size(morpho_struct,1)
                morpho_struct{kk,6}=img__type;
            end
        end
        while i <= tot_feat_temp
            family=ract_feat{i,1};
            if contains(family,'3') || contains(family, 'Morph') % || contains(family, 'mrg')
                ract_feat(i,:) = [];
                tot_feat_temp = tot_feat_temp - 1;
            else
                i = i + 1;
            end
        end

        i=1;
        while i <= tot_feat_temp
            family = ract_feat{i,1};
            feat_name = ract_feat{i,2};
            if strcmp(img__type, 'RETINOGRAPHY')
                if strcmpi(family,'(ind)')
                    ract_feat(i,:)=[];
                    tot_feat_temp = tot_feat_temp - 1;
                elseif strcmpi(family,'Statistics')
                    ract_feat(i,:)=[];
                    tot_feat_temp = tot_feat_temp - 1;
                elseif strcmpi(family,'Local intensity')
                    ract_feat(i,:)=[];
                    tot_feat_temp = tot_feat_temp - 1;
                elseif strcmpi(family,'Intensity histogram')
                        ract_feat(i,:)=[];
                        tot_feat_temp = tot_feat_temp - 1;
                elseif strcmpi(family,'intensity volume')
                        ract_feat(i,:)=[];
                        tot_feat_temp = tot_feat_temp - 1;
                elseif contains(family,'gldzmFeatures2D')
    %                 elseif strcmp(family,'gldzmFeatures2D')
                    if strcmpi(feat_name,'small distance low grey level emphasis gldzm')
                        ract_feat(i,:)=[];
                        tot_feat_temp = tot_feat_temp - 1;
                    else
                        i = i + 1;
                    end
                else
                    i = i + 1;
                end
            else
                if strcmpi(family,'(ind)')
                    ract_feat(i,:)=[];
                    tot_feat_temp = tot_feat_temp - 1;
                elseif strcmpi(family,'Local intensity')
                    ract_feat(i,:)=[];
                    tot_feat_temp = tot_feat_temp - 1;
                elseif strcmpi(family,'Intensity histogram')
                    if strcmpi(feat_name,'minimum') || strcmpi(feat_name,'interquartile range') ||...
                            strcmpi(feat_name,'quartile coefficient')
                        ract_feat(i,:)=[];
                        tot_feat_temp = tot_feat_temp - 1;
                    else
                        i = i + 1;
                    end
                elseif strcmpi(family,'intensity volume')
                    if strcmpi(feat_name,'volume at int fraction 90') ||...
                            strcmpi(feat_name,'int at vol fraction 10')||...
                            strcmpi(feat_name,'int at vol fraction 90')||...
                            strcmpi(feat_name,'difference int at volume fraction')
                        ract_feat(i,:)=[];
                        tot_feat_temp = tot_feat_temp - 1;
                    else
                        i = i + 1;
                    end
                elseif contains(family,'gldzmFeatures2D')
                    if strcmpi(feat_name,'small distance low grey level emphasis gldzm')
                        ract_feat(i,:)=[];
                        tot_feat_temp = tot_feat_temp - 1;
                    else
                        i = i + 1;
                    end
                else
                    i = i + 1;
                end
            end
            
        end

        racat_table = readtable(strcat(path_exe,'\RaCat\dataframe_IBSI__RaCaT__nomenclature.csv'));
        tot_table=size(racat_table,1);
        feat__categories = unique(ract_feat(:,1));
        racat_feat_name = table2array(racat_table(1:tot_table,9));
        racat_feat_name2 = table2array(racat_table(1:tot_table,2));
        elimina=[0, 0];
        for i=1:tot_table
            count=0;
            for j=1:size(feat__categories,1)
                if strcmpi(racat_feat_name(i),feat__categories(j))
                    count=count+1;
                end
            end
            if count>0
                if strcmp(img__type, 'RETINOGRAPHY')
                    if strcmpi(racat_feat_name(i),'Local intensity')
                        count=count-1;
                    elseif strcmpi(racat_feat_name(i),'Statistics')
                        count=count-1;
                    elseif strcmpi(racat_feat_name(i),'Intensity histogram')
                        count=count-1;
                    elseif strcmpi(racat_feat_name(i),'intensity volume')
                        count=count-1;
                    elseif contains(racat_feat_name(i),'gldzmFeatures2D') && strcmpi(racat_feat_name2(i),'small distance low grey level emphasis gldzm')
                        count=count-1;
                    end
                else
                    if strcmpi(racat_feat_name(i),'Local intensity')
                        count=count-1;
                    elseif strcmpi(racat_feat_name(i),'Intensity histogram') && (strcmpi(racat_feat_name2(i),'minimum')...
                            || strcmpi(racat_feat_name2(i),'interquartile range') ||...
                            strcmpi(racat_feat_name2(i),'quartile coefficient'))
                        count=count-1;
                    elseif strcmpi(racat_feat_name(i),'intensity volume') && (strcmpi(racat_feat_name2(i),'volume at int fraction 90')||...
                            strcmpi(racat_feat_name2(i),'int at vol fraction 10') ||...
                            strcmpi(racat_feat_name2(i),'int at vol fraction 90') ||...
                            strcmpi(racat_feat_name2(i),'difference int at volume fraction'))
                        count=count-1;
                    elseif contains(racat_feat_name(i),'gldzmFeatures2D') && strcmpi(racat_feat_name2(i),'small distance low grey level emphasis gldzm')
                        count=count-1;
                    end
                end
                
            end
            if count == 0
                elimina = [elimina, i];
            end
        end
    else
        while i <= tot_feat_temp
            family=ract_feat{i,1};
            if contains(family,'2')
                ract_feat(i,:)=[];
                tot_feat_temp = tot_feat_temp - 1;
            else
                i = i + 1;
            end
        end

        i=1;
        while i <= tot_feat_temp
            family=ract_feat{i,1};
            feat_name=ract_feat{i,2};
            if strcmpi(family,'Morphology')                
                if strcmpi(feat_name,'Compactness1') || strcmpi(feat_name,'Compactness2') ||...
                        strcmpi(feat_name,'Asphericity') || strcmpi(feat_name,'Flatness') ||...
                        strcmpi(feat_name,'Morans i')
                    ract_feat(i,:)=[];
                    tot_feat_temp = tot_feat_temp - 1;
                else
                    i = i + 1;
                end
            elseif strcmpi(family,'(ind)')
                ract_feat(i,:)=[];
                tot_feat_temp = tot_feat_temp - 1;
            elseif strcmpi(family,'Local intensity')
                ract_feat(i,:)=[];
                tot_feat_temp = tot_feat_temp - 1;
            elseif strcmpi(family,'Intensity histogram')
                if strcmpi(feat_name,'minimum') || strcmpi(feat_name,'interquartile range') ||...
                        strcmpi(feat_name,'quartile coefficient')
                    ract_feat(i,:)=[];
                    tot_feat_temp = tot_feat_temp - 1;
                else
                    i = i + 1;
                end
            elseif strcmpi(family,'intensity volume')
                if strcmpi(feat_name,'volume at int fraction 90') ||...
                        strcmpi(feat_name,'int at vol fraction 10')||...
                        strcmpi(feat_name,'int at vol fraction 90')||...
                        strcmpi(feat_name,'difference int at volume fraction')
                    ract_feat(i,:)=[];
                    tot_feat_temp = tot_feat_temp - 1;
                else
                    i = i + 1;
                end
            elseif strcmpi(family,'gldzmFeatures3D')
                if strcmpi(feat_name,'small distance low grey level emphasis gldzm')
                    ract_feat(i,:)=[];
                    tot_feat_temp = tot_feat_temp - 1;
                else
                    i = i + 1;
                end
            else
                i = i + 1;
            end
        end

        racat_table = readtable(strcat(path_exe,'\RaCat\dataframe_IBSI__RaCaT__nomenclature.csv'));
        tot_table=size(racat_table,1);
        feat__categories = unique(ract_feat(:,1));
        racat_feat_name = table2array(racat_table(1:tot_table,9));
        racat_feat_name2 = table2array(racat_table(1:tot_table,2));
        elimina=[0, 0];
        for i=1:tot_table
            count=0;
            for j=1:size(feat__categories,1)
                if strcmpi(racat_feat_name(i),feat__categories(j))
                    count=count+1;
                end
            end
            if count>0
                if strcmpi(racat_feat_name(i),'Morphology') && (strcmpi(racat_feat_name2(i),'compactness1')...
                        || strcmpi(racat_feat_name2(i),'compactness2')|| strcmpi(racat_feat_name2(i),'asphericity')...
                        || strcmpi(racat_feat_name2(i),'flatness')|| strcmpi(racat_feat_name2(i),'morans i'))
                    count=count-1;
                elseif strcmpi(racat_feat_name(i),'Local intensity')
                    count=count-1;
                elseif strcmpi(racat_feat_name(i),'Intensity histogram') && (strcmpi(racat_feat_name2(i),'minimum')...
                        || strcmpi(racat_feat_name2(i),'interquartile range') ||...
                        strcmpi(racat_feat_name2(i),'quartile coefficient'))
                    count=count-1;
                elseif strcmpi(racat_feat_name(i),'intensity volume') && (strcmpi(racat_feat_name2(i),'volume at int fraction 90')||...
                        strcmpi(racat_feat_name2(i),'int at vol fraction 10') ||...
                        strcmpi(racat_feat_name2(i),'int at vol fraction 90') ||...
                        strcmpi(racat_feat_name2(i),'difference int at volume fraction'))
                    count=count-1;
                elseif contains(racat_feat_name(i),'gldzmFeatures3D') && strcmpi(racat_feat_name2(i),'small distance low grey level emphasis gldzm')
                    count=count-1;
                end
            end
            if count==0
                elimina=[elimina, i];
            end
        end
    end
    
    elimina(1:2)=[];
    racat_table1=racat_table;
    for i=1:length(elimina)
        row=elimina(length(elimina)-i+1);
        racat_table1(row,:)=[];
    end
    tot_table1=size(racat_table1,1);
    racat_feat_str = table2array(racat_table1(1:tot_table1,:));
    for i=1:tot_table1
        racat_units{i,1}=racat_feat_str{i,11};
        racat_units{i,2}=racat_feat_str{i,12};
        racat_units{i,3}=racat_feat_str{i,13};
    end
    
    racat_feat_str(:,6:9)=[];
    
    if strcmpi(img__type,'PET')
        for i=1:tot_table1
            if strcmpi(racat_feat_str(i,6),'FB')
                racat_feat_str{i,7}='FBN:64';
            else
                racat_feat_str{i,7}='--';
            end
            racat_feat_str{i,6}='PET';
            racat_feat_str{i,8}='LIN:3';
            racat_feat_str{i,9}='S:DS';
            racat_feat_str{i,10}='RS:--';
            val=ract_feat{i,3};
            racat_feat_str{i,11}=val;
            racat_feat_str{i,12}=racat_units{i,1};
        end
    elseif strcmpi(img__type,'CT') || strcmpi(img__type,'TC')
        if length(dimension) == 3
            for i=1:tot_table1
                if strcmpi(racat_feat_str(i,6),'FB')
                    racat_feat_str{i,7}='FBS:25HU';
                elseif strcmpi(racat_feat_str(i,6),'FB1')
                    racat_feat_str{i,7}='FBS:2.5HU';
                else
                    racat_feat_str{i,7}='--';
                end
                racat_feat_str{i,6}='CT';
                racat_feat_str{i,8}='LIN:3';
                racat_feat_str{i,9}='S:2mm';
                racat_feat_str{i,10}='RS:[-1000,400]';
                val=ract_feat{i,3};
                racat_feat_str{i,11}=val;
                racat_feat_str{i,12}=racat_units{i,2};
            end
        else
            for i=1:tot_table1
                if strcmpi(racat_feat_str(i,6),'FB')
                    racat_feat_str{i,7}='FBN:32';
                elseif strcmpi(racat_feat_str(i,6),'FB1')
                    racat_feat_str{i,7}='--';
                else
                    racat_feat_str{i,7}='--';
                end
                racat_feat_str{i,6}='CT';
                racat_feat_str{i,8}='LIN:2';
                racat_feat_str{i,9}='S:1mm';
                racat_feat_str{i,10}='RS:[-500,400]';
                val=ract_feat{i,3};
                racat_feat_str{i,11}=val;
                racat_feat_str{i,12}=racat_units{i,2};
            end
            racat_feat_str=[morpho_struct; racat_feat_str];
        end
    elseif strcmpi(img__type,'MAMMOGRAPHY')
        for i=1:tot_table1
            if strcmpi(racat_feat_str(i,6),'FB')
                racat_feat_str{i,7}='FBN:64';
            elseif strcmpi(racat_feat_str(i,6),'FB1')
                racat_feat_str{i,7}='--';
            else
                racat_feat_str{i,7}='--';
            end
            racat_feat_str{i,6}='MAM';
            racat_feat_str{i,8}='LIN:2';
            racat_feat_str{i,9}='S:1mm';
            racat_feat_str{i,10}='RS:--';
            val=ract_feat{i,3};
            racat_feat_str{i,11}=val;
            racat_feat_str{i,12}='--';
        end
        racat_feat_str=[morpho_struct; racat_feat_str];
    elseif strcmpi(img__type,'RX')
        for i=1:tot_table1
            if strcmpi(racat_feat_str(i,6),'FB')
                racat_feat_str{i,7}='FBN:64';
            elseif strcmpi(racat_feat_str(i,6),'FB1')
                racat_feat_str{i,7}='--';
            else
                racat_feat_str{i,7}='--';
            end
            racat_feat_str{i,6}='RX';
            racat_feat_str{i,8}='LIN:2';
            racat_feat_str{i,9}='S:1mm';
            racat_feat_str{i,10}='RS:--';
            val=ract_feat{i,3};
            racat_feat_str{i,11}=val;
            racat_feat_str{i,12}='--';
        end
        racat_feat_str=[morpho_struct; racat_feat_str];
    elseif strcmpi(img__type,'RETINOGRAPHY')
        for i=1:tot_table1
            if strcmpi(racat_feat_str(i,6),'FB')
                racat_feat_str{i,7}='FBN:64';
            elseif strcmpi(racat_feat_str(i,6),'FB1')
                racat_feat_str{i,7}='--';
            else
                racat_feat_str{i,7}='--';
            end
            racat_feat_str{i,6}='RT';
            racat_feat_str{i,8}='LIN:2';
            racat_feat_str{i,9}='S:--';
            racat_feat_str{i,10}='RS:--';
            val=ract_feat{i,3};
            racat_feat_str{i,11}=val;
            racat_feat_str{i,12}='--';
        end
%         racat_feat_str=[morpho_struct; racat_feat_str];
    elseif strcmpi(img__type,'US')
        for i=1:tot_table1
            if strcmpi(racat_feat_str(i,6),'FB')
                racat_feat_str{i,7}='FBN:64';
            elseif strcmpi(racat_feat_str(i,6),'FB1')
                racat_feat_str{i,7}='--';
            else
                racat_feat_str{i,7}='--';
            end
            racat_feat_str{i,6}='US';
            racat_feat_str{i,8}='LIN:2';
            racat_feat_str{i,9}='S:1mm';
            racat_feat_str{i,10}='RS:--';
            val=ract_feat{i,3};
            racat_feat_str{i,11}=val;
            racat_feat_str{i,12}='--';
        end
        racat_feat_str=[morpho_struct; racat_feat_str];
    elseif strcmpi(img__type,'CYBERKNIFE') || strcmpi(img__type,'MRI')
        for i=1:tot_table1
            if strcmpi(racat_feat_str(i,6),'FB')
                racat_feat_str{i,7}='FBN:64';
            else
                racat_feat_str{i,7}='--';
            end
            racat_feat_str{i,6}='MRI';
            racat_feat_str{i,8}='LIN:3';
            racat_feat_str{i,9}='S:2mm';
            racat_feat_str{i,10}='RS:--';
            val=ract_feat{i,3};
            racat_feat_str{i,11}=val;
            racat_feat_str{i,12}=racat_units{i,3};
        end
    elseif strcmpi(img__type,'T2')
        for i=1:tot_table1
            if strcmpi(racat_feat_str(i,6),'FB')
                racat_feat_str{i,7}='FBN:64';
            else
                racat_feat_str{i,7}='--';
            end
            racat_feat_str{i,6}='MRI-T2';
            racat_feat_str{i,8}='LIN:3';
            racat_feat_str{i,9}='S:2mm';
            racat_feat_str{i,10}='RS:--';
            val=ract_feat{i,3};
            racat_feat_str{i,11}=val;
            racat_feat_str{i,12}=racat_units{i,3};
        end
    elseif strcmpi(img__type,'ADC')
        for i=1:tot_table1
            if strcmpi(racat_feat_str(i,6),'FB')
                racat_feat_str{i,7}='FBN:64';
            else
                racat_feat_str{i,7}='--';
            end
            racat_feat_str{i,6}='MRI-ADC';
            racat_feat_str{i,8}='LIN:3';
            racat_feat_str{i,9}='S:DS';
            racat_feat_str{i,10}='RS:--';
            val=ract_feat{i,3};
            racat_feat_str{i,11}=val;
            racat_feat_str{i,12}=racat_units{i,3};
        end
    end 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     racat_feat_str = racat_feat_str(1:9, :);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Remove output folder with subfolders and files
    rmdir(output_path,'s');
end
