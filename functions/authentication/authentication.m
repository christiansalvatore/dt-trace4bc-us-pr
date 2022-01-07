function [check,buttons_ok] = authentication(varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% auth.login{1} = 'user01';
% auth.pwd{1} = 'radiomics';

    % Varargin
    usr__ = varargin{1};
    pwd__ = varargin{2};
    license__fullpath = varargin{3};
    local_license = license__fullpath.local;
    private_license = license__fullpath.private;
    % Load
    local = load(local_license);
    private = load(private_license);
    log = local.log;
    next_log = size(log,1)+1;
%     if (counter.bus.testmodel>=counter.demomax.bus && counter.demomax.bus>0) %update per provare n classificazioni (se n>0)
%         check = -25;
%         buttons_ok=[];
%     else
        mac_ok = checkmac_code(private.mac_value);
        total_ok = 0;
        if mac_ok == 0
            waitfor(msgbox(sprintf('License error 21210904. Unrecognised hardware.\nIf the problem persists, please, contact the software provider.'),'License error','error'));
        else
            
            annual_licenze = 1;
            
            if annual_licenze == 1
                date_times = web__datetime;
                if ~isdatetime(date_times)
                    [date_ok, local.last_date] = checkdate(local.last_date);
                else
                    date_ok = 1;
                    local.last_date = date_times;
                end

                if date_ok == 0
                    waitfor(msgbox(sprintf('License error 04012005.\nPlease, contact the software provider.'),'License error','error'));
                else
                    tot_annual_licenses = [private.annual_licenses,local.annual_licenses_count];
                    [license_year_ok,tot_annual_licenses,local.anniversary,local.warnings] = checkyear(local.anniversary,tot_annual_licenses,local.warnings,local.last_date);
                    if license_year_ok == 0
                    else
                        total_ok = 1;
                        annual_licenses_count = tot_annual_licenses(:,2);
                        warnings = local.warnings;
                        last_date = local.last_date;
                        anniversary = local.anniversary;
                        save(local_license,'annual_licenses_count','-append','anniversary','-append','warnings','-append','last_date','-append');
                    end
                end
            else
                total_ok = 1;
            end
        end

        if total_ok == 1
            auth.login = [private.auth.login,local.auth_use.login];
            auth.pwd = [private.auth.pwd,local.auth_use.pwd];
            auth_use.tag_button = local.auth_use.tag_button;
            auth.tag_button = [private.auth.tag_button,local.auth_use.tag_button];
            security_settings = local.security_settings;
            security_settings.retrive = [private.security_settings.retrive,local.security_settings.retrive];
            % Find items
        %     index = find(contains(auth.login,usr__));
            index = find(strcmp(auth.login(1,:),usr__));
            if isempty(index)
                check = 0; % Error
                buttons_ok=[];
                now_date = datetime('now');
                log{next_log,1} = now_date;
                log{next_log,2} = 'Unknown';
                log{next_log,3} = {'error login username'};
            else
                if auth.pwd{3,index} >= local.security_settings.max_error
                    buttons_ok=[];
                    now_date = datetime('now');
                    log{next_log,1} = now_date;
                    log{next_log,2} = usr__;
                    log{next_log,3} = {'error login user suspended'};
                    if index == size(private.auth.login,2)+1
                        %superadmin error
                        ind = find([security_settings.retrive{:,3}] == 2);
                        if isempty(ind)
                            check = 9;
                            log{next_log,1} = now_date;
                            log{next_log,2} = usr__;
                            log{next_log,3} = {'error login user suspended'};
                        else
                            pwd = auth.pwd{1,index};
                            if strcmp(pwd, pwd__)
                                check = 3; % Success
                                auth.pwd{3,index} = 0;
                                auth_use.pwd = auth.pwd(:,size(private.auth.login,2)+1:end);
                                auth_use.login = auth.login(:,size(private.auth.login,2)+1:end);
                                local.security_settings.retrive(ind,1)={1};
                                
                                security_settings = local.security_settings;
                                save(license__fullpath.local,'auth_use','-append');
                                save(license__fullpath.local,'security_settings','-append');
                                log{next_log,1} = now_date;
                                log{next_log,2} = usr__;
                                log{next_log,3} = {'correct password reset'};
                            else
                                check = 9;
                                log{next_log,1} = now_date;
                                log{next_log,2} = usr__;
                                log{next_log,3} = {'error login user suspended'};
                            end
                        end
                    else
                        check = 5;
                        log{next_log,1} = now_date;
                        log{next_log,2} = usr__;
                        log{next_log,3} = {'error login user suspended'};
                    end
                else
                    % Associate password
                    pwd = auth.pwd{1,index};

                    % Compare
                    if strcmp(pwd, pwd__)

                        check = 1; % Success
                        auth.pwd{3,index} = 0;
                        auth_use.pwd = auth.pwd(:,size(private.auth.login,2)+1:end);
                        auth_use.login = auth.login(:,size(private.auth.login,2)+1:end);
                        save(license__fullpath.local,'auth_use','-append');

%                         date_times = web__datetime;
%                         if ~isdatetime(date_times)
%                             [date_ok, last_date] = checkdate(last_date);
%                         else
%                             date_ok = 1;
%                             last_date = date_times;
%                         end
                        if date_ok == 1
%                             save(license__fullpath,'last_date','-append');

                            now_date = local.last_date;

                            try difference_days=between(now_date,auth.pwd{4,index},'Month');
                            catch
                                auth.pwd{4,index} = now_date + calmonths(local.security_settings.expiration);
                                difference_days=between(now_date,auth.pwd{4,index},'Month');
                                auth_use.pwd = auth.pwd(:,size(private.auth.login,2)+1:end);
                                auth_use.login = auth.login(:,size(private.auth.login,2)+1:end);
                                save(license__fullpath.local,'auth_use','-append');
                            end
                            DateVector = datevec(difference_days);
                            if index >3
                                if DateVector(2)<=0
                                    difference_days=between(now_date,auth.pwd{4,index},'Day');
                                    DateVector = datevec(difference_days);
                                    if DateVector(3)<=0
                                        date_ok = 0;
                                    elseif DateVector(3) <=15 && DateVector(3)>0
                                        date_ok = 1;
                                        msgbox('Warning, password will expire soon. Please renew it.','Password warning','warn');
                                    else
                                        date_ok = 1;
                                    end
                                else
                                    date_ok = 1;
                                end
                            else
                                date_ok = 1;
                            end
                            if date_ok == 1
                                if strcmp(usr__,'superuser')
                                    check = -1;
                                    date_ok = 1;
                                elseif index == size(private.auth.login,2)+1
                                    check = -2;
                                    date_ok = 1;
                                elseif index == 2
                                    date_ok = 1;
                                else
                                    try difference_days=between(now_date,auth.pwd{5,index},'Month');
                                    catch
                                        auth.pwd{5,index} = now_date + calmonths(local.security_settings.expiration_acc);
                                        difference_days=between(now_date,auth.pwd{5,index},'Month');
                                        auth_use.pwd = auth.pwd(:,size(private.auth.login,2)+1:end);
                                        auth_use.login = auth.login(:,size(private.auth.login,2)+1:end);
                                        save(license__fullpath.local,'auth_use','-append');
                                    end
                                    DateVector = datevec(difference_days);
                                    if DateVector(2)<=0
                                        difference_days=between(now_date,auth.pwd{5,index},'Day');
                                        DateVector = datevec(difference_days);
                                        if DateVector(3)<=0
                                            date_ok = 0;
                                        else
                                            date_ok = 1;
                                        end
                                    else
                                        date_ok = 1;
                                    end
                                end
                                if date_ok == 1
                                    for i = 1:size(auth.tag_button,1)
                                        buttons_ok{i,1}=auth.tag_button{i,1};
                                        buttons_ok{i,2}=auth.tag_button{i,index+1};
                                        buttons_ok{i,3}=auth.login{2,index};
                                        buttons_ok{i,4}=auth.login{3,index};
                                    end
                                    if auth.pwd{2,index} == 1
                                        check = 3;
                                    end
                                    log{next_log,1} = now_date;
                                    log{next_log,2} = usr__;
                                    log{next_log,3} = {'successful login'};
                                    auth.pwd{5,index} = now_date + calmonths(local.security_settings.expiration_acc);
                                    auth_use.pwd = auth.pwd(:,size(private.auth.login,2)+1:end);
                                    auth_use.login = auth.login(:,size(private.auth.login,2)+1:end);
                                    save(license__fullpath.local,'auth_use','-append');
%                                     save(license__fullpath,'auth','-append');
                                else
                                    %expired account
                                    log{next_log,1} = now_date;
                                    log{next_log,2} = usr__;
                                    log{next_log,3} = {'error login for expired account'};
                                    check = 8;
                                    buttons_ok = [];
                                end

                            else
                                if strcmp(usr__,'superuser')
                                    check = -1;
                                    log{next_log,1} = now_date;
                                    log{next_log,2} = usr__;
                                    log{next_log,3} = {'successful login'};
                                    for i = 1:size(auth.tag_button,1)
                                        buttons_ok{i,1}=auth.tag_button{i,1};
                                        buttons_ok{i,2}=auth.tag_button{i,index+1};
                                        buttons_ok{i,3}=auth.login{2,index};
                                        buttons_ok{i,4}=auth.login{3,index};
                                    end
    %                             elseif index == 1
    %                                 check = -2;
    %                                 log{next_log,1} = now_date;
    %                                 log{next_log,2} = usr__;
    %                                 log{next_log,3} = {'successful login'};
                                elseif index == 2
                                    for i = 1:size(auth.tag_button,1)
                                        buttons_ok{i,1}=auth.tag_button{i,1};
                                        buttons_ok{i,2}=auth.tag_button{i,index+1};
                                        buttons_ok{i,3}=auth.login{2,index};
                                        buttons_ok{i,4}=auth.login{3,index};
                                    end
                                    check = 1;
                                    log{next_log,1} = now_date;
                                    log{next_log,2} = usr__;
                                    log{next_log,3} = {'successful login'};
                                else
                                    check = 6;% pass expired
                                    log{next_log,1} = now_date;
                                    log{next_log,2} = usr__;
                                    log{next_log,3} = {'error login for expired password'};
                                    buttons_ok = [];
                                end

                            end
                        else
                            check = 7; %wrong date
                            now_date = datetime('now');
                            log{next_log,1} = now_date;
                            log{next_log,2} = usr__;
                            log{next_log,3} = {'error login for code error'};
                            buttons_ok = [];
                        end


                    else

                        auth.pwd{3,index} = auth.pwd{3,index}+1;
                        auth_use.pwd = auth.pwd(:,size(private.auth.login,2)+1:end);
                        auth_use.login = auth.login(:,size(private.auth.login,2)+1:end);
                        save(license__fullpath.local,'auth_use','-append');
%                         save(license__fullpath,'auth','-append');
                        check = 40+auth.pwd{3,index}; % Error
                        buttons_ok=[];
                        now_date = datetime('now');
                        log{next_log,1} = now_date;
                        log{next_log,2} = usr__;
                        log{next_log,3} = {'error login password'};
                    end
                end
            end
        else
            check = 2;
            now_date = datetime('now');
            log{next_log,1} = now_date;
            log{next_log,2} = 'Unknown';
            log{next_log,3} = {'error login system'};
        end
        
        save(license__fullpath.local,'log','-append');
%     end
end
