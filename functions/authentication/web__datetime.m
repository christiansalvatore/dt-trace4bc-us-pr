function date_times = web__datetime(varargin)

    % Retrieve datetime from web
    
    date_times = NaN;
    
    % Website #1
    try        
        path = 'http://deeptracetech.com/utils/datetime__now.html';
        time = webread(path);
        date_times = time;
        clear time
    catch
        % Website #2        
        try
            % Retrieve from web
            path = 'http://worldtimeapi.org/api/ip';
            time = webread(path);
            %time = time.unixtime;                
            time = time.datetime;
            time = [time(1:4) time(6:7) time(9:10) ...
                time(12:13) time(15:16)];
            
            % Assign
            date_times = time;
            clear time
            
        catch
            
            % Website #3
            try

                ...

            end        
                
        end
        
    end
    if ~isnan(date_times)
        try date_year = str2double(date_times(1:4));
            date_month = str2double(date_times(5:6));
            date_day = str2double(date_times(7:8));
            date_hour = str2double(date_times(9:10));
            date_min = str2double(date_times(11:12));
        catch
            date_times=num2str(date_times);
            date_year = str2double(date_times(1:4));
            date_month = str2double(date_times(5:6));
            date_day = str2double(date_times(7:8));
            date_hour = str2double(date_times(9:10));
            date_min = str2double(date_times(11:12));
        end
        date_times = datetime(date_year,date_month,date_day,date_hour,date_min,0);
    end

end