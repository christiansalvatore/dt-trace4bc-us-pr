function [data0, data1, params] = harmonize(harmonization, params, ...
    outerk, innerk, data0, data1, batch0, batch1)

    N0 = size(data0, 1);
    N1 = size(data1, 1);

    if harmonization == 1

        try
            
            % Data
            dat = [data0; data1]';

            % Remove rows with constant values across samples
            try
                params(outerk, innerk).constantrows__ind;
            catch
                occur = (dat == 64);
                DelRow = sum(occur, 2) == size(occur, 2);
                params(outerk, innerk).constantrows__ind = find(DelRow);
            end
            if size(params(outerk, innerk).constantrows__ind,2) == 1 && ...
                ~isempty(params(outerk, innerk).constantrows__ind)
                deleted__row = ...
                    dat(params(outerk, innerk).constantrows__ind, :);
                dat = ...
                    [dat(1:params(outerk, innerk).constantrows__ind-1, :);...
                    dat(params(outerk, innerk).constantrows__ind+1:end, :)];
            else
                ...
            end

            % Scan or site
            params(outerk, innerk).harm.batches__str = [batch0 batch1];
            batch__unique = unique(params(outerk, innerk).harm.batches__str);
            for sbj = 1:size(params(outerk, innerk).harm.batches__str,2)
                idx = find(strcmp(batch__unique,...
                    params(outerk, innerk).harm.batches__str{sbj}));
                params(outerk, innerk).harm.batch(sbj) = idx;
            end

            % Diagnosis
            params(outerk, innerk).harm.mod = [ones(N0,1); 2*ones(N1,1)];

            % Parametric
            params(outerk, innerk).harm.parametric = 1;

            [bayesdata, params(outerk, innerk).harm.std, ...
                params(outerk, innerk).harm.var,...
                params(outerk, innerk).harm.gamma_star, ...
                params(outerk, innerk).harm.delta_star,...
                params(outerk, innerk).harm.parametric] = ...
                combat(dat, params(outerk, innerk).harm.batch,...
                params(outerk, innerk).harm.mod, ...
                params(outerk, innerk).harm.parametric);
            
            % Restore rows with constant values across samples
            if size(params(outerk, innerk).constantrows__ind,2) == 1 && ...
                ~isempty(params(outerk, innerk).constantrows__ind)
                bayesdata = ...
                    [bayesdata(1:params(outerk, innerk).constantrows__ind-1, :);...
                    deleted__row; ...
                    bayesdata(params(outerk, innerk).constantrows__ind:end, :)];
            else
                ...
            end            

            data0 = (bayesdata(:, 1:N0))';
            data1 = (bayesdata(:, N0+1:end))';
            
            params(outerk, innerk).harm.flag = 1;
            
        catch
        
            params(outerk, innerk).harm.flag = 0;
            
        end

    else

        params(outerk, innerk).harm.flag = 0;

    end

end
