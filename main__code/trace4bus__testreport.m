% function trace4bus__testreport(out_risk, patient__name, path_save, second)
function file_name = trace4bus__testreport(out_risk, patient__name, path_save)
% TRACE4AD © 2019 DeepTrace Technologies S.R.L.

makeDOMCompilable(); 
% p__i = input.pid;
%     k = strfind(p__i,'.');
%     if length(k)>1
%         patient__name = p__i(1:k(end)-1);
%     else
%         patient__name = p__i;
%     end

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
    
% % Add title
% title = Heading(1,LinkTarget('index'));
% append(title,"CLASSIFICATION OF RISK OF ALZHEIMER'S DISEASE");
% title.Style = {Italic,FontFamily('Raleway')};
% add(rpt,title);  

% % Add blank line
%     blankline(rpt,5); 

% Add paragraph
% if second == 0
%     prg = Paragraph("USI image has been evaluated as a ");
% elseif second == 1
%     prg = Paragraph("USI image has been classified as a ");
% end

prg = Paragraph(out_risk);
% txt = lower(out_risk);

% append(prg,txt);
% txt = Text(" of MALIGNANCY");%, with ");
% append(prg,txt);
% probability = round(100 * input.results.results.pprob);
% txt = Text(num2str(probability));
% append(prg,txt);
% txt = Text("% probability.");
% append(prg,txt);
add(rpt,prg);

% Add blank line
    blankline(rpt,10);

% if out_risk.warn == 1
%     prg = Paragraph("IMPORTANT: This result does not take into consideration the CA-125 levels, which were not provided by the user. CA-125 levels equal to or higher than ");
% 	prg.Style = {HAlign('justify'), FontSize('14')};
%     if out_risk.mp == 1
%         txt = "71 U/mL would indicate a HIGH RISK OF MALIGNANCY.[1]";
%     else
%         txt = "200 U/mL would indicate a HIGH RISK OF MALIGNANCY.[1]";
%     end
%     append(prg,txt);
%     add(rpt,prg);
% end


% Add blank line
%     blankline(rpt,15);
%     
% if out_risk.warn == 1
%     if out_risk.mp == 1
%         prg = Paragraph("[1] Karlsen MA. et al. Evaluation of HE4, CA125, risk of ovarian malignancy algorithm (ROMA) and risk of malignancy index (RMI) as diagnostic tools of epithelial ovarian cancer in patients with a pelvic mass. Gynecol Oncol.2012 Nov;127(2):379-83. doi: 10.1016/j.ygyno.2012.07.106.");
%     else
%         prg = Paragraph("[1] American College of Obstetricians and Gynecologists’ Committee on Practice Bulletins—Gynecology'. Practice Bulletin No. 174: Evaluation and Management of Adnexal Masses. Obstet Gynecol.2016 Nov;128(5):e210-e226. doi: 10.1097/AOG.0000000000001768.");
%     end
%     prg.Style = {HAlign('justify'), FontSize('10')};
%     add(rpt,prg);
% end


% % % Add blank line
% %     blankline(rpt,15);
% %     
% % % Add paragraph about #classifier #training
% %     prg = Paragraph("The classification model was previously trained and validated ");
% %     prg.Style = {HAlign('justify'), FontSize('12')};
% % 
% % %     txt = Text("showing an accuracy of ");
% % %     append(prg,txt);
% % % 
% % %     txt = Text(num2str(num2str(round(100*input.performance.acc))));
% % %     append(prg,txt);
% % % 
% % %     txt = Text("%, sensitivity of ");
% % %     append(prg,txt);
% % % 
% % %     txt = Text(num2str(round(100*input.performance.sen)));
% % %     append(prg,txt);
% % % 
% % %     txt = Text("%, and specificity ");
% % %     append(prg,txt);
% % % 
% % %     txt = Text(num2str(round(100*input.performance.spe)));
% % %     append(prg,txt);
% % % % 
% % %     txt = Text("%.");
% % %     append(prg,txt);
% % txt = Text("showing an accuracy of 88%, sensitivity of 99%, and specificity of 76%.");
% % append(prg,txt);
% %     add(rpt,prg);

% Add blank line
    blankline(rpt,10);    

% Add MRI
% title = Heading(1,LinkTarget('mri'));
% append(title,"MRI gray-matter image used by TRACE4AD to predict the risk of Alzheimer's disease (axial view)");
% title.Style = {HAlign('center'), Italic, FontFamily('Raleway'), FontSize('12')};
% add(rpt,title);
% 
% try
%     temp__img = load_nii(input.path.nimg);
%     app.img = temp__img.img; clear temp__img
%     try delete(app.path.nimg); end
% end
% 
% fig__ = figure('Visible','off');
% montage(flipdim(permute(app.img,[2,1,3]),1), 'Indices', 10:3:(size(app.img, 1)-25));
% saveas(fig__,strcat(input.dir.save,'\mri__montage.png'));
% close(fig__);
% img__mri = Image(strcat(input.dir.save,'\mri__montage.png'));
% img__mri.Style = {HAlign('center'), Width('7.0in')};
% add(rpt,img__mri);
% 
% % % Break
% %     Break = PageBreak();
% %     add(rpt,Break);
% 
% % Add date
%     prg = Paragraph("File-creation date: ");
%     prg.Style = {HAlign('right'), FontSize('10')};
% 
%     txt = Text(adesso);
%     append(prg,txt);
%     
%     add(rpt,prg);
%     
% % Add Biomarker Maps
% title = Heading(1,LinkTarget('biomarkers'));
% append(title,'TRACE4AD Imaging Features and Performance');
% title.Style = {Italic,FontFamily('Raleway')};
% add(rpt,title);
% 
% prg = Paragraph("Figure below shows MRI gray-matter imaging features detected by TRACE4AD as best predictors* of the risk of Alzheimer’s Disease. Such imaging features have been revealed by TRACE4AD during training on MRI images of low- and high-risk of Alzheimer’s Disease and mapped onto a standard 3D-MRI atlas for your convenience, based on significant differences in their expression levels. Significance is expressed in terms of imaging-feature importance and associated to the color scale on the right of the figure.");
% prg.Style = {HAlign('justify')};
% add(rpt,prg);
% 
% blankline(rpt,4);
% 
% txt = Paragraph("* on the basis of the comparison of the performance of the predictive abilities of TRACE4OC (Accuracy ");
% 
% txt1 = Text(num2str(num2str(round(100*input.performance.acc))));
% append(txt,txt1);
% 
% txt1 = Text("%, Sensitivity ");
% append(txt,txt1);
% 
% txt1 = Text(num2str(round(100*input.performance.sen)));
% append(txt,txt1);
% 
% txt1 = Text("%, Specificity ");
% append(txt,txt1);
% 
% txt1 = Text(num2str(round(100*input.performance.spe)));
% append(txt,txt1);
% 
% txt1 = Text("%) ");
% append(txt,txt1);
%     
% txt1 = Text("considering distinct brain tissues partitioned by TRACE4AD from the MRI images.");
% append(txt,txt1);
% 
% txt.Style = {HAlign('justify'),Italic,FontFamily('Raleway'),FontSize('10')};
% add(rpt,txt);
% 
% blankline(rpt,6.5);
% 
% img__biom = Image(strcat('images\biomarkers.png'));
% img__biom.Style = {HAlign('center'), Width('6.1in')};
% add(rpt,img__biom);

% % Add Notes
% title = Heading(1,LinkTarget('notes'));
% append(title,'Notes about the clinical use of Trace4AD');
% title.Style = {Italic,FontFamily('Raleway'),FontSize('12')};
% add(rpt,title);
% 
% prg = Paragraph("Automatic classification was carried out using Trace4AD, an artificial-intelligence algorithm for the early diagnosis of Alzheimer's Disease (AD), as in [1]. The use of Trace4AD for the automatic identification of patients with high risk (AD + MCIc) vs. low risk (CN + MCInc) to develop AD was validated in [1] using both MRI studies and neuropsychological-test scores obtained from 200 subjects. Subjects were distributed as follows: 50 patients with a diagnosis of AD, 50 patients with Mild Cognitive Impairment (MCI) who will convert to AD within 24 months (MCIc), 50 MCI patients who will not convert to AD within 24 months (MCInc), and 50 Cognitively-Normal (CN) subjects. Validation was performed using a nested cross-validation approach. Trace4AD was able to automatically identify patients with different risk to develop AD 24 months before a stable clinical diagnosis, with 85% accuracy, 83% sensitivity and 87% specificity using MRI data coupled to neuropsychological-test scores, and 79% accuracy, 79% sensitivity and 78% specificity using MRI data alone.");
% prg.Style = {HAlign('justify'),FontFamily('Raleway'),FontSize('10')};
% add(rpt,prg);

% % Add Privacy
% title = Heading(1,LinkTarget('privacy'));
% append(title,'Privacy');
% title.Style = {Italic,FontFamily('Raleway'),FontSize('12')};
% add(rpt,title);
% 
% prg = Paragraph("This report was automatically generated by Trace4AD and it contains confidential and privileged information. If you are not the intended recipient, you are not authorised to read, print, save, process or disclose this report. Any use, distribution, reproduction or disclosure by any person other than the intended recipient is strictly prohibited and the person responsible may incur penalties. Thank you!");
% prg.Style = {HAlign('justify'),FontFamily('Raleway'),FontSize('10')};
% add(rpt,prg);

% % Add References
% title = Heading(1,LinkTarget('references'));
% append(title,'References');
% title.Style = {Italic,FontFamily('Raleway'),FontSize('12')};
% add(rpt,title);
% 
% prg = Paragraph("[1] Salvatore, C, et al. MRI Characterizes the Progressive Course of AD and Predicts Conversion to Alzheimer’s Dementia 24 Months Before Probable Diagnosis. Frontiers in Aging Neuroscience (2018).");
% prg.Style = {HAlign('justify'),FontFamily('Raleway'),FontSize('10')};
% add(rpt,prg);

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
