function out = ml__train(clparams, in)

    switch clparams.clmethod.cl
        
        % Training of the model
        case 'svm'

            if in.clparams.svm.kernelscale == 0
                model = fitcsvm(in.data, in.labels,...
                    'KernelFunction', in.clparams.svm.kernel, ...
                    'Standardize', in.clparams.svm.standardize,...
                    'BoxConstraint', in.clparams.svm.boxconstraint,...
                    'KernelScale', 'auto');
            else
                model = fitcsvm(in.data, in.labels,...
                    'KernelFunction', in.clparams.svm.kernel, ...
                    'Standardize', in.clparams.svm.standardize,...
                    'BoxConstraint', in.clparams.svm.boxconstraint,...
                    'KernelScale', in.clparams.svm.kernelscale);
            end
            
            % model = compact(model);
            model = fitPosterior(model, in.data, in.labels);
            
            params.kernel = in.clparams.svm.kernel;
            params.standardize = in.clparams.svm.standardize;
            params.boxconstraint = in.clparams.svm.boxconstraint;
            params.kernelscale = in.clparams.svm.kernelscale;
            
            % Compute classification performance on the training set
            [outclass__tr, s] = predict(model, in.data);
            outscore__tr = s(:, 1);
            train__perf = classperf(in.labels, outclass__tr, ...
                'Positive', 0, 'Negative', 1);
            [~, ~, ~, trauc] = perfcurve(in.labels, outscore__tr, '0');            
            
            roc.trtargets = in.labels;
            roc.trpprobs = outscore__tr;
            roc.trscores = outclass__tr;
            roc.trauc = trauc;         
            
            % Compute feature importance / activation pattern
            % in the feature space
            fimportance = svm__activationpattern(model, in.data);
            fimportance__norm = 0;
            
        case 'rf'

            params.ntrees = 200;
            model = TreeBagger(params.ntrees, in.data, in.labels, ...
                'OOBPredictorImportance', 'on', ...
                'OOBPrediction', 'on');
            % model = compact(model);
            
            % Compute classification performance on the training set
            [l, s] = predict(model, in.data);
            outclass__tr = str2num(cell2mat(l));
            outscore__tr = s(:, 1);
            train__perf = classperf(in.labels, outclass__tr, ...
                'Positive', 0, 'Negative', 1);
            [~, ~, ~, trauc] = perfcurve(in.labels, outscore__tr, '0');
            
            roc.trtargets = in.labels;
            roc.trpprobs = outscore__tr;
            roc.trscores = outclass__tr;
            roc.trauc = trauc;
            
            % Compute feature importance (in the feature space)
            fimportance = model.OOBPermutedPredictorDeltaError;
            fimportance__norm = 1;
            
        case 'knn'

            params.nneighbors = 5;
            params.standardize = 1;
            model = fitcknn(in.data, in.labels, ...
                'NumNeighbors', params.nneighbors, ...
                'Standardize', params.standardize);
            
            % Compute classification performance on the training set
            [l, s] = predict(model, in.data);
            outclass__tr = l;
            outscore__tr = s(:, 1);
            train__perf = classperf(in.labels, outclass__tr, ...
                'Positive', 0, 'Negative', 1);
            [~, ~, ~, trauc] = perfcurve(in.labels, outscore__tr, '0');
            
            roc.trtargets = in.labels;
            roc.trpprobs = outscore__tr;
            roc.trscores = outclass__tr;
            roc.trauc = trauc;
            
            % Compute feature importance (in the feature space)
            fimportance = ones(1, size(in.data, 2));
            fimportance__norm = 1;            
        
    end
    
    out.method = clparams.clmethod.cl;
    out.model = model;
    out.params = params;
    out.train__perf = train__perf;
    out.roc = roc;
    out.fimportance = fimportance;
    out.fimportance__norm = fimportance__norm;

end

function activation__pattern = svm__activationpattern(model, data)

    % COMPUTING weight vector W of the features (after training)
    W = (model.Alpha)' * (model.SupportVectors);

    % COMPUTING covariance matrix of training data
    covData = cov(data);

    % COMPUTING activation pattern (in the feature space)
    activation__pattern = covData * W';

end
