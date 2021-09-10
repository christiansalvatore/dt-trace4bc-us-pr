function [date_ok, last_date] = checkdate(last_date)
%     now_date = str2double(datestr(now,'yyyymmddHHMM'));
    now_date = datetime('now');
    difference_days=between(last_date,now_date,'Time');
    DateVector = datevec(difference_days);
    if DateVector(4)<0 || (DateVector(4)==0 && DateVector(5)<=0 && DateVector(6)<=0)
        date_ok = 0;
    else
        date_ok = 1;
        last_date = now_date;
    end
end