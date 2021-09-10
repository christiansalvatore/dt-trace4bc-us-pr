function trace4__report_icc(stable__features,racat__features, res_folder, im_type)
    %leggi excel risultati
%     [A,B,feature_tutte]=xlsread('C:\Users\Matteo\Desktop\DEMO\P_USOV001\P_USOV001_202002271142_autoseg-radiomics\P_USOV001_202002271142_autoseg-radiomics-excels\P_USOV001_MAMMOGRAPHY_features.xlsx','Foglio1','A2:L320');
    %leggi array indici featstaabili
%     ovaio='SOLID';
    indici_stabili=stable__features';
    %seleziona feat stabili con descrizione
    racat_feat_str=racat__features(indici_stabili,:);
    %genera pdf
    if strcmp(res_folder(end),'\')
        file_name = strcat(res_folder, im_type,'__STABLE_FEATURES-report.pdf');
    else
        file_name = strcat(res_folder, '\', im_type,'__STABLE_FEATURES-report.pdf');
    end
    
    import mlreportgen.report.*
        import mlreportgen.dom.*
        rpt = Report(file_name,'pdf');
        title = Heading(1,LinkTarget('index'));
        append(title,"Stable Features Report | ");
        txt = Text(im_type);
        append(title,txt);
        title.Style = {Italic,FontFamily('Raleway')};
        add(rpt,title);

    % Add blank line
        blankline(rpt,15);

        global__counter = 1;
%         tab_feat =strcat(input.ct.drive, '\results\', ovaio, '_CT_features.mat');
%         load(tab_feat);
        feat__categories = unique(racat_feat_str(:,1),'stable');
        for i = 1:size(feat__categories,1)
            prg = Heading1(feat__categories{i,1});
            prg.Style = {Italic,FontFamily('Raleway'),FontSize('8pt')};
            add(rpt,prg);
            k = 1;
    %         if i==1
                temp{k,1} = [];
                temp{k,2} = 'Feature Name';
%                 temp{k,3} = 'Value';
                temp{k,3} = 'Unit';
                temp{k,4} = 'Feature details';
                k = k+1;
    %         end
            for j = 1:size(racat_feat_str,1)
                if strcmp(racat_feat_str{j,1},feat__categories{i,1})
                    temp{k,1} = num2str(indici_stabili(global__counter));
                    temp{k,2} = racat_feat_str{j,2};
%                     temp{k,3} = num2str(racat_feat_str{j,11});
                    temp{k,3} = racat_feat_str{j,12};
                    temp{k,4} = strcat(racat_feat_str{j,3},',',racat_feat_str{j,4},',',racat_feat_str{j,6},',',racat_feat_str{j,7},',',racat_feat_str{j,8},',',racat_feat_str{j,9},',',racat_feat_str{j,10});
                    k = k+1;
                    global__counter = global__counter + 1;
                end
            end
            table = Table(temp);
            clear temp;
            table.Style = {Border('single','black','1px'), ...
                       ColSep('single','black','1px'), ...
                       RowSep('single','black','1px'), ...
                       FontSize('6pt'), ...
                       Width('400')};
            add(rpt,table);
        end    

            blankline(rpt,1);

    close(rpt)
end

function blankline(rpt,num)
    import mlreportgen.report.*
    import mlreportgen.dom.*

    prg = Paragraph(" ");
    prg.Style = {WhiteSpace('pre'), ...
        LineSpacing([num2str(num) 'px'])};
    add(rpt,prg);
end