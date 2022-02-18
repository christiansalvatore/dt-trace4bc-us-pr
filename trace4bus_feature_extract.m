function out = trace4bus_feature_extract(app)
    %DeepTrace Technologies S.R.L. (c) - Trace4BUS
    %code for radiomic features extraction starting from 2D US image
    out = [];
    try 
        output = app.modello.output;
        results = app.modello.results;
    %     K = app.modello.cv.k;
    %     bestmodel = app.modello.bestmodel;
        rad_settings = app.modello.output.rad_settings;
        [ss__data, ~, batch, ~, shape_feat] = t4__vol2radiomicsTOOL__alg(app.dicm_fig,app.temp.mask2,...
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
            ss__data = ss__data(:, app.modello.stable__features);
        end
        out.ss__data = ss__data;
        out.batch = batch;
        out.shape_feat = shape_feat;
    catch
    end