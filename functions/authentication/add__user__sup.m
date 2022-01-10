function check = add__user__sup(varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% auth.login{1} = 'user01';
% auth.pwd{1} = 'radiomics';

% check =  1  Success
% check =  0  Username or password incorrect
% check = -1  New password mismatch
% check = -2  User already exists

    % Varargin
    usr__ = varargin{1};
%     pwd__ = varargin{2};
%     usr__ = crypting(usr__, 1, 0);
%     pwd__ = crypting(pwd__, 1, 0);
    license__fullpath = varargin{3};
    new__usr = varargin{4};
    new__pwd = varargin{5};
    confirm__newpwd = varargin{6};
    
    new__usr = crypting(new__usr, 1, 0);

    
    % Check if new__usr already exist
        % Load
        load(license__fullpath);
        next_log = size(log,1)+1;

        % Find items
        index = find(cellfun(@(s) ~isempty(strfind(new__usr,s)), auth_use.login(1,:)));
%         index = find(strcmp(auth_use.login(1,:),new__usr));
        
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
        
        check = -1; % New password mismatch
        
    elseif ~isempty(index)
        
        check = -2; % User already exists
        
    elseif lungh == 0
        check = -3; % Password too short
        
    elseif check_comp == 0
        check = -4; % Password too not complex
   
    else
        new__pwd = crypting(new__pwd, 1, 0);
%         confirm__newpwd = crypting(confirm__newpwd, 1, 0);
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
%                 index = find(strcmp(auth_use.login(1,:),usr__));
                index = 1;%find(cellfun(@(s) ~isempty(strfind(usr__,s)), auth_use.login(1,:)));
                % Associate password
%                 pwd = auth_use.pwd{1,index};

                % Compare
%                 if strcmp(pwd, pwd__)
                    new__index = size(auth_use.login,2) + 1;
                    auth_use.login{1,new__index} = new__usr;
                    if new__index<10
                        user_num=strcat('0',num2str(new__index-2));
                    else
                        user_num=strcat(num2str(new__index-2));
                    end
                    auth_use.login{2,new__index} = user_num;
                    auth_use.login(3,new__index) = auth_use.login(3,index);
    %                 auth_use.pwd{new__index} = new__pwd;
                    auth_use.pwd{1,new__index} = new__pwd;
                    auth_use.pwd{2,new__index} = 1;
                    auth_use.pwd{3,new__index} = 0;

                    auth_use.pwd{4,new__index} = now_date + calmonths(security_settings.expiration);
                    auth_use.pwd{4,new__index} = crypting(auth_use.pwd{4,new__index}, 1, 1);
                    auth_use.pwd{5,new__index} = now_date + calmonths(security_settings.expiration_acc);
                    auth_use.pwd{5,new__index} = crypting(auth_use.pwd{5,new__index}, 1, 1);

                    auth_use.tag_button(:,new__index+1)=auth_use.tag_button(:,index+1);
                    save(license__fullpath,'auth_use','-append');
                    log{next_log,1} = now_date;
                    log{next_log,2} = usr__;
                    log{next_log,3} = {sprintf('successful add user %s',new__usr)};
                    save(license__fullpath,'log','-append');
                    check = 1; % Success
%                 else
%                     check = 0; % Username or password incorrect
%                 end
            else
                now_date = datetime('now');
                log{next_log,1} = now_date;
                log{next_log,2} = usr__;
                log{next_log,3} = {'error add user for code error'};
                save(license__fullpath,'log','-append');
                check = 7; %wrong date
            end
        catch
           
            check = 0; % Username or password incorrect
            
        end
    
    end
    
end
