function varargout = increase__counter(varargin)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    if nargin == 2
        license__path = varargin{1};
        category = varargin{2};
        
        load(license__path,'counter');
        counter.(category) = counter.(category) + 1;
        counter.global = counter.global + 1;
        save(license__path,'counter','-append');
    elseif nargin == 3
        license__path = varargin{1};
        category__1 = varargin{2};
        category__2 = varargin{3};
        
        load(license__path,'counter');
        try
            counter.(category__1).(category__2) = counter.(category__1).(category__2) + 1;
        catch
            counter.(category__1).(category__2) = 1;
        end
        counter.global = counter.global + 1;
        save(license__path,'counter','-append');        
    end
end
