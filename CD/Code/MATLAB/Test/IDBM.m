function [enSpeech,stats] = IDBM(cleanTrain,noiseTrain,dirtyTest)
% Performs MMSE enhancement using Voicebox's ssubmmse
%
% Written by Ashley Gillman

alen=32;ulen=4;
fs=16000;%sampling frequency
LC = -5;

IDBM_LOC='/Users/Ash/Dropbox/Uni/2014/Thesis/Code/MATLAB/idbm';
if isempty(strfind(path,IDBM_LOC))
    path(IDBM_LOC,path)
end

train = cleanTrain/std(cleanTrain);
dirty = dirtyTest/std(dirtyTest);

if numel(dirty) > numel(train)
    train = [train;zeros(numel(dirty)-numel(train),1)];
elseif numel(train) > numel(dirty)
    train = train(1:numel(dirty));
end

tic;
enSpeech = idbm(dirty,train,fs,alen,ulen,LC);
enhTime = toc;

stats.speechTrainTime = 0;
stats.noiseTrainTime = 0;
stats.enhTime = enhTime;