function [ract_feat, racat_feat_values] = ...
    main__Radiomics_Extraction_2D_309_maculo(drive__root, im_type, nome)
    
    % Running RaCat
    %  Note: specifing the absolute paths is necessary.
    %  Change it accordingly!
    %
    %  path to .exe compiled RaCat file
    %  --ini = path to configuration file
    %  --img = path to image file (nifti format)
    %  --voi = path to mask file (nifti format)
    %  --out = path to output csv file

    p = mfilename('fullpath');
    endout = regexp(p,filesep,'split');

    for i = 1:size(endout,2)-1
        if i == 1
            path_exe = endout{1,1};
        else
            path_exe = fullfile(path_exe, endout{1,i});
        end  
    end

    output_path = mkdir__ifnotexist(fullfile(drive__root, 'results'));
    output_name = fullfile(output_path, [im_type '_RacatOutput']);
    
    in_file = dir(fullfile(drive__root, 'volumes', 'vol*'));
    in_mask = dir(fullfile(drive__root, 'volumes', 'mask*'));
    in_config = fullfile(path_exe, 'RaCat', 'config__IBSI-B__2D__MRI.ini');
    vol__path = fullfile(in_file.folder, in_file.name);
    mask__path = fullfile(in_mask.folder, in_mask.name);
%     morpho_struct=morph2Dfeatures(vol__path,mask__path,path_exe);
    command_racat = strcat(...
        '"',path_exe,'"', '\RaCat\RaCaT_v1.4.exe --ini ', {' '},'"', in_config,'"',...
        ' --img ', {' '},'"', vol__path,'"', ' --voi ', {' '},'"', mask__path,'"', ...
        ' --out ', {' '},'"', output_name,'"' ...
        );
 
    command_racat = command_racat{1};
    system(command_racat)

    % Loading .csv files and merging features in a .mat cell
    racat_csv = readtable(strcat(output_name,'.csv'));

    % Read RaCat output csv from line 23 to exclude morphological features
    % note that Splitting name and feature values is necessary because table2array does not manage cell and
    % double formats in the same input)
    tot_feat=size(racat_csv,1);
    racat_feat_name = table2array(racat_csv(1:tot_feat,1:2));
    racat_feat_values = table2array(racat_csv(1:tot_feat,3));
    
    for i = 1:tot_feat
        ract_feat{i,1} = racat_feat_name{i,1};
        ract_feat{i,2} = racat_feat_name{i,2};
        ract_feat{i,3} = racat_feat_values(i,1);
    end 
    tot_feat_temp = tot_feat;
    i=1;

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
    
    % Features final .mat
    full_feat_mat = ract_feat;

    output_name = fullfile(output_path, [im_type '__features.mat']);
    save(output_name, 'full_feat_mat');
    

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
        end
        if count == 0
            elimina = [elimina, i];
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
        racat_units{i,1} = racat_feat_str{i,11};
        racat_units{i,2} = racat_feat_str{i,12};
    end
    
    racat_feat_str(:,6:9)=[];
    
  
%     elseif strcmp(im_type,'CT')
%     for i=1:tot_table1
%         if strcmp(racat_feat_str(i,6),'FB')
%             racat_feat_str{i,7}='FBS:25HU';
%         elseif strcmp(racat_feat_str(i,6),'FB1')
%             racat_feat_str{i,7}='FBS:2.5HU';
%         else
%             racat_feat_str{i,7}='--';
%         end
%         racat_feat_str{i,6}='CT';
%         racat_feat_str{i,8}='LIN:3';
%         racat_feat_str{i,9}='S:2mm';
%         racat_feat_str{i,10}='RS:[-1000,400]';
%         val=ract_feat{i,3};
%         racat_feat_str{i,11}=val;
%         racat_feat_str{i,12}=racat_units{i,2};
%     end
    for i=1:tot_table1
        if strcmp(racat_feat_str(i,6),'FB')
            racat_feat_str{i,7}='FBN:64';
        elseif strcmp(racat_feat_str(i,6),'FB1')
            racat_feat_str{i,7}='FBN:64';
        else
            racat_feat_str{i,7}='--';
        end
        racat_feat_str{i,6}='RG';
        racat_feat_str{i,8}='LIN:2';
        racat_feat_str{i,9}='S:--';
        racat_feat_str{i,10}='RS:--';
        val=ract_feat{i,3};
        racat_feat_str{i,11}=val;
        racat_feat_str{i,12}=racat_units{i,2};
    end
    %erase intensity feat
%     racat_feat_str(1:33,:)=[];
%     old=racat_feat_str;
%     new_racat_feat_str=[morpho_struct; racat_feat_str];
%     racat_feat_str=new_racat_feat_str;
    nome_excel = fullfile(output_path, [nome '__features.xlsx']);
    titles={'Feature Family', 'Feature name', 'Family abbr.', 'Aggregation',...
        'Dimensions','Acquisition','Discretization','Interpolation',...
        'Re-sampling', 'Re-segmentation', 'Feature Value', 'unit'};
    titles=titles';
    racat_feat_str_tras=racat_feat_str';
    xlswrite(nome_excel,titles,'Foglio1','A1')
    xlswrite(nome_excel,racat_feat_str_tras,'Foglio1','B1')
%     xlswrite(nome_excel,racat_feat_str);
    output_name2 = fullfile(output_path, [nome '_' im_type '_features.mat']);
    save(output_name2, 'racat_feat_str');
    
    
end
