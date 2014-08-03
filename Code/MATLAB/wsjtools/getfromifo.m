function [val] = getfromifo(ifofile,key)
% [val] = getfromifo(ifofile,key) - Gets a property from the speaker's ifo
% file.
%   ifofile - path to the speaker's ifofile
%   key     - the property name to retrieve (as listed in the file)
%   val     - the value of the property returned
C = fileread(ifofile);
keyi = strfind(C, key);
deli = strfind(C(keyi(1):end),':');
val = strsplit(C(keyi(1)+deli(1):end));
val = val{2};