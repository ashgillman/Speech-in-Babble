function [enSpeech,stats] = MMSE(cleanTrain,noiseTrain,dirtyTest)
% Performs MMSE enhancement using Voicebox's ssubmmse
%
% Written by Ashley Gillman

VOICEBOX_LOC='/Users/Ash/Dropbox/Uni/2014/Thesis/Code/MATLAB/voicebox';
if isempty(strfind(path,VOICEBOX_LOC))
    path(VOICEBOX_LOC,path)
end

mixed = dirtyTest/std(dirtyTest);

tic;
enSpeech = ssubmmse(mixed,16000);
enhTime = toc;

stats.speechTrainTime = 0;
stats.noiseTrainTime = 0;
stats.enhTime = enhTime;