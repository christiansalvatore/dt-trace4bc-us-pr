function [hundred_ok, code_list] = checkhundred_code(in_code, code_list)
    code_list1=code_list(:,1);
    Index = find(contains(code_list1,in_code));
    if isempty(Index)
        hundred_ok = 0;
    else
        check_used = code_list{Index,2};
        if check_used == 0
            code_list{Index,2}=1;
            hundred_ok = 1;
        else
            hundred_ok = 0;
        end
    end
end