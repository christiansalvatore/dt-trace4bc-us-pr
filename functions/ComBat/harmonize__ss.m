function outdata = harmonize__ss(params, data, batch)

    if params.harm.flag == 1

        try
            
            % Data
            dat = data';

            % Remove rows with constant values across samples
            if size(params.constantrows__ind,2) == 1 && ...
                    ~isempty(params.constantrows__ind)
                deleted__row = dat(params.constantrows__ind, :);
                dat = [dat(1:params.constantrows__ind-1, :);...
                    dat(params.constantrows__ind+1:end, :)];
            else
                ...
            end

            % Scan or site
            batch__str = batch;
            ind = find(strcmp(params.harm.batches__str,batch__str));
            if size(ind,2) > 1
                batch = params.harm.batch(ind(1));
            else
                ...
            end
            
            bayesdata = combat__singlesbj(dat, batch, params.harm.std, ...
                params.harm.var, params.harm.gamma_star, ...
                params.harm.delta_star);
            
            % Restore rows with constant values across samples
            if size(params.constantrows__ind,2) == 1 && ...
                    ~isempty(params.constantrows__ind)
                bayesdata = [bayesdata(1:params.constantrows__ind-1, :);...
                    deleted__row; ...
                    bayesdata(params.constantrows__ind:end, :)];
            else
                ...
            end            

            outdata = bayesdata';            
            
        catch
        
            outdata = data;
            
        end

    else

        outdata = data;

    end

end
