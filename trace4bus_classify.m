function out = trace4bus_classify(app)

    if strcmpi(app.answer1,'Yes')
        app.th = 0.50;
    else
        app.th = 1-0.77;
    end
    output = app.modello.output;
    results = app.modello.results;
    K = app.modello.cv.k;
    bestmodel = app.modello.bestmodel;
    rad_settings = app.modello.output.rad_settings;
    [ss__data, ~, batch] = t4__vol2radiomicsTOOL__alg(app.dicm_fig,app.temp.mask2,...
    app.img__type, app.info, rad_settings);
    ss__data = double(ss__data);
    output.sstest__fullradiomics__noclinical = ss__data;
    % Check for clinical features
    clin=0;
    for i = 1:size(output.feature__specs,1)
        fam=output.feature__specs{i,1};
        if strcmpi(fam,'clinical')
            clin=clin+1;
            clin_feat{1,clin}=output.feature__specs{i,2};
        end
    end

    if clin>0
        answers=0;
        while answers<1
            answers=1;
            prompt = clin_feat;
            dlgtitle = 'Clinical features';
            dims = [1 35];
        %     definput = {'0','hsv'};
            answer = inputdlg(prompt,dlgtitle,dims);
            if ~isempty(answer)
                for i = 1:length(answer)
                    feat_name=clin_feat{1,i};
                    k=strfind(feat_name,'-');
                    k1=strfind(feat_name,'[');
                    k2=strfind(feat_name,']');
                    minim=str2double(feat_name(k1(1)+1:k(1)-1));
                    maxim=str2double(feat_name(k(1)+1:k2(1)-1));
                    if isempty(answer{i,1}) || isnan(str2double(answer{i,1}))
                        answers=0;
                    else
                        if str2double(answer{i,1})<minim || str2double(answer{i,1})>maxim
                            answers=0;
                        end
                    end
                end
                if answers==0
                    msg='Please fill all fields with values compliant with ranges';
                    f = errordlg(msg);
                    waitfor(f)
                end
            else
                msg='Please fill all fields with values compliant with ranges';
                f = errordlg(msg);
                waitfor(f)
            end

        end
        n_feat_clin=length(answer);
        for i=1:n_feat_clin
            answer2(i)=str2double(answer{i,1});
        end
        ss__data(1,end+1:end+n_feat_clin)=answer2;
    end

    % Remove non-stable features (PERTURBATIONS)
    if results(1,1).params(1,1).perturbation.flag == 1
        ss__data = ss__data(:, stable__features);
    end

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
        