close all
clear all

% params
DAT_LOC = '/Volumes/Gillman/Thesis/testdat/1/';
OUT_LOC = [DAT_LOC 'enhanced/'];
FS = 16000;
mkdir(OUT_LOC);

% read dirty to be cleaned
dirtyWav = wavread([DAT_LOC 'test_dirty.wav']);

% variation params
trainLens = [1 3 5 10 15 20 30 40 50 60 70 80];

% run through variations
for i=1:numel(trainLens)
    trainLen = trainLens(i);
    fprintf('testing for %i utterances\n',trainLen);
    
    fprintf('loading training data...  '); tic;
    SoIWav = wavread([DAT_LOC '/' num2str(trainLen) '/' ...
        'train_SoI.wav']);
    CompSpkrWav = wavread([DAT_LOC '/' num2str(trainLen) '/' ...
        'train_compSpkr.wav']);
    disp(toc)
    
    fprintf('extracting...  '); tic;
    MSenhWav = mohammadiaSupervised(SoIWav,CompSpkrWav,dirtyWav);
    wavwrite(MSenhWav,FS,[OUT_LOC num2str(trainLen) ...
        'mohammadiaSupervised.wav']);
    disp(toc)
end