function check = reset__password(varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% auth.login{1} = 'user01';
% auth.pwd{1} = 'radiomics';

    % Varargin
    usr__ = varargin{1};
    pwd__ = varargin{2};
    usr__ = crypting(usr__, 1, 0);
    pwd__ = crypting(pwd__, 1, 0);
    license__fullpath = varargin{3};
    new__pwd = varargin{4};
    confirm__newpwd = varargin{5};
    orig = varargin{6};
    % Load
    load(license__fullpath);
    next_log = size(log,1)+1;
    %check password length
    if length(new__pwd)<security_settings.min_length
        lungh = 0;
    else
        lungh = 1;
    end

    %check password complexity
    if security_settings.complexity == 1
        check_comp = check_complexity(new__pwd);
    else
        check_comp = 1;
    end
    
    
    if ~strcmp(new__pwd,confirm__newpwd)
        
        check = -1;
    elseif lungh == 0
        check = -3; % Password too short
        
    elseif check_comp == 0
        check = -4; % Password too not complex
        
    else
    
        try
            date_times = web__datetime;
            if ~isdatetime(date_times)
                last_date = crypting(last_date, 0, 1);
                [date_ok, last_date] = checkdate(last_date);
            else
                date_ok = 1;
                last_date = date_times;
            end
            if date_ok == 1
                now_date = last_date;
                last_date = crypting(last_date, 1, 1);
                save(license__fullpath,'last_date','-append');
                % Find items
                index = find(strcmp(auth_use.login(1,:),usr__));

                % Associate password
                pwd = auth_use.pwd{1,index};

                % Compare
                if strcmp(pwd, pwd__)
                    auth_use.pwd{1,index} = new__pwd;
                    if orig == 1
                        auth_use.pwd{2,index} = 1;
                    else
                        auth_use.pwd{2,index} = 0;
                    end
                    auth_use.pwd{3,index} = 0;
                    auth_use.pwd{4,index} = now_date + calmonths(security_settings.expiration);
                    auth_use.pwd{4,index} = crypting(auth_use.pwd{4,index}, 1, 1);
                    save(license__fullpath,'auth_use','-append');
                    log{next_log,1} = now_date;
                    log{next_log,2} = usr__;
                    log{next_log,3} = {'successful change password'};
                    save(license__fullpath,'log','-append');
                    check = 1;
                else
                    check = 0;
                end
            else
                now_date = datetime('now');
                log{next_log,1} = now_date;
                log{next_log,2} = usr__;
                log{next_log,3} = {'error add user for code error'};
                save(license__fullpath,'log','-append');
                check = 7; %wrong date
            end
            
        catch
           
            check = 0;
            
        end
    
    end
    
end
