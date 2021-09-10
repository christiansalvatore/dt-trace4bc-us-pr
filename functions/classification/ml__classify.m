function [class, prob] = ml__classify(model, indata)

    switch model.method
        
        % Training of the model
        case 'svm'

            [class, prob] = predict(model.model, indata);
            class = cast(class,'double');
            
        case 'rf'

            [class, prob] = predict(model.model, indata);
            class = str2double(class{1});
            
        case 'knn'

            [class, prob] = predict(model.model, indata);        
                    
    end

end
