function check = authentication(varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% auth.login{1} = 'user01';
% auth.pwd{1} = 'radiomics';

    % Varargin
    usr__ = varargin{1};
    pwd__ = varargin{2};
    license__fullpath = varargin{3};
    
    % Load
    load(license__fullpath);
    
    mac_ok = checkmac_code(mac_value);
    total_ok = 0;
    if mac_ok == 0
        waitfor(msgbox(sprintf('License error 21210904. Unrecognised hardware.\nIf the problem persists, please, contact the software provider.'),'License error','error'));
    else
        date_times = web__datetime;
        if ~isdatetime(date_times)
            [date_ok, last_date] = checkdate(last_date);
        else
            date_ok = 1;
            last_date = date_times;
        end
        
        if date_ok == 0
            waitfor(msgbox(sprintf('License error 04012005.\nPlease, contact the software provider.'),'License error','error'));
        else
            [license_year_ok,annual_licenses,anniversary,warnings] = checkyear(anniversary,annual_licenses,warnings,last_date);
            if license_year_ok == 0
            else
                total_ok = 1;
                save(license__fullpath,'annual_licenses','-append','anniversary','-append','warnings','-append','last_date','-append');
            end
        end
    end
%     total_ok=1;
    
    
    
    if total_ok == 1
        % Find items
        
        index = find(strcmp(auth.login,usr__));
        if isempty(index)
            check = 0; % Error
        else
            % Associate password
            pwd = auth.pwd{index};

            % Compare
            if strcmp(pwd, pwd__)
                check = 1; % Success

                if strcmp(usr__,'superuser')
                    check = -1;
                elseif index == 1
                    check = -2;
                end

            else
                check = 0; % Error
            end
        end
    else
        check = 2;
    end
    
end
