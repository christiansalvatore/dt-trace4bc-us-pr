
function output = t4bc__test__alg_integrato(app,h,prog,testo)
% TRACE4AD © 2019 DeepTrace Technologies S.R.L.

%                                                                             prog = 0;
%                                                                             h = waitbar(prog,'Processing...');

% Fetching input data
path__model = app.dir.model;
path__save = app.dir.save;
% path__data = app.dir.data;

GROUP_0 = 'POSITIVE';
GROUP_1 = 'NEGATIVE';

%
%
%
%
%
% Testing new subject
%
%
%
%
%

% Loading the existing model
try if isempty(app.model)
        app.model = load(path__model);
    end
catch
    app.model = load(path__model);
end
output = app.model.output;
output.model = app.model;
K = app.model.cv.k;
% array features, manuf
% % Loading single-subject img data
% [ss__data, ~, batch] = t4bc__nii2radiomics__alg(path__data, ...
%     app.model.results(1,1).params(1,1).img__type, app.pathology, 1);
ss__data = double(app.features);
if isempty (app.manuf)
    batch = 'unknown';
else
    batch = app.manuf;
end


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

% Remove lines with NaN for at least one subject
...
    
% Remove non-stable features (PERTURBATIONS)
if app.model.results(1,app.model.bestmodel).params(1,1).perturbation.flag == 1%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    try ss__data = ss__data(:, app.model.stable__features);
    catch
        ss__data = ss__data';
        ss__data = ss__data(:, app.model.stable__features);
    end
end

for iter = 1:size(app.model.results, 1)
    for outerk = 1:K
        for innerk = 1:K
    
                                                                            try
                                                                            prog = prog + (0.7/(K*K));
                                                                            waitbar(prog,h);
                                                                            drawnow
                                                                            catch
                                                                            h = waitbar(prog,testo);
                                                                            drawnow
                                                                            end

            % Preprocessing: testing data
            % Harmonize dataset for multi-site/multi-scan differences
            ss__data = ...
                harmonize__ss(app.model.results(iter, app.model.bestmodel).params(outerk, innerk), ...
                ss__data, batch);

            % Max-min normalization
            te_data = ...
                (ss__data - app.model.results(iter, app.model.bestmodel).params(outerk, innerk).min__) ./ ...
                app.model.results(iter, app.model.bestmodel).params(outerk, innerk).max__;

            % Feature transform: extraction / selection / ranking
            if app.model.bestmodel == 1
                ...
            elseif app.model.bestmodel == 2
                ftinput.data = te_data;
                te_data = ...
                    feat__transform(...
                    app.model.results(iter, app.model.bestmodel).params(outerk, innerk).f__transform, ftinput, 'II'); 
                te_data = ...
                    squeeze(te_data(:, 1:app.model.results(iter, app.model.bestmodel).opdim(outerk, innerk).comp));
            elseif app.model.bestmodel == 3
                ftinput.data = te_data;
                te_data = ...
                    feat__transform(...
                    app.model.results(iter, app.model.bestmodel).params(outerk, innerk).f__transform, ftinput, 'II'); 
                te_data = ...
                    squeeze(te_data(:, 1:app.model.results(iter, app.model.bestmodel).opdim(outerk, innerk).comp__3));
            end

            % Classification
            [class, postprob] = ...
                ml__classify(app.model.results(iter, app.model.bestmodel).model(outerk, innerk), te_data);
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

cv__scores = scores;
% predicted__score = round(mean(mean(mean(scores))));
predicted__score = (mean(mean(mean(pprob))) < 0.5);
if predicted__score == 0
    predicted__pprob = mean(mean(mean(pprob)));
    predicted__diagnosis = GROUP_0;
elseif predicted__score == 1
    predicted__pprob = 1 - mean(mean(mean(pprob)));
    predicted__diagnosis = GROUP_1;
end

date__str = datestr(now,'yyyymmdd-HHMM');
output.res__path = [mkdir__ifnotexist(fullfile(path__save)) date__str '__trace4-classification.mat'];
save(output.res__path, 'predicted__score', 'predicted__diagnosis', 'cv__scores');

% Create pdf report
output.savedir = mkdir__ifnotexist(fullfile(path__save)); %Saving path
output.filename = [date__str '__trace4-report']; %Filename
output.classification = predicted__diagnosis;
output.pprob = predicted__pprob;
output.acc = app.model.acc;
output.sen = app.model.sen;
output.spe = app.model.spe;
output.auc = app.model.auc;
% output.cp = cp;
output.sbjs = app.model.sbjs;
output.date__str = date__str;

% Remove data folder
try rmdir(fullfile(path__save,'data'),'s'); end
                                                                            
                                                                            try %#ok<*TRYNC>
                                                                            waitbar(1,h);
                                                                            close(h);
                                                                            end

end
