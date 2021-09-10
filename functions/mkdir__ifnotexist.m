function output__dir = mkdir__ifnotexist(dir)
%
% Create a folder if it does not already exist
%
% INPUT
% dir: the (path of the) directory to be created
%
% OUTPUT
% output__dir: the (path of the) directory created; this is useful, as this
% function can be called in cases like this:
% //
% saving_path = mkdir__ifnotexist([fileparts(pwd) '\results\']);
% //
% i.e., to check and assign a path to a variable at the same time.
%
% Last modified: Christian Salvatore, 2018-09-13
%

if dir(end) ~= '\'
    dir = [dir '\'];
end

if ~exist(dir, 'dir')
    mkdir(dir);
end

output__dir = dir;

end