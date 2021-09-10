function outdata = combat__singlesbj(indata, batch, std__mean,...
    var__pooled, gamma__star, delta__star)

    %
    % Compute single-subject data harmonized to a given model whose parameters
    % are passed as input to this function.
    % Use "combat.m" to compute the parameters of the model (multiple subjects
    % needed).
    % It works with multiple single-subject data.
    %
    % indata -> columns = subjects
    %           rows = features
    % batch  -> columns = subjects
    %           1 row
    %

    outdata = zeros(size(indata,1), size(indata,2));
    
    for sbj = 1:size(indata,2)

        outdata(:,sbj) = (indata - std__mean) ./ (sqrt(var__pooled));
        batch__sbj = batch(1,sbj);

        outdata(:,sbj) = (outdata(:,sbj) -...
            (gamma__star(batch__sbj,:))') ./...
            (sqrt(delta__star(batch__sbj,:))');
        
        outdata(:,sbj) = (outdata(:,sbj) .* (sqrt(var__pooled))) +...
            std__mean;
        
    end

end
