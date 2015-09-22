function addpathrec(path)

% addpathrec -- add all directories and subdirectories recursively
%               to matlab pathdefs variable
%
%   addpathrec(path);
%
%   path is a string pointing to the root directory
%
%   Copyright (c) 2014 Charles Deledalle

list = dir(path);
for k = 1:length(list)
    if ~strcmp(list(k).name(1), '.') && list(k).isdir
        addpath([path '/' list(k).name]);
        addpathrec([path '/' list(k).name]);
    end
end
