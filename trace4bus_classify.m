function out = trace4bus_classify(app)
    %DeepTrace Technologies S.R.L. (c) - Trace4BUS
    %code for machine learning classification starting from radiomic features array 
    out = [];
    output = app.modello.output;
    results = app.modello.results;
    K = app.modello.cv.k;
    bestmodel = app.modello.bestmodel;
    batch = app.temp_data.batch;
    ss__data = app.temp_data.ss__data;
    
    for iter = 1:size(results, 1)
        for outerk = 1:K
            for innerk = 1:K
                % Preprocessing: testing data
                % Harmonize dataset for multi-site/multi-scan differences
                ss__data = ...
                    harmonize__ss(results(iter, bestmodel).params(outerk, innerk), ...
                    ss__data, batch);

                % Max-min normalization
                te_data = ...
                    (ss__data - results(iter, bestmodel).params(outerk, innerk).min__) ./ ...
                    results(iter, bestmodel).params(outerk, innerk).max__;

                % Feature transform: extraction / selection / ranking
                if bestmodel == 1
                    ...
                elseif bestmodel == 2
                    ftinput.data = te_data;
                    te_data = ...
                        feat__transform(...
                        results(iter, bestmodel).params(outerk, innerk).f__transform, ftinput, 'II'); 
                    te_data = ...
                        squeeze(te_data(:, 1:results(iter, bestmodel).opdim(outerk, innerk).comp));
                elseif bestmodel == 3
                    ftinput.data = te_data;
                    te_data = ...
                        feat__transform(...
                        results(iter, bestmodel).params(outerk, innerk).f__transform, ftinput, 'II'); 
                    te_data = ...
                        squeeze(te_data(:, 1:results(iter, bestmodel).opdim(outerk, innerk).comp__3));
                end

                % Classification
                [class, postprob] = ...
                    ml__classify(results(iter, bestmodel).model(outerk, innerk), te_data);
                if class == 0
                    postprob = max(postprob);
                elseif class == 1
                    postprob = min(postprob);
                end 

                if ~exist('scores','var')
                    scores = zeros(iter, K, K);
                    pprob = zeros(iter, K, K);
                end
                scores(iter, outerk, innerk) = class;
                pprob(iter, outerk, innerk) = postprob;

                clear te_data
            end
        end
    end

%     cv__scores = scores;
    % predicted__score = round(mean(mean(mean(scores))));
    
    if startsWith(batch,'ESAOTE')
        temp_th = 0.198;
    else
        temp_th = 0.172;
    end
    if app.malign__zero
        app.th = 0.50;
    else
        app.th = temp_th;
    end
    
    predicted__score = (mean(mean(mean(pprob))) < app.th);
    if predicted__score == 0
        predicted__pprob = mean(mean(mean(pprob)));
        predicted__diagnosis = output.freeze.label{1};
    elseif predicted__score == 1
        predicted__pprob = 1 - mean(mean(mean(pprob)));
        predicted__diagnosis = output.freeze.label{2};
    end

    date__str = datestr(now,'yyyymmdd-HHMM');


%         output.res__path = [mkdir__ifnotexist(fullfile(path__save)) date__str '__trace4-classification.mat'];

%         save(output.res__path, 'predicted__score', 'predicted__diagnosis', 'cv__scores');
    % Create pdf report
%         output.savedir = mkdir__ifnotexist(fullfile(path__save)); %Saving path
%         output.filename = [date__str '__trace4-report']; %Filename
    out.classification = predicted__diagnosis;
    out.class = predicted__score;
    out.pprob = predicted__pprob;
    
    
    
    
    
    if app.malign__zero
          if out.class == 0
              out.b_class = 'B3';
          else
              out.b_class = 'B2';
          end
    else
        if out.class == 0
            if out.pprob <= 0.9
                out.b_class = 'B4';
            else
                out.b_class = 'B5';
            end
        else
            out.b_class = 'B3';
        end
    end
    
    
    
%if output.class == 0
%     switch app.answer1
%     case 'Yes'
%         switch app.answer2
%             case 'Yes' % 0% di malignancy with second opinion
% %                 app.testo = 'The breast mass has been predicted to have >0% likelihood of malignancy: short-interval follow-up or continuous surveillance is suggested.';
%                 app.testo = 'The breast mass has been predicted to belong to BI-RADS 3 category (between 0% and 2% likelihood of malignancy): short-interval follow-up or continuous surveillance is suggested.';
%                 set(handles.testo_save, 'string',app.testo);
%                 app.pdf__path = trace4bus__testreport(app.testo,app.sbj_name,app.Path_Name,app.second);
%             case 'No' % 0% di malignancy without second opinion
%                 
%         end
%     case 'No'
%         switch app.answer2
%             case 'Yes' % >0% di malignancy with second opinion
%                 if output.pprob <= 0.9
%                     app.testo = 'The breast mass has been predicted to belong to BI-RADS 4 category (between 2% and 95% likelihood of malignancy): tissue diagnosis is suggested.';
%                 else
%                     app.testo = 'The breast mass has been predicted to belong to BI-RADS 5 category (more than 95% likelihood of malignancy): tissue diagnosis is suggested.';
%                 end
% %                 app.testo = 'The breast mass has been predicted to have >2% likelihood of malignancy: tissue diagnosis is suggested.';
%                 set(handles.testo_save, 'string',app.testo);
%                 app.pdf__path = trace4bus__testreport(app.testo,app.sbj_name,app.Path_Name,app.second);
%             case 'No' % >0% di malignancy without second opinion
%                 
%         end
%     end
% else
%     switch app.answer1
%     case 'Yes'
%         switch app.answer2
%             case 'Yes' % 0% di malignancy with second opinion
% %                 app.testo = 'The breast mass has been predicted to have 0% likelihood of malignancy.';
%                 app.testo = 'The breast mass has been predicted to belong to BI-RADS 2 category (0% likelihood of malignancy).';
%                 set(handles.testo_save, 'string',app.testo);
%                 app.pdf__path = trace4bus__testreport(app.testo,app.sbj_name,app.Path_Name,app.second);
%             case 'No' % 0% di malignancy without second opinion
%                 
%         end
%     case 'No'
%         switch app.answer2
%             case 'Yes' % >0% di malignancy with second opinion
% %                 app.testo = 'The breast mass has been predicted to have <2% likelihood of malignancy: short-interval follow-up or continuous surveillance is suggested.';
%                 app.testo = 'The breast mass has been predicted to belong to BI-RADS 3 category (between 0% and 2% likelihood of malignancy): short-interval follow-up or continuous surveillance is suggested.';
%                 set(handles.testo_save, 'string',app.testo);
%                 app.pdf__path = trace4bus__testreport(app.testo,app.sbj_name,app.Path_Name,app.second);
%             case 'No' % >0% di malignancy without second opinion
%                 
%         end
%     end
% end