function [license_year_ok,annual_licenses,anniversary,warnings] = checkyear(anniversary,annual_licenses,warnings,now_date)
%     now_date = datetime('today');
    license_year_check = 0;
    difference_days=between(now_date,anniversary,'days');
    difference_days=char(difference_days);
    difference_days=difference_days(1:end-1);
    difference_days=str2double(difference_days);
    if difference_days<=0
        license_year_check = 1;
    elseif difference_days<=30 && difference_days>15 && warnings.thirty == 0
        waitfor(msgbox(sprintf('Warning, your annual license will expire in less than 1 mounth.\nPlease, contact the software provider for new license key.'),'License expiration','warn'));
        warnings.thirty = 1;
    elseif difference_days<=15 && difference_days>7 && warnings.fifteen == 0
        waitfor(msgbox(sprintf('Warning, your annual license will expire in less than 15 days.\nPlease, contact the software provider for new license key.'),'License expiration','warn'));
        warnings.fifteen = 1;
    elseif difference_days<=7 && difference_days>1 && warnings.seven == 0
        waitfor(msgbox(sprintf('Warning, your annual license will expire in less than 7 days.\nPlease, contact the software provider for new license key.'),'License expiration','warn'));
        warnings.seven = 1;
    elseif difference_days == 1 && warnings.one == 0
        waitfor(msgbox(sprintf('Warning, your annual license will expire tomorrow.\nPlease, contact software the provider for new license key.'),'License expiration','warn'));
        warnings.one = 1;        
    end
    license_year_ok = 0;
    if license_year_check == 1
        code_list1=annual_licenses(:,2);
        while license_year_ok<1
            if isempty(find([code_list1{:}] == 1, 1))
                in_code = inputdlg({sprintf('Please, insert license key:')},...
                      'License', [1 36]);
            else
                try in_code = inputdlg({sprintf('Warning, your annual license expired.\nPlease, insert new license key:')},...
                      'License', [1 38], in_code);
                catch
                    in_code = inputdlg({sprintf('Warning, your annual license expired.\nPlease, insert new license key:')},...
                      'License', [1 38]);
                end
            end
            if isempty(in_code)
                waitfor(msgbox(sprintf('Error, license key not provided.'),'License expired','error'));
                license_year_ok = 2;
            else
                in_code_char = in_code{1};
                if isempty(in_code_char)
                    waitfor(msgbox(sprintf('Error, license key not provided.'),'License expired','error'));
                    license_year_ok = 0;
                else
                    [hundred_ok, annual_licenses] = checkhundred_code(in_code_char, annual_licenses);
                    if hundred_ok == 1
                        waitfor(msgbox(sprintf('License key recognised, your annual license was extended.'),'License extended','error'));
                        anniversary = anniversary + calyears(1);
                        license_year_ok = 1;
                        warnings.one = 0;
                        warnings.seven = 0;
                        warnings.fifteen = 0;
                        warnings.thirty = 0;
                    else
                        license_year_ok = 0;
                        waitfor(msgbox(sprintf('Error, license key is incorrect.\nPlease check your key'),'License expired','error'));
                    end
                end
            end
        end
        
    else
        license_year_ok = 1;
    end
    if license_year_ok == 2
        license_year_ok = 0;
    end
end