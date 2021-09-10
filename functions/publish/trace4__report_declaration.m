function trace4__report_declaration(output)

makeDOMCompilable(); 

dir = output.input.results.dir.save;
str = output.input.results.date__str;
file_name = strcat(dir, '/', str, '__declaration.pdf');

% Create report object
    import mlreportgen.report.*
    import mlreportgen.dom.*
    rpt = Report(file_name,'pdf');

% % Add blank line
%     blankline(rpt,10);

% Add title

    title = Heading(1,LinkTarget('index'));
    append(title,"DECLARATION");
    title.Style = {Italic,FontFamily('Raleway')};
    add(rpt,title);
    
% structure1 = struct(args1{:});
% app.output.l1=structure1;
% output.imgProtocol
% output.imgQuality
% output.expMulti
% output.expProsp
% output.clinRelation
% output.clinApplic
% output.materialData
% output.materialModel
    
imgProtocol_label='Acquisition and reconstruction protocols of images used for the model are similar across patients';
imgQualityimg_label='Images used for the model are of sufficient quality';
expMulti_label='Images used for the model are from multi-institutional patients'' cohort';
expProsp_label='Images used for the model are from prospective study patients'' cohort';
% clinRelation_label='Assessment of the relationship between macroscopic tumor phenotype(s) described with radiomics, and the underlying microscopic tumor biology, is provided';
% clinApplic_label='The study discusses the current and potential application(s) of proposed radiomics-based models in the clinical setting';
materialData_label='Imaging data, tumor ROI and clinical information are made available';
materialModel_label='Complete model is available, including model parameters and cut-off values';
   
imgCompu_label='Computation of radiomics features and image processing steps match the benchmarks of the IBSI';
imgIBSI_label='Radiomics features computation are provided for the IBSI calibration phantom';
featRobust_label='The robustness of feature against segmentation variations and varying imaging settings is evaluated';
featUnreliable_label='Unreliable features are discarded';
featCorrel_label='The inter-correlation of features is evaluated';
featRedunt_label='Redundant features are discarded';
modelUniv_label='Univariate analysis is performed';
modelMulti_test_label='Correction for multiple testing comparisons is applied in case of univariate analysis';
modelHarm_label='Feature harmonization is provided';
modelOversamp_label='Feature oversampling is provided for the minority class';
modelDatasep_label='The teaching dataset is separated into training and validation set(s)';
modelTest_distinct_label='A testing set distinc from the teaching set is used to evaluate the perfomance of complete models without retraining or withour adaptation of cut-off values';
modelPerfeval_label='The evaluation of the perfomance  is unbiased and not used to optimiza model parameteres';
modelPerf_label='Model performance obtained in the training, validation and testing sets is reported';
modelConsist_label='Consistency check of performance measures across the different sets are performed';
modelRandomdata_label='Consistency check of performances measures across random data sets are performed';
modelComparison_label='Performance of radiomics-based model is compared againts conventional metrics such as tumor volume in order to evaluate the added value of radiomics';
modelMultivariate_label='Multivariate analysis integrate variables other than radiomics features (e.g. clinical information, demographic data, panomics etc.)';

imgCompu = output.input.decl.imgCompu;
imgIBSI = output.input.decl.imgIBSI;
featRobust = output.input.decl.featRobust;
featUnreliable = output.input.decl.featUnreliable;
featCorrel = output.input.decl.featCorrel;
featRedunt = output.input.decl.featRedunt; 
modelUniv = output.input.decl.modelUniv;
modelMulti_test = output.input.decl.modelMulti_test;
modelHarm = output.input.decl.modelHarm;
modelOversamp = output.input.decl.modelOversamp;
modelDatasep = output.input.decl.modelDatasep;
modelTest_distinct = output.input.decl.modelTest_distinct;
modelPerfeval = output.input.decl.modelPerfeval;
modelPerf = output.input.decl.modelPerf;
modelConsist = output.input.decl.modelConsist;
try modelRandomdata = output.input.decl.modelRandomdata;
catch
    modelRandomdata = 'No';
end
modelComparison = output.input.decl.modelComparison;
modelMultivariate = output.input.decl.modelMultivariate;

    prg = Heading1('IMAGING');
    prg.Style = {Italic,FontFamily('Raleway'),FontSize('12pt')};
    add(rpt,prg);
    n=1;
    temp{n,1}='USER:';
    temp{n+1,2}=imgProtocol_label;
    temp{n+2,3}=output.imgProtocol;
    
    n=n+3;
    temp{n,1}='USER:';
    temp{n+1,2}=imgQualityimg_label;
    temp{n+2,3}=output.imgQuality;
    n=n+3;
    temp{n,1}='PROVIDER:';
    temp{n+1,2}=imgCompu_label;
    temp{n+2,3}=imgCompu;
    n=n+3;
    temp{n,1}='PROVIDER:';
    temp{n+1,2}=imgIBSI_label;
    temp{n+2,3}=imgIBSI;
%     n=n+3;
    table = Table(temp);
    clear temp;
    table.Style = {Border('single','white','1px'), ...
               ColSep('single','white','1px'), ...
               RowSep('single','white','1px'), ...
               FontSize('8pt')};
%         table.Style = {FontSize('6pt')};
    add(rpt,table);
    blankline(rpt,15);

    prg = Heading1('EXPERIMENTAL SETUP');
    prg.Style = {Italic,FontFamily('Raleway'),FontSize('12pt')};
    add(rpt,prg);
    n=1;
    temp{n,1}='USER:';
    temp{n+1,2}=expMulti_label;
    temp{n+2,3}=output.expMulti;
    n=n+3;
    temp{n,1}='USER:';
    temp{n+1,2}=expProsp_label;
    temp{n+2,3}=output.expProsp;

%     n=n+3;
    table = Table(temp);
    clear temp;
    table.Style = {Border('single','white','1px'), ...
               ColSep('single','white','1px'), ...
               RowSep('single','white','1px'), ...
               FontSize('8pt')};
%         table.Style = {FontSize('6pt')};
    add(rpt,table);
    blankline(rpt,15);
    
    prg = Heading1('FEATURE SELECTION');
    prg.Style = {Italic,FontFamily('Raleway'),FontSize('12pt')};
    add(rpt,prg);
    n=1;
    temp{n,1}='PROVIDER:';
    temp{n+1,2}=featRobust_label;
    temp{n+2,3}=featRobust;
    n=n+3;
    temp{n,1}='PROVIDER:';
    temp{n+1,2}=featUnreliable_label;
    temp{n+2,3}=featUnreliable;
    n=n+3;
    temp{n,1}='PROVIDER:';
    temp{n+1,2}=featCorrel_label;
    temp{n+2,3}=featCorrel;
    n=n+3;
    temp{n,1}='PROVIDER:';
    temp{n+1,2}=featRedunt_label;
    temp{n+2,3}=featRedunt;
%     n=n+3;
    table = Table(temp);
    clear temp;
    table.Style = {Border('single','white','1px'), ...
               ColSep('single','white','1px'), ...
               RowSep('single','white','1px'), ...
               FontSize('8pt')};
%         table.Style = {FontSize('6pt')};
    add(rpt,table);
    blankline(rpt,15);
    
    prg = Heading1('MODEL ASSESSMENT');
    prg.Style = {Italic,FontFamily('Raleway'),FontSize('12pt')};
    add(rpt,prg);
    n=1;
    
    temp{n,1}='PROVIDER:';
    temp{n+1,2}=modelUniv_label;
    temp{n+2,3}=modelUniv;
    n=n+3;
    temp{n,1}='PROVIDER:';
    temp{n+1,2}=modelMulti_test_label;
    temp{n+2,3}=modelMulti_test;
    n=n+3;
    temp{n,1}='PROVIDER:';
    temp{n+1,2}=modelHarm_label;
    temp{n+2,3}=modelHarm;
    n=n+3;
    temp{n,1}='PROVIDER:';
    temp{n+1,2}=modelOversamp_label;
    temp{n+2,3}=modelOversamp;
    n=n+3;
    temp{n,1}='PROVIDER:';
    temp{n+1,2}=modelDatasep_label;
    temp{n+2,3}=modelDatasep;
    n=n+3;
    temp{n,1}='PROVIDER:';
    temp{n+1,2}=modelTest_distinct_label;
    temp{n+2,3}=modelTest_distinct;
    n=n+3;
    temp{n,1}='PROVIDER:';
    temp{n+1,2}=modelPerfeval_label;
    temp{n+2,3}=modelPerfeval;
    n=n+3;
    temp{n,1}='PROVIDER:';
    temp{n+1,2}=modelPerf_label;
    temp{n+2,3}=modelPerf;
    n=n+3;
    temp{n,1}='PROVIDER:';
    temp{n+1,2}=modelConsist_label;
    temp{n+2,3}=modelConsist;
    n=n+3;
    temp{n,1}='PROVIDER:';
    temp{n+1,2}=modelRandomdata_label;
    temp{n+2,3}=modelRandomdata;
    n=n+3;
    temp{n,1}='PROVIDER:';
    temp{n+1,2}=modelComparison_label;
    temp{n+2,3}=modelComparison;
    n=n+3;
    temp{n,1}='PROVIDER:';
    temp{n+1,2}=modelMultivariate_label;
    temp{n+2,3}=modelMultivariate;
%     n=n+3;
    table = Table(temp);
    clear temp;
    table.Style = {Border('single','white','1px'), ...
               ColSep('single','white','1px'), ...
               RowSep('single','white','1px'), ...
               FontSize('8pt')};
%         table.Style = {FontSize('6pt')};
    add(rpt,table);
    blankline(rpt,25);
    

%     prg = Heading1('CLINICAL IMPLICATIONS');
%     prg.Style = {Italic,FontFamily('Raleway'),FontSize('12pt')};
%     add(rpt,prg);
%     n=1;
%     temp{n,1}='USER:';
%     temp{n+1,2}=clinRelation_label;
%     temp{n+2,3}=output.clinRelation;
% 
%     n=n+3;
%     temp{n,1}='USER:';
%     temp{n+1,2}=clinApplic_label;
%     temp{n+2,3}=output.clinApplic;
% 
% %     n=n+3;
%     table = Table(temp);
%     clear temp;
%     table.Style = {Border('single','white','1px'), ...
%                ColSep('single','white','1px'), ...
%                RowSep('single','white','1px'), ...
%                FontSize('8pt')};
% %         table.Style = {FontSize('6pt')};
%     add(rpt,table);
%     blankline(rpt,25);
    
    
    prg = Heading1('MATERIAL AVAILABILITY');
    prg.Style = {Italic,FontFamily('Raleway'),FontSize('12pt')};
    add(rpt,prg);
    n=1;
    temp{n,1}='USER:';
    temp{n+1,2}=materialData_label;
    temp{n+2,3}=output.materialData;
    n=n+3;
    temp{n,1}='USER:';
    temp{n+1,2}=materialModel_label;
    temp{n+2,3}=output.materialModel;
%     n=n+3;
    table = Table(temp);
    clear temp;
    table.Style = {Border('single','white','1px'), ...
               ColSep('single','white','1px'), ...
               RowSep('single','white','1px'), ...
               FontSize('8pt')};
%         table.Style = {FontSize('6pt')};
    add(rpt,table);
    blankline(rpt,25);
    blankline(rpt,2);

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
