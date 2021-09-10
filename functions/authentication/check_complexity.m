function out = check_complexity(password)

atLeastOneLC = '(?=.*?[a-z])';
atLeastOneUC = '(?=.*?[A-Z])';
atLeastOneDigit = '(?=.*?\d)';
matchAll = '.*';
passwdCriteria =   [atLeastOneLC,atLeastOneUC,atLeastOneDigit,matchAll];
out = ~isempty(regexp(password,passwdCriteria,'once'));
end