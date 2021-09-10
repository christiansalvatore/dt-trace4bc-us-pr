function racat_feat_str  = structure_radiomics(morpho_struct, radiomics_out, img__type, is3D, rad_settings)
    p = mfilename('fullpath');
    endout = regexp(p, filesep, 'split');
    for i = 1:size(endout,2)-2
        if i == 1
            path_exe = endout{1,1};
        else
            path_exe = strcat(path_exe, '/' ,endout{1,i});
        end  
    end
    if is3D
        racat_table = readtable(strcat(path_exe,'\feature_nomenclature\dataframe_IBSI__nomenclature_3D.csv'));
    else
        racat_table = readtable(strcat(path_exe,'\feature_nomenclature\dataframe_IBSI__nomenclature_2D.csv'));
    end
    
    tot_table1=size(racat_table,1);
    ract_feat = radiomics_out;
    if ~is3D
        if ~strcmp(class(ract_feat(1,1)),class(morpho_struct(1,1)))
            for i = 1 : size(morpho_struct,1)
                morpho_struct(i,1)=double(morpho_struct(i,1));
            end
            ract_feat = double(ract_feat);
        end
        ract_feat = [morpho_struct; ract_feat];
    else
        ract_feat = double(ract_feat);
    end
    racat_feat_str = table2array(racat_table(1:tot_table1,:));
    for i=1:tot_table1
        racat_units{i,1}=racat_feat_str{i,11};
        racat_units{i,2}=racat_feat_str{i,12};
        racat_units{i,3}=racat_feat_str{i,13};
    end
    
    racat_feat_str(:,6:9)=[];
    
    if strcmpi(img__type,'PET')
        for i=1:tot_table1
            if strcmpi(racat_feat_str(i,6),'FB')
                racat_feat_str{i,7}=strcat(rad_settings.discretisation.IH.type,':',num2str(rad_settings.discretisation.IH.val));
            elseif strcmpi(racat_feat_str(i,6),'FBT')
                racat_feat_str{i,7}=strcat(rad_settings.discretisation.texture.type{1},':',num2str(rad_settings.discretisation.texture.val{1}));
            else
                racat_feat_str{i,7}='--';
            end
            racat_feat_str{i,6}='PET';
            racat_feat_str{i,8}='LIN:3';
            racat_feat_str{i,9}=strcat('S:',num2str(rad_settings.out_pix_dim),'mm');
            if ~isempty(rad_settings.reSeg.range)
                racat_feat_str{i,10}=strcat('RS:[',num2str(rad_settings.reSeg.range(1)),',',num2str(rad_settings.reSeg.range(2)),']');
            else
                racat_feat_str{i,10}='RS:--';
            end
            val=ract_feat(i,1);
            racat_feat_str{i,11}=val;
            racat_feat_str{i,12}=racat_units{i,1};
        end
    elseif strcmpi(img__type,'CT') || strcmpi(img__type,'TC')
        if is3D
            for i=1:tot_table1
                if strcmpi(racat_feat_str(i,6),'FB')
                    racat_feat_str{i,7}=strcat(rad_settings.discretisation.IH.type,':',num2str(rad_settings.discretisation.IH.val));
                elseif strcmpi(racat_feat_str(i,6),'FBT')
                    racat_feat_str{i,7}=strcat(rad_settings.discretisation.texture.type{1},':',num2str(rad_settings.discretisation.texture.val{1}));
                else
                    racat_feat_str{i,7}='--';
                end
%                 if strcmpi(racat_feat_str(i,6),'FB')
%                     racat_feat_str{i,7}='FBS:25HU';
%                 elseif strcmpi(racat_feat_str(i,6),'FB1')
%                     racat_feat_str{i,7}='FBS:2.5HU';
%                 else
%                     racat_feat_str{i,7}='--';
%                 end
                racat_feat_str{i,6}='CT';
                racat_feat_str{i,8}='LIN:3';
                racat_feat_str{i,9}=strcat('S:',num2str(rad_settings.out_pix_dim),'mm');
                if ~isempty(rad_settings.reSeg.range)
                    racat_feat_str{i,10}=strcat('RS:[',num2str(rad_settings.reSeg.range(1)),',',num2str(rad_settings.reSeg.range(2)),']');
                else
                    racat_feat_str{i,10}='RS:--';
                end
                
                val=ract_feat(i,1);
                racat_feat_str{i,11}=val;
                racat_feat_str{i,12}=racat_units{i,2};
            end
        else
            for i=1:tot_table1
                if strcmpi(racat_feat_str(i,6),'FB')
                    racat_feat_str{i,7}=strcat(rad_settings.discretisation.IH.type,':',num2str(rad_settings.discretisation.IH.val));
                elseif strcmpi(racat_feat_str(i,6),'FBT')
                    racat_feat_str{i,7}=strcat(rad_settings.discretisation.texture.type{1},':',num2str(rad_settings.discretisation.texture.val{1}));
                else
                    racat_feat_str{i,7}='--';
                end
%                 if strcmpi(racat_feat_str(i,6),'FB')
%                     racat_feat_str{i,7}='FBN:32';
%                 elseif strcmpi(racat_feat_str(i,6),'FB1')
%                     racat_feat_str{i,7}='--';
%                 else
%                     racat_feat_str{i,7}='--';
%                 end
                racat_feat_str{i,6}='CT';
                racat_feat_str{i,8}='LIN:2';
                racat_feat_str{i,9}=strcat('S:',num2str(rad_settings.out_pix_dim),'mm');
                if ~isempty(rad_settings.reSeg.range)
                    racat_feat_str{i,10}=strcat('RS:[',num2str(rad_settings.reSeg.range(1)),',',num2str(rad_settings.reSeg.range(2)),']');
                else
                    racat_feat_str{i,10}='RS:--';
                end
                val=ract_feat(i,1);
                racat_feat_str{i,11}=val;
                racat_feat_str{i,12}=racat_units{i,2};
            end
%             racat_feat_str=[morpho_struct; racat_feat_str];
        end
    elseif strcmpi(img__type,'MAMMOGRAPHY')
        for i=1:tot_table1
            if strcmpi(racat_feat_str(i,6),'FB')
                racat_feat_str{i,7}=strcat(rad_settings.discretisation.IH.type,':',num2str(rad_settings.discretisation.IH.val));
            elseif strcmpi(racat_feat_str(i,6),'FBT')
                racat_feat_str{i,7}=strcat(rad_settings.discretisation.texture.type{1},':',num2str(rad_settings.discretisation.texture.val{1}));
            else
                racat_feat_str{i,7}='--';
            end
%             if strcmpi(racat_feat_str(i,6),'FB')
%                 racat_feat_str{i,7}='FBN:64';
%             elseif strcmpi(racat_feat_str(i,6),'FB1')
%                 racat_feat_str{i,7}='--';
%             else
%                 racat_feat_str{i,7}='--';
%             end
            racat_feat_str{i,6}='MAM';
            racat_feat_str{i,8}='LIN:2';
            racat_feat_str{i,9}=strcat('S:',num2str(rad_settings.out_pix_dim),'mm');
            if ~isempty(rad_settings.reSeg.range)
                racat_feat_str{i,10}=strcat('RS:[',num2str(rad_settings.reSeg.range(1)),',',num2str(rad_settings.reSeg.range(2)),']');
            else
                racat_feat_str{i,10}='RS:--';
            end
            val=ract_feat(i,1);
            racat_feat_str{i,11}=val;
            racat_feat_str{i,12}=racat_units{i,3};
        end
%         racat_feat_str=[morpho_struct; racat_feat_str];
    elseif strcmpi(img__type,'RX')
        for i=1:tot_table1
            if strcmpi(racat_feat_str(i,6),'FB')
                racat_feat_str{i,7}=strcat(rad_settings.discretisation.IH.type,':',num2str(rad_settings.discretisation.IH.val));
            elseif strcmpi(racat_feat_str(i,6),'FBT')
                racat_feat_str{i,7}=strcat(rad_settings.discretisation.texture.type{1},':',num2str(rad_settings.discretisation.texture.val{1}));
            else
                racat_feat_str{i,7}='--';
            end
%             if strcmpi(racat_feat_str(i,6),'FB')
%                 racat_feat_str{i,7}='FBN:64';
%             elseif strcmpi(racat_feat_str(i,6),'FB1')
%                 racat_feat_str{i,7}='--';
%             else
%                 racat_feat_str{i,7}='--';
%             end
            racat_feat_str{i,6}='RX';
            racat_feat_str{i,8}='LIN:2';
            racat_feat_str{i,9}=strcat('S:',num2str(rad_settings.out_pix_dim),'mm');
            if ~isempty(rad_settings.reSeg.range)
                racat_feat_str{i,10}=strcat('RS:[',num2str(rad_settings.reSeg.range(1)),',',num2str(rad_settings.reSeg.range(2)),']');
            else
                racat_feat_str{i,10}='RS:--';
            end
            val=ract_feat(i,1);
            racat_feat_str{i,11}=val;
            racat_feat_str{i,12}=racat_units{i,3};
        end
%         racat_feat_str=[morpho_struct; racat_feat_str];
    elseif strcmpi(img__type,'RETINOGRAPHY')
        for i=1:tot_table1
            if strcmpi(racat_feat_str(i,6),'FB')
                racat_feat_str{i,7}=strcat(rad_settings.discretisation.IH.type,':',num2str(rad_settings.discretisation.IH.val));
            elseif strcmpi(racat_feat_str(i,6),'FBT')
                racat_feat_str{i,7}=strcat(rad_settings.discretisation.texture.type{1},':',num2str(rad_settings.discretisation.texture.val{1}));
            else
                racat_feat_str{i,7}='--';
            end
%             if strcmpi(racat_feat_str(i,6),'FB')
%                 racat_feat_str{i,7}='FBN:64';
%             elseif strcmpi(racat_feat_str(i,6),'FB1')
%                 racat_feat_str{i,7}='--';
%             else
%                 racat_feat_str{i,7}='--';
%             end
            racat_feat_str{i,6}='RT';
            racat_feat_str{i,8}='LIN:2';
            racat_feat_str{i,9}='S:--';
            if ~isempty(rad_settings.reSeg.range)
                racat_feat_str{i,10}=strcat('RS:[',num2str(rad_settings.reSeg.range(1)),',',num2str(rad_settings.reSeg.range(2)),']');
            else
                racat_feat_str{i,10}='RS:--';
            end
            val=ract_feat(i,1);
            racat_feat_str{i,11}=val;
            racat_feat_str{i,12}=racat_units{i,3};
        end
%         racat_feat_str=[morpho_struct; racat_feat_str];
    elseif strcmpi(img__type,'US')
        for i=1:tot_table1
            if strcmpi(racat_feat_str(i,6),'FB')
                racat_feat_str{i,7}=strcat(rad_settings.discretisation.IH.type,':',num2str(rad_settings.discretisation.IH.val));
            elseif strcmpi(racat_feat_str(i,6),'FBT')
                racat_feat_str{i,7}=strcat(rad_settings.discretisation.texture.type{1},':',num2str(rad_settings.discretisation.texture.val{1}));
            else
                racat_feat_str{i,7}='--';
            end
%             if strcmpi(racat_feat_str(i,6),'FB')
%                 racat_feat_str{i,7}='FBN:64';
%             elseif strcmpi(racat_feat_str(i,6),'FB1')
%                 racat_feat_str{i,7}='--';
%             else
%                 racat_feat_str{i,7}='--';
%             end
            racat_feat_str{i,6}='US';
            racat_feat_str{i,8}='LIN:2';
            racat_feat_str{i,9}=strcat('S:',num2str(rad_settings.out_pix_dim),'mm');
            if ~isempty(rad_settings.reSeg.range)
                racat_feat_str{i,10}=strcat('RS:[',num2str(rad_settings.reSeg.range(1)),',',num2str(rad_settings.reSeg.range(2)),']');
            else
                racat_feat_str{i,10}='RS:--';
            end
            val=ract_feat(i,1);
            racat_feat_str{i,11}=val;
            racat_feat_str{i,12}=racat_units{i,3};
        end
%         racat_feat_str=[morpho_struct; racat_feat_str];
    elseif strcmpi(img__type,'CYBERKNIFE') || strcmpi(img__type,'MRI')
        for i=1:tot_table1
            if strcmpi(racat_feat_str(i,6),'FB')
                racat_feat_str{i,7}=strcat(rad_settings.discretisation.IH.type,':',num2str(rad_settings.discretisation.IH.val));
            elseif strcmpi(racat_feat_str(i,6),'FBT')
                racat_feat_str{i,7}=strcat(rad_settings.discretisation.texture.type{1},':',num2str(rad_settings.discretisation.texture.val{1}));
            else
                racat_feat_str{i,7}='--';
            end
%             if strcmpi(racat_feat_str(i,6),'FB')
%                 racat_feat_str{i,7}='FBN:64';
%             else
%                 racat_feat_str{i,7}='--';
%             end
            racat_feat_str{i,6}='MRI';
            racat_feat_str{i,8}='LIN:3';
            racat_feat_str{i,9}=strcat('S:',num2str(rad_settings.out_pix_dim),'mm');
            if ~isempty(rad_settings.reSeg.range)
                racat_feat_str{i,10}=strcat('RS:[',num2str(rad_settings.reSeg.range(1)),',',num2str(rad_settings.reSeg.range(2)),']');
            else
                racat_feat_str{i,10}='RS:--';
            end
            val=ract_feat(i,1);
            racat_feat_str{i,11}=val;
            racat_feat_str{i,12}=racat_units{i,3};
        end
    elseif strcmpi(img__type,'T2')
        for i=1:tot_table1
            if strcmpi(racat_feat_str(i,6),'FB')
                racat_feat_str{i,7}=strcat(rad_settings.discretisation.IH.type,':',num2str(rad_settings.discretisation.IH.val));
            elseif strcmpi(racat_feat_str(i,6),'FBT')
                racat_feat_str{i,7}=strcat(rad_settings.discretisation.texture.type{1},':',num2str(rad_settings.discretisation.texture.val{1}));
            else
                racat_feat_str{i,7}='--';
            end
            racat_feat_str{i,6}='MRI-T2';
            racat_feat_str{i,8}='LIN:3';
            racat_feat_str{i,9}=strcat('S:',num2str(rad_settings.out_pix_dim),'mm');
            if ~isempty(rad_settings.reSeg.range)
                racat_feat_str{i,10}=strcat('RS:[',num2str(rad_settings.reSeg.range(1)),',',num2str(rad_settings.reSeg.range(2)),']');
            else
                racat_feat_str{i,10}='RS:--';
            end
            val=ract_feat(i,1);
            racat_feat_str{i,11}=val;
            racat_feat_str{i,12}=racat_units{i,3};
        end
    elseif strcmpi(img__type,'ADC')
        for i=1:tot_table1
            if strcmpi(racat_feat_str(i,6),'FB')
                racat_feat_str{i,7}=strcat(rad_settings.discretisation.IH.type,':',num2str(rad_settings.discretisation.IH.val));
            elseif strcmpi(racat_feat_str(i,6),'FBT')
                racat_feat_str{i,7}=strcat(rad_settings.discretisation.texture.type{1},':',num2str(rad_settings.discretisation.texture.val{1}));
            else
                racat_feat_str{i,7}='--';
            end
            racat_feat_str{i,6}='MRI-ADC';
            racat_feat_str{i,8}='LIN:3';
            racat_feat_str{i,9}=strcat('S:',num2str(rad_settings.out_pix_dim),'mm');
            if ~isempty(rad_settings.reSeg.range)
                racat_feat_str{i,10}=strcat('RS:[',num2str(rad_settings.reSeg.range(1)),',',num2str(rad_settings.reSeg.range(2)),']');
            else
                racat_feat_str{i,10}='RS:--';
            end
            val=ract_feat(i,1);
            racat_feat_str{i,11}=val;
            racat_feat_str{i,12}=racat_units{i,3};
        end
    end
%     feat__categories = unique(racat_table(:,1));
%     racat_feat_name = table2array(racat_table(1:tot_table,9));
%     racat_feat_name2 = table2array(racat_table(1:tot_table,2));
%     elimina=[];
%     for i=1:tot_table
%         count=0;
%         for j=1:size(feat__categories,1)
%             if strcmpi(racat_feat_name(i),feat__categories(j))
%                 count=count+1;
%             end
%         end
%         if count>0
%             if strcmp(img__type, 'RETINOGRAPHY')
%                 if strcmpi(racat_feat_name(i),'Local intensity')
%                     count=count-1;
%                 elseif strcmpi(racat_feat_name(i),'Statistics')
%                     count=count-1;
%                 elseif strcmpi(racat_feat_name(i),'Intensity histogram')
%                     count=count-1;
%                 elseif strcmpi(racat_feat_name(i),'intensity volume')
%                     count=count-1;
%                 elseif contains(racat_feat_name(i),'gldzmFeatures2D') && strcmpi(racat_feat_name2(i),'small distance low grey level emphasis gldzm')
%                     count=count-1;
%                 end
%             else
%                 if strcmpi(racat_feat_name(i),'Local intensity')
%                     count=count-1;
%                 elseif strcmpi(racat_feat_name(i),'Intensity histogram') && (strcmpi(racat_feat_name2(i),'minimum')...
%                         || strcmpi(racat_feat_name2(i),'interquartile range') ||...
%                         strcmpi(racat_feat_name2(i),'quartile coefficient'))
%                     count=count-1;
%                 elseif strcmpi(racat_feat_name(i),'intensity volume') && (strcmpi(racat_feat_name2(i),'volume at int fraction 90')||...
%                         strcmpi(racat_feat_name2(i),'int at vol fraction 10') ||...
%                         strcmpi(racat_feat_name2(i),'int at vol fraction 90') ||...
%                         strcmpi(racat_feat_name2(i),'difference int at volume fraction'))
%                     count=count-1;
%                 elseif contains(racat_feat_name(i),'gldzmFeatures2D') && strcmpi(racat_feat_name2(i),'small distance low grey level emphasis gldzm')
%                     count=count-1;
%                 end
%             end
% 
%         end
%         if count == 0
%             elimina = [elimina, i];
%         end
%     end