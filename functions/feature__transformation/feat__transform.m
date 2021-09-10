function [out, params] = feat__transform(ftparams, in, phase)

    % Initial var definition    
    params = ftparams;
    
    switch phase
        
        % Perform extraction / selection / ranking on a new dataset
        case 'I'

            % Feature extraction
            try

                ftparams.ftmethod.fe;

                switch ftparams.ftmethod.fe

                    case 'pca'
                        [temp.data, params.fe] = pca__extraction(in.data, []);

                    case 'pls'
                        [temp.data, ~, params.fe] = plsregression(in.data, ...
                        in.labels, in.comp);

                    otherwise
                        temp.data = in.data;
                        try temp.labels = in.labels; end                

                end

            catch

                temp.data = in.data;
                try temp.labels = in.labels; end

            end

            %
            %
            %
            %
            %

            % Feature ranking
            try

                ftparams.ftmethod.fr;

                switch ftparams.ftmethod.fr

                    case 'fdr'
                        [temp.data, params.fr, ~, ~] = fdrranking(temp.data, ...
                        in.labels, []); 

                    otherwise
                        ...

                end

            catch

                ...

            end

            out = temp.data;

        %
        %
        %
        %
        %
        
        % Apply extraction / selection / ranking on new data
        case 'II'
            
            % Feature extraction
            try

                ftparams.ftmethod.fe;

                switch ftparams.ftmethod.fe

                    case 'pca'
                        temp.data = data2pca(in.data, params.fe);

                    case 'pls'
                        temp.data = data2pls(in.data, params.fe);

                    otherwise
                        temp.data = in.data;
                        try temp.labels = in.labels; end                

                end

            catch

                temp.data = in.data;
                try temp.labels = in.labels; end

            end

            %
            %
            %
            %
            %

            % Feature ranking
            try

                ftparams.ftmethod.fr;

                switch ftparams.ftmethod.fr

                    case 'fdr'
                        temp.data = temp.data(params.fr);

                    otherwise
                        ...

                end

            catch

                ...

            end

            out = temp.data;        
        
    end           
    
end