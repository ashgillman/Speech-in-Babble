function [phones,startstops] = getPhnData(fname)
% GETPHNDATA get a file list of phn and wav files for a speaker.
%   directory is the directory speaker folders are located in.
%   speakerName is the id names of the speaker
%   phnFiles and wavFiles are arrays of directory structures.
currentRecPhnFID = fopen(fname);
phnData = textscan(currentRecPhnFID,'%u %u %s','delimiter','\t');
fclose(currentRecPhnFID);
phones = phnData{3};
startstops = [phnData{1}+1 phnData{2}+1];