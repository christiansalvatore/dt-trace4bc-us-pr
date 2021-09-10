function [data, N] = t4bc__loadmat__alg(path)

    files = dir(fullfile(path,'*.mat'));
    for n = 1:size(files,1)
        mat__data = load(fullfile(path,files(n).name));
        features = mat__data.racat_feat_str;
        data(n,:) = double((cell2mat(features(:,11)))');
    end
    
    if ~exist('data','var')
        mat__data = load(path);
        features = mat__data.racat_feat_str;
        data(1,:) = double((cell2mat(features(:,11)))');
    end

    N = size(data,1);

end
