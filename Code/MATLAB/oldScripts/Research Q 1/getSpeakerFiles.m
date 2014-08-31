function [phnFiles,wavFiles] = getSpeakerFiles(directory,speakerName)
% GETSPEAKERFILES get a file list of phn and wav files for a speaker.
%   directory is the directory speaker folders are located in.
%   speakerName is the id names of the speaker
%   phnFiles and wavFiles are arrays of directory structures.
if nargin < 2
    speakerName = [];
end 
phnFiles = dir([directory speakerName '/*.phn']);
wavFiles = dir([directory speakerName '/*.wav']);