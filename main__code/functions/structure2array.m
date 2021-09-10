function [radiomics_out,fields] = structure2array(radiomics,scaleName,is3D)
radiomics_out = [];
fields = [];
% exclude local intensity
% T = struct2table(radiomics.image.locInt_3D.(scaleName),'AsArray',true);
% A1 = T.Floc_peak_local;
% radiomics_out = [radiomics_out; A1];
T = struct2table(radiomics.image.stats_3D.(scaleName),'AsArray',true);
radiomics_out = [radiomics_out; table2array(T)'];
fields = [fields; fieldnames(radiomics.image.stats_3D.(scaleName))];
% temp_name = strcat(scaleName,'_algoFBN_bin64');
% temp_name = strcat(scaleName,'_algo',...
%     radiomics.imParam.image.discretisation.IH.type ,'_bin',...
%     num2str(radiomics.imParam.image.discretisation.IH.val));
% temp_name = replaceCharacter(temp_name,'.','dot');
temp_name = fieldnames(radiomics.image.intHist_3D);
temp_name = temp_name{1};
T = struct2table(radiomics.image.intHist_3D.(temp_name),'AsArray',true);
radiomics_out = [radiomics_out; table2array(T)'];
fields = [fields; fieldnames(radiomics.image.intHist_3D.(temp_name))];

to_delete = [24 28 29 35 38 39 41];%exclude min, mode, iqr, qcod, max grad, max grad gl, min grad gl
radiomics_out(to_delete)=[];
fields(to_delete)=[];
if is3D
    T = struct2table(radiomics.image.morph_3D.(scaleName),'AsArray',true);
    radiomics_out = [table2array(T)';radiomics_out];
end
% exclude intensity volume histogram
% T = struct2table(radiomics.image.intVolHist_3D.(temp_name),'AsArray',true);
% radiomics_out = [radiomics_out; table2array(T)'];
% fields = [fields; fieldnames(radiomics.image.intVolHist_3D.(temp_name))];
T = struct2table(radiomics.image.texture,'AsArray',true);
A = table2array(T);
% temp_name = strcat(scaleName,'_algo',...
%     radiomics.imParam.image.discretisation.texture.type ,'_bin',...
%     num2str(radiomics.imParam.image.discretisation.texture.val));
% temp_name = replaceCharacter(temp_name,'.','dot');

for i = 1:length(A)
    temp_name = fieldnames(A(i));
    temp_name = temp_name{1};
    if i ~= 4 %exclude grey-level distance zone matrix
        T = struct2table(A(i).(temp_name),'AsArray',true);
        Atemp = table2array(T)';
        if i == 3
            Atemp(8)=[];%exclude Fszm_lzhge
            temp_fields = fieldnames(A(i).(temp_name));
            temp_fields(8) = [];
            fields = [fields; temp_fields];
        else
            
            fields = [fields; fieldnames(A(i).(temp_name))];
        end
        radiomics_out = [radiomics_out; Atemp];
    end
end



