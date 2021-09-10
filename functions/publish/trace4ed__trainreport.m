
function file_name = trace4ed__trainreport(input)
% TRACE4ED © 2019 DeepTrace Technologies S.R.L.

makeDOMCompilable(); 

% File name
    file_name = strcat(input.dir.save, '/', input.date__str,...
        '__trainreport.pdf');

% Create report object
    import mlreportgen.report.*
    import mlreportgen.dom.*
    rpt = Report(file_name,'pdf');
    % rpt.Style = {FontFamily('Raleway')};
    
% Creating figures
    % TRAINING Performance
    tobe__exported = figure('Visible','off');
    hold on
    metric_name = [1 2 3];
    metric_value = [input.traccuracy, input.trsensitivity, input.trspecificity].*100;
    err = [input.traccuracy__std, input.trsensitivity__std, input.trspecificity__std].*100;
    errorbar(metric_name, metric_value, err, 'o')
    names = {'ACCURACY'; 'SENSITIVITY'; 'SPECIFICITY'};
    % set(tobe__exported, 'xtick', (1:3), 'xticklabel', names);
    xticks((1:3));
    xticklabels(names);
    axis([0 4 0 100])
    % xlabel('METRICS') 
    ylabel('TRAINING PERFORMANCE [%]')
    yline(70,'r:','70% threshold');
    yline(85,'r:','85% threshold');
    hold off    
    export_fig(tobe__exported, strcat(input.tdir,'\trperformance_temp'), '-png');
    close(tobe__exported)
    
    % VALIDATION Performance
    tobe__exported = figure('Visible','off');
    hold on
    metric_name = [1 2 3];
    metric_value = [input.vlaccuracy, input.vlsensitivity, input.vlspecificity].*100;
    err = [input.vlaccuracy__std, input.vlsensitivity__std, input.vlspecificity__std].*100;
    errorbar(metric_name, metric_value, err, 'o')
    names = {'ACCURACY'; 'SENSITIVITY'; 'SPECIFICITY'};
    % set(tobe__exported, 'xtick', (1:3), 'xticklabel', names);
    xticks((1:3));
    xticklabels(names);
    axis([0 4 0 100])
    % xlabel('METRICS') 
    ylabel('VALIDATION PERFORMANCE [%]')
    yline(70,'r:','70% threshold');
    yline(85,'r:','85% threshold');
    hold off    
    export_fig(tobe__exported, strcat(input.tdir,'\vlperformance_temp'), '-png');
    close(tobe__exported)    

    % TESTING Performance
    tobe__exported = figure('Visible','off');
    hold on
    metric_name = [1 2 3];
    metric_value = [input.accuracy, input.sensitivity, input.specificity].*100;
    err = [input.accuracy__std, input.sensitivity__std, input.specificity__std].*100;
    errorbar(metric_name, metric_value, err, 'o')
    names = {'ACCURACY'; 'SENSITIVITY'; 'SPECIFICITY'};
    % set(tobe__exported, 'xtick', (1:3), 'xticklabel', names);
    xticks((1:3));
    xticklabels(names);
    axis([0 4 0 100])
    % xlabel('METRICS') 
    ylabel('TESTING PERFORMANCE [%]')
    yline(70,'r:','70% threshold');
    yline(85,'r:','85% threshold');
    hold off    
    export_fig(tobe__exported, strcat(input.tdir,'\performance_temp'), '-png');
    close(tobe__exported) 
    
    % ROC
    tobe__exported = figure('Visible','off');
    for w = 1:size(input.Xroc, 2)
        plot(input.Xroc{w}, input.Yroc{w});
        hold on
    end
    hold off
    xlabel('1 - SPECIFICITY')
    ylabel('SENSITIVITY')
    export_fig(tobe__exported, strcat(input.tdir,'\ROC_temp'), '-png');
    close(tobe__exported) 

% Add title
    title = Heading(1,LinkTarget('index'));
    append(title,"TRACE4AMD | TRAIN Report");
%     txt = Text(erase(input.pet.patient__id,'zzproc__'));
%     append(title,txt);
    title.Style = {Italic,FontFamily('Raleway')};
    add(rpt,title);
        
% Add blank line
    blankline(rpt,15);  
    
% Initial comment
        prg = Paragraph('The model was trained, tested and validated with ');
        prg.Style = {Italic,FontFamily('Raleway'),FontSize('10pt')};
        txt = Text(num2str(input.sbjs));
        append(prg,txt);
        txt = Text(' subjects.');
        append(prg,txt);
        txt = Text(" Training, testing and validation phases resulted in a model with the following performance: ");
        append(prg,txt);
        
        txt = Text(" TRAINING -> ");
        append(prg,txt);
        txt = Text(num2str(round(100 * input.traccuracy)));
        append(prg,txt);
        txt = Text('% accuracy, ');
        append(prg,txt);
        txt = Text(num2str(round(100 * input.trsensitivity)));
        append(prg,txt);
        txt = Text('% sensitivity, ');
        append(prg,txt);
        txt = Text(num2str(round(100 * input.trspecificity)));
        append(prg,txt);
        txt = Text('% specificity, ');
        append(prg,txt);
        txt = Text(num2str(round(input.trauc*100)));
        append(prg,txt);
        txt = Text('% ROC-AUC. ');
        append(prg,txt);

        txt = Text(" VALIDATION -> ");
        append(prg,txt);
        txt = Text(num2str(round(100 * input.vlaccuracy)));
        append(prg,txt);
        txt = Text('% accuracy, ');
        append(prg,txt);
        txt = Text(num2str(round(100 * input.vlsensitivity)));
        append(prg,txt);
        txt = Text('% sensitivity, ');
        append(prg,txt);
        txt = Text(num2str(round(100 * input.vlspecificity)));
        append(prg,txt);
        txt = Text('% specificity, ');
        append(prg,txt);
        txt = Text(num2str(round(input.vlauc*100)));
        append(prg,txt);
        txt = Text('% ROC-AUC. ');
        append(prg,txt);

        txt = Text(" TESTING -> ");
        append(prg,txt);
        txt = Text(num2str(round(100 * input.accuracy)));
        append(prg,txt);
        txt = Text('% accuracy, ');
        append(prg,txt);
        txt = Text(num2str(round(100 * input.sensitivity)));
        append(prg,txt);
        txt = Text('% sensitivity, ');
        append(prg,txt);
        txt = Text(num2str(round(100 * input.specificity)));
        append(prg,txt);
        txt = Text('% specificity, ');
        append(prg,txt);
        txt = Text(num2str(round(input.auc*100)));
        append(prg,txt);
        txt = Text('% ROC-AUC. ');
        append(prg,txt);
        
        add(rpt,prg);  

% Add blank line
    blankline(rpt,15);  

% Add plots
    % Performance & ROC curve
    % Training and validation
        images = cell(1,2);
        images{1} = Image(strcat(input.dir.save,'\temp\',...
            'trperformance_temp.png'));
        images{1}.Style = {Width('300px'), HAlign('center')};
        images{2} = [];
        images{2}.Style = {Width('20px'), HAlign('center')};        
        images{3} = Image(strcat(input.dir.save,'\temp\',...
            'vlperformance_temp.png'));
        images{3}.Style = {Width('300px'), HAlign('center')};

        labels = cell(1,2);
        labels{1} = Text('TRAINING performance');
        labels{1}.Style = {Italic,FontFamily('Raleway'),...
            FontSize('10pt'),HAlign('center')};
        labels{2} = '';
        labels{3} = Text('VALIDATION performance');
        labels{3}.Style = {Italic,FontFamily('Raleway'),...
            FontSize('10pt'),HAlign('center')};

        t = Table({ images{1}, [], [], [], images{3} ;...
            labels{1}, '', '', '', labels{3} });
        t.Border = 'none';
        t.TableEntriesInnerMargin = '1pt';
        add(rpt,t);    
        
% Add blank line
    blankline(rpt,25);        
    
    % Testing
        images = cell(1,2);
        images{1} = Image(strcat(input.dir.save,'\temp\',...
            'performance_temp.png'));
        images{1}.Style = {Width('300px'), HAlign('center')};
        images{2} = [];
        images{2}.Style = {Width('20px'), HAlign('center')};        
        images{3} = Image(strcat(input.dir.save,'\temp\',...
            'ROC_temp.png'));
        images{3}.Style = {Width('300px'), HAlign('center')};

        labels = cell(1,2);
        labels{1} = Text('TESTING performance');
        labels{1}.Style = {Italic,FontFamily('Raleway'),...
            FontSize('10pt'),HAlign('center')};
        labels{2} = '';
        labels{3} = Text('TESTING ROC-AUC Curve');
        labels{3}.Style = {Italic,FontFamily('Raleway'),...
            FontSize('10pt'),HAlign('center')};

        t = Table({ images{1}, [], [], [], images{3} ;...
            labels{1}, '', '', '', labels{3} });
        t.Border = 'none';
        t.TableEntriesInnerMargin = '1pt';
        add(rpt,t);
        
% Add blank line
    blankline(rpt,25);        

    % Performance table
        prg = Heading1("Performance");
        prg.Style = {Italic,FontFamily('Raleway'),FontSize('10pt')};
        add(rpt,prg);    

        temp = cell(5,4);
        temp{2,1} = 'Accuracy [%]';
        temp{3,1} = 'Sensitivity [%]';
        temp{4,1} = 'Specificity [%]';
        temp{5,1} = 'ROC-AUC [%]';
        temp{1,2} = 'TRAINING';
        temp{1,3} = 'VALIDATION';
        temp{1,4} = 'TESTING';        
        % TRAINING
        temp{2,2} = strcat(num2str(round(100*input.traccuracy)),...
            ' +/- ', ...
            num2str(round(100*input.traccuracy__std)));
        temp{3,2} = strcat(num2str(round(100*input.trsensitivity)),...
            ' +/- ', ...
            num2str(round(100*input.trsensitivity__std)));
        temp{4,2} = strcat(num2str(round(100*input.trspecificity)),...
            ' +/- ', ...
            num2str(round(100*input.trspecificity__std))); 
        temp{5,2} = strcat(num2str(round(100*input.trauc)),...
            ' +/- ', ...
            num2str(round(100*input.trauc__std))); 
        % VALIDATION
        temp{2,3} = strcat(num2str(round(100*input.vlaccuracy)),...
            ' +/- ',...
            num2str(round(100*input.vlaccuracy__std)));
        temp{3,3} = strcat(num2str(round(100*input.vlsensitivity)),...
            ' +/- ', ...
            num2str(round(100*input.vlsensitivity__std)));
        temp{4,3} = strcat(num2str(round(100*input.vlspecificity)),...
            ' +/- ', ...
            num2str(round(100*input.vlspecificity__std))); 
        temp{5,3} = strcat(num2str(round(100*input.vlauc)),...
            ' +/- ', ...
            num2str(round(100*input.vlauc__std))); 
        % TESTING
        temp{2,4} = strcat(num2str(round(100*input.accuracy)),...
            ' +/- ', ...
            num2str(round(100*input.accuracy__std)));
        temp{3,4} = strcat(num2str(round(100*input.sensitivity)),...
            ' +/- ', ...
            num2str(round(100*input.sensitivity__std)));
        temp{4,4} = strcat(num2str(round(100*input.specificity)),...
            ' +/- ', ...
            num2str(round(100*input.specificity__std))); 
        temp{5,4} = strcat(num2str(round(100*input.auc)),...
            ' +/- ', ...
            num2str(round(100*input.auc__std)));         
        table = Table(temp);
        table.Style = {Border('single','black','1px'), ...
                   ColSep('single','black','1px'), ...
                   RowSep('single','black','1px'), ...
                   FontSize('8pt'), ...
                   Width('400')};    
        add(rpt,table);    

% Add blank line
    blankline(rpt,10);
    
% Add blank line
    blankline(rpt,1);

close(rpt)

rmdir(strcat(input.dir.save,'\temp'),'s');

end

function blankline(rpt,num)
    import mlreportgen.report.*
    import mlreportgen.dom.*

    prg = Paragraph(" ");
    prg.Style = {WhiteSpace('pre'), ...
        LineSpacing([num2str(num) 'px'])};
    add(rpt,prg);
end
