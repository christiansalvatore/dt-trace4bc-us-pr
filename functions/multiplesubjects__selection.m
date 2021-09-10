function subdir = multiplesubjects__selection(fig, varargin)

    temp = uigetdir();
     
    figure(fig); % Bringing the window up 
    if ~isempty(temp) & temp~= 0
        subdir = [];
        % Fetch subfolders 
        files = dir(temp);

        % Initialize generic index and specific indexes
        index = ones(1,size(files,1));
        % index__1 = index;
        % index__2 = index;
        index__3 = zeros(1,size(files,1));

        % Find '.' and '..'
        index__1 = strcmp({files.name}, '.') == 1;
        index__2 = strcmp({files.name}, '..') == 1;

        % Find
        % (1) non-directories
        % (2) files not ending with _xxx_xxx, where xxx are 3-digit numbers
        for j = 1:size(files,1)
            try

                if files(j).isdir == 0
                    index__3(1,j) = 1;
                end

                if ( strcmp(files(j).name(end-7),'_') == 0 && ...
                        strcmp(files(j).name(end-7),'-') == 0 )
                    index__3(1,j) = 1;
                end

                if ( strcmp(files(j).name(end-3),'_') == 0 && ...
                        strcmp(files(j).name(end-3),'-') == 0 )
                    index__3(1,j) = 1;
                end

                if isnan(str2double(files(j).name(end-2:end)))
                    index__3(1,j) = 1;
                end

                if isnan(str2double(files(j).name(end-6:end-4)))
                    index__3(1,j) = 1;
                end            
                if ~isempty(varargin) && (strcmp(varargin(1),'MAMMOGRAPHY') || strcmp(varargin(1),'CT') || strcmp(varargin(1),'US'))
                    if  strcmp(files(j).name(end-7:end),'biobanca')
                        index__3(1,j) = 0;
                    end
                end
            catch

                % Error in the previous statements
                index__3(1,j) = 1;

            end
        end

        % Exclude all previous findings
        index(index__1) = 0;
        index(index__2) = 0;
        index(logical(index__3)) = 0;

        % Populate subdir (cell)
        counter = 1;
        for i = 1:size(index,2)
            if index(1,i) ~= 0
                subdir{counter} = fullfile(files(i).folder, files(i).name);
                counter = counter + 1;
            end
        end
        if isempty(subdir)
            subdir = 1;
        end
    else
        subdir=[];
    end
    
    
end

