function [data] = getfromifo(ifofile)
% [val] = getfromifo(ifofile,key) - Gets a property from the speaker's ifo
% file.
%   ifofile - path to the speaker's ifofile
%   key     - the property name to retrieve (as listed in the file)
%   val     - the value of the property returned
C = fileread(ifofile); % open file
keyVals = cellfun(@(x) strsplit(x,':'),...
    strsplit(C,'\n'),'UniformOutput',false); % pull text from file a split
wanted = cellfun(@(x) all(eq(x,[1 2])), ...
    cellfun(@size,keyVals,'UniformOutput',false)); % lines w/ key/value
keyVals = keyVals(wanted); % only wanted lines
keys = cellfun(@(x) ...
    regexprep(strrep(strtrim(x{1}),' ','_'),'[^a-zA-Z0-9_]',''), ...
    keyVals,'UniformOutput',false); % get keys, ignore invalid chars
vals = cellfun(@(x) strtrim(x{2}),keyVals,'UniformOutput',false); % vals
data = cell2struct(vals,keys,2); % key:vals into struct