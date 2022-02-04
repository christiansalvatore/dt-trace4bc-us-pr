% function trace4bus__testreport(out_risk, patient__name, path_save, second)
function file_name = trace4bus__testreport(out_risk, patient__name, path_save,extra_text)
% TRACE4AD © 2019 DeepTrace Technologies S.R.L.

makeDOMCompilable(); 


    lista = dir(fullfile(path_save,strcat(patient__name,'*repor*')));
    if ~isempty(lista)
        file_name = fullfile(path_save, ...
        [patient__name, '__report(', num2str(length(lista)),').pdf']);
    else
        file_name = fullfile(path_save, ...
        [patient__name, '__report.pdf']);
    end
    

% Create report object
    import mlreportgen.report.*
    import mlreportgen.dom.*
    rpt = Report(file_name,'pdf');

% Add date
    prg = Paragraph("File-creation date: ");
    prg.Style = {HAlign('right'), FontSize('10')};

    adesso = datestr(datetime);
    txt = Text(adesso);
    append(prg,txt);
    
    add(rpt,prg);
    
% Add title
    title = Heading(1,LinkTarget('index'));
    append(title,"TRACE4BUS | Report ");
    title.Style = {Italic,FontFamily('Raleway')};
    % add(rpt,title);

% Add patient's name
    max__str = 68;
    try 

        txt = Text(patient__name);
        append(title,txt);
        add(rpt,title);
        
    catch
        
        if size(patient__name, 2) > max__str
            mod__ = mod(size(patient__name, 2), max__str);
            mod__name = [patient__name repmat(' ', 1, max__str - mod__)];
            temp__name = cellstr(reshape(mod__name, max__str, [])');
            for i__ = 1:ceil(size(patient__name, 2) / max__str)
                parag = Paragraph([temp__name{i__, 1} ' ']);
                add(rpt, parag);
            end
        else
            txt = Text(patient__name);
            append(title,txt);
            add(rpt,title);   
        end
    
    end
    


prg = Paragraph(out_risk);

add(rpt,prg);

% Add blank line
    blankline(rpt,10);
if contains(out_risk,'BI-RADS 2')
    title = Heading(1,LinkTarget('mg'));
    append(title,"US native image of the breast mass");

        title.Style = {HAlign('center'), Italic, FontFamily('Raleway'), FontSize('12')};
        add(rpt,title);

        images{1} = Image(strcat(path_save,'volumes\image_nomask.png'));
        images{1}.Style = {Width('3.1in'), HAlign('center')};
    
        t = Table(images(1)); 
        t.Border = 'none';
        t.TableEntriesInnerMargin = '1pt';
        t.Style = {HAlign('center')};
    add(rpt,t);
else
    title = Heading(1,LinkTarget('mg'));
    append(title,"US native image (left) and with manually drawn ROI of the breast mass (right)");

        title.Style = {HAlign('left'), Italic, FontFamily('Raleway'), FontSize('12')};
        add(rpt,title);

        images{1} = Image(strcat(path_save,'volumes\image_nomask.png'));
        images{1}.Style = {Width('3.1in'), HAlign('left')};
        images{2} = Image(strcat(path_save,'volumes\image_mask.png'));
        images{2}.Style = {Width('3.1in'), HAlign('left')};

        
                t = Table({images{1}, images{2}});
            t.Border = 'none';
            t.TableEntriesInnerMargin = '1pt';
            t.Style = {HAlign('left')};
            add(rpt,t);
end
    

    blankline(rpt,10);   
    if ~isempty(extra_text)
        title = Heading(1,LinkTarget('mg'));
        append(title,"BI-RADS DESCRIPTORS");

        title.Style = {HAlign('left'), Italic, FontFamily('Raleway'), FontSize('12')};
        add(rpt,title);
        %diam
%         k1 = strfind(extra_text.diam, ': ');
%         testo1 = strcat(extra_text.diam(1:k1+1),"   ",extra_text.diam(k1+2:end));
%         txt = Text("  ");
%         append(prg,txt);
%         append(prg,extra_text.diam(k1+2:end));
%         add(rpt,prg);
%         %area
%         k1 = strfind(extra_text.area, ': ');
%         testo2 = strcat(extra_text.area(1:k1+1),"                     ",extra_text.area(k1+2:end));
%         prg = Paragraph(extra_text.area(1:k1+1));
%         txt = Text("                    ");
%         append(prg,txt);
%         append(prg,extra_text.area(k1+2:end));
%         add(rpt,prg);
%         %shape
%         k1 = strfind(extra_text.shape, ': ');
%         testo3 = strcat(extra_text.shape(1:k1+1),"                                  ",extra_text.shape(k1+2:end));
%         prg = Paragraph(extra_text.shape(1:k1+1));
%         txt = Text("                                 ");
%         append(prg,txt);
%         append(prg,extra_text.shape(k1+2:end));
%         add(rpt,prg);
%         %orientation
%         k1 = strfind(extra_text.orientation, ': ');
%         testo4 = strcat(extra_text.orientation(1:k1+1),"                       ",extra_text.orientation(k1+2:end));
%         prg = Paragraph(extra_text.orientation(1:k1+1));
%         txt = Text("                      ");
%         append(prg,txt);
%         append(prg,extra_text.orientation(k1+2:end));
%         add(rpt,prg);

        prg = Paragraph(extra_text.diam);
        prg.Style = {FontSize('12')};
%         prg.Children.Content = testo1;
        add(rpt,prg);
        prg = Paragraph(extra_text.area);
        prg.Style = {FontSize('12')};
%         prg.Children.Content = testo2;
        add(rpt,prg);
        prg = Paragraph(extra_text.shape);
        prg.Style = {FontSize('12')};
%         prg.Children.Content = testo3;
        add(rpt,prg);
        prg = Paragraph(extra_text.orientation);
        prg.Style = {FontSize('12')};
%         prg.Children.Content = testo4;
        add(rpt,prg);
    end



% Add blank line
    blankline(rpt,1);

close(rpt)

% rmdir(strcat(input.dir.save,'\temp'),'s');

end

function blankline(rpt,num)
    import mlreportgen.report.*
    import mlreportgen.dom.*

    prg = Paragraph(" ");
    prg.Style = {WhiteSpace('pre'), ...
        LineSpacing([num2str(num) 'px'])};
    add(rpt,prg);
end
