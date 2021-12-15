function output = read_results_t4bus(in)




if output.class == 0
    switch app.answer1
    case 'Yes'
        switch app.answer2
            case 'Yes' % 0% di malignancy with second opinion
%                 app.testo = 'The breast mass has been predicted to have >0% likelihood of malignancy: short-interval follow-up or continuous surveillance is suggested.';
                app.testo = 'The breast mass has been predicted to belong to BI-RADS 3 category (between 0% and 2% likelihood of malignancy): short-interval follow-up or continuous surveillance is suggested.';
                set(handles.testo_save, 'string',app.testo);
                app.pdf__path = trace4bus__testreport(app.testo,app.sbj_name,app.Path_Name,app.second);
            case 'No' % 0% di malignancy without second opinion
                
        end
    case 'No'
        switch app.answer2
            case 'Yes' % >0% di malignancy with second opinion
                if output.pprob <= 0.9
                    app.testo = 'The breast mass has been predicted to belong to BI-RADS 4 category (between 2% and 95% likelihood of malignancy): tissue diagnosis is suggested.';
                else
                    app.testo = 'The breast mass has been predicted to belong to BI-RADS 5 category (more than 95% likelihood of malignancy): tissue diagnosis is suggested.';
                end
%                 app.testo = 'The breast mass has been predicted to have >2% likelihood of malignancy: tissue diagnosis is suggested.';
                set(handles.testo_save, 'string',app.testo);
                app.pdf__path = trace4bus__testreport(app.testo,app.sbj_name,app.Path_Name,app.second);
            case 'No' % >0% di malignancy without second opinion
                
        end
    end
else
    switch app.answer1
    case 'Yes'
        switch app.answer2
            case 'Yes' % 0% di malignancy with second opinion
%                 app.testo = 'The breast mass has been predicted to have 0% likelihood of malignancy.';
                app.testo = 'The breast mass has been predicted to belong to BI-RADS 2 category (0% likelihood of malignancy).';
                set(handles.testo_save, 'string',app.testo);
                app.pdf__path = trace4bus__testreport(app.testo,app.sbj_name,app.Path_Name,app.second);
            case 'No' % 0% di malignancy without second opinion
                
        end
    case 'No'
        switch app.answer2
            case 'Yes' % >0% di malignancy with second opinion
%                 app.testo = 'The breast mass has been predicted to have <2% likelihood of malignancy: short-interval follow-up or continuous surveillance is suggested.';
                app.testo = 'The breast mass has been predicted to belong to BI-RADS 3 category (between 0% and 2% likelihood of malignancy): short-interval follow-up or continuous surveillance is suggested.';
                set(handles.testo_save, 'string',app.testo);
                app.pdf__path = trace4bus__testreport(app.testo,app.sbj_name,app.Path_Name,app.second);
            case 'No' % >0% di malignancy without second opinion
                
        end
    end
end


% output.risk = 'NO risk';
% output.risk = 'LOW risk';
% output.risk = 'MEDIUM risk';
% output.risk = 'HIGH risk';
output.warn = 0;
% output.warn = 1;

model_path = in.path.model;
clinical = in.clin_input;
output.mp = clinical.Menopause;
if strcmp(in.results.results.classification, 'POSITIVE')
    risk = 1;
else
    risk = 2;
end
if endsWith(model_path,'model_cystic.mat')
    if risk == 2 %negative
    %     if clinical.AcShadow == 1
            if clinical.Menopause == 1
                if clinical.Ca125 >= 0
                    if clinical.Ca125 >= 71
                        output.risk = 'HIGH risk'; %HR of malignancy 
                    else
                        output.risk = 'VERY LOW risk'; %NR of malignancy 
                    end
                else
                    output.risk = 'VERY LOW risk'; %NR of malignancy
                    output.warn = 1; %con warning
                end
            else
                if clinical.Ca125 >= 0
                    if clinical.Ca125 >= 200
                        output.risk = 'HIGH risk'; %HR of malignancy 
                    else
                        output.risk = 'VERY LOW risk'; %NR of malignancy 
                    end
                else
                    output.risk = 'VERY LOW risk'; %NR of malignancy
                    output.warn = 1; %con warning
                end
            end
    %     else
    %         output.risk = 'VERY LOW risk'; %NR of malignancy 
    %     end
    else %positive
        if clinical.AcShadow == 1
            if clinical.Menopause == 1
                if clinical.Ca125 >= 0
                    if clinical.Ca125 >= 71
                        output.risk = 'HIGH risk'; %HR of malignancy 
                    else
                        output.risk = 'VERY LOW risk'; %NR of malignancy 
                    end
                else
                    output.risk = 'VERY LOW risk'; %NR of malignancy
                    output.warn = 1; %con warning
                end
            else
                if clinical.Ca125 >= 0
                    if clinical.Ca125 >= 200
                        output.risk = 'HIGH risk'; %HR of malignancy 
                    else
                        output.risk = 'VERY LOW risk'; %NR of malignancy 
                    end
                else
                    output.risk = 'VERY LOW risk'; %NR of malignancy
                    output.warn = 1; %con warning
                end
            end
        else
            output.risk = 'MEDIUM risk'; %MR of malignancy 
        end
    end
elseif endsWith(model_path,'model_mix.mat')
    if risk == 2 %negative
        if clinical.Menopause == 1
            if clinical.Ca125 >= 0
                if clinical.Ca125 >= 71
                    output.risk = 'HIGH risk'; %HR of malignancy 
                else
                    if clinical.AcShadow == 1
                        output.risk = 'VERY LOW risk'; %NR of malignancy 
                    else
                        output.risk = 'LOW risk'; %LR of malignancy 
                    end
                end
            else
                if clinical.AcShadow == 1
                    output.risk = 'VERY LOW risk'; %NR of malignancy
                    output.warn = 1; %con warning
                else
                    output.risk = 'LOW risk'; %LR of malignancy
                    output.warn = 1; %con warning
                end
            end
        else
            if clinical.Ca125 >= 0
                if clinical.Ca125 >= 200
                    output.risk = 'HIGH risk'; %HR of malignancy 
                else
                    if clinical.AcShadow == 1
                        output.risk = 'VERY LOW risk'; %NR of malignancy 
                    else
                        output.risk = 'LOW risk'; %LR of malignancy 
                    end
                end
            else
                if clinical.AcShadow == 1
                    output.risk = 'VERY LOW risk'; %NR of malignancy
                    output.warn = 1; %con warning
                else
                    output.risk = 'LOW risk'; %LR of malignancy
                    output.warn = 1; %con warning
                end
            end
        end
    else %positive
        if clinical.AcShadow == 1
            if clinical.Menopause == 1
                if clinical.Ca125 >= 0
                    if clinical.Ca125 >= 71
                        output.risk = 'HIGH risk'; %HR of malignancy 
                    else
                        output.risk = 'VERY LOW risk'; %NR of malignancy 
                    end
                else
                    output.risk = 'VERY LOW risk'; %NR of malignancy
                    output.warn = 1; %con warning
                end
            else
                if clinical.Ca125 >= 0
                    if clinical.Ca125 >= 200
                        output.risk = 'HIGH risk'; %HR of malignancy 
                    else
                        output.risk = 'VERY LOW risk'; %NR of malignancy 
                    end
                else
                    output.risk = 'VERY LOW risk'; %NR of malignancy
                    output.warn = 1; %con warning
                end
            end
        else
            output.risk = 'HIGH risk'; %HR of malignancy 
        end
    end
elseif endsWith(model_path,'model_solid.mat')
    if risk == 2 %negative
        if clinical.Menopause == 1
            if clinical.Ca125 >= 0
                if clinical.Ca125 >= 71
                    output.risk = 'HIGH risk'; %HR of malignancy 
                else
                    if clinical.AcShadow == 1
                        output.risk = 'VERY LOW risk'; %NR of malignancy 
                    else
                        output.risk = 'MEDIUM risk'; %MR of malignancy 
                    end
                end
            else
                if clinical.AcShadow == 1
                    output.risk = 'VERY LOW risk'; %NR of malignancy
                    output.warn = 1; %con warning
                else
                    output.risk = 'MEDIUM risk'; %MR of malignancy
                    output.warn = 1; %con warning
                end
            end
        else
            if clinical.Ca125 >= 0
                if clinical.Ca125 >= 200
                    output.risk = 'HIGH risk'; %HR of malignancy 
                else
                    if clinical.AcShadow == 1
                        output.risk = 'VERY LOW risk'; %NR of malignancy 
                    else
                        output.risk = 'MEDIUM risk'; %MR of malignancy 
                    end
                end
            else
                if clinical.AcShadow == 1
                    output.risk = 'VERY LOW risk'; %NR of malignancy
                    output.warn = 1; %con warning
                else
                    output.risk = 'MEDIUM risk'; %MR of malignancy
                    output.warn = 1; %con warning
                end
            end
        end
    else %positive
        if clinical.AcShadow == 1
            if clinical.Menopause == 1
                if clinical.Ca125 >= 0
                    if clinical.Ca125 >= 71
                        output.risk = 'HIGH risk'; %HR of malignancy 
                    else
                        output.risk = 'VERY LOW risk'; %NR of malignancy 
                    end
                else
                    output.risk = 'VERY LOW risk'; %NR of malignancy
                    output.warn = 1; %con warning
                end
            else
                if clinical.Ca125 >= 0
                    if clinical.Ca125 >= 200
                        output.risk = 'HIGH risk'; %HR of malignancy 
                    else
                        output.risk = 'VERY LOW risk'; %NR of malignancy 
                    end
                else
                    output.risk = 'VERY LOW risk'; %NR of malignancy 
                    output.warn = 1; %con warning
                end
            end
        else
            output.risk = 'HIGH risk'; %HR of malignancy 
        end
    end
end
