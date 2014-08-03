Fs = 16000;
nf = 513;
nb = 80;
speaker = 'c3c';
recVals = ['2':'9' 'a':'z']; % 34 recordings. Ignore '1', it's silence
ROOT_LOC = '/users/ash/documents/thesisdata/wsjcam0/rawdat/si_dt/';
DATA_LOC = sprintf('%s%s/',DATA_LOC,speaker);

% Include Voicebox Library
VOICEBOX_LOC = '/Users/Ash/Dropbox/Uni/2014/Thesis/Code/MATLAB/voicebox';
if isempty(strfind(path,VOICEBOX_LOC))
    path(VOICEBOX_LOC,path)
end
WSJTOOLS_LOC = '/Users/Ash/Dropbox/Uni/2014/Thesis/Code/MATLAB/wsjtools';
if isempty(strfind(path,WSJTOOLS_LOC))
    path(WSJTOOLS_LOC,path)
end

% Form training data
trainingData = [];
age = getfromifo(sprintf('%s%sa0100.ifo',DATA_LOC,speaker),...
    'Talker Age');
sex = getfromifo(sprintf('%s%sa0100.ifo',DATA_LOC,speaker),...
    'Talker Sex');
sex = sex(1); % f or m
%f = fopen(
fprintf(    ['Training on speaker %3s (%2s %1s):              ' ...
        '                                      | start |  end  |\n'], ...
        speaker,age,sex)
for recIndex = 1:8 % first 8 for training
    recNum = recVals(recIndex);
    [rec,FsIn] = audioread([DATA_LOC '/' speaker 'a010' recNum ...
        '.wav']);
    rec = resample(rec,FsIn,Fs);
    fprintf(['             %s%sa010%s.wav |%7d|%7d|\n'],DATA_LOC, ...
        speaker,recNum,length(trainingData)+1, ...
        length(trainingData)+length(rec));
    trainingData = [trainingData;rec];
end

% Nicities
%soundsc(trainingData,Fs);
figure()
plot(trainingData);
figure()

% STFT
frameN = (nf-1)*2;
win = hamming(frameN,'periodic');
trainSTFT = rfft(enframe(trainingData,win,nf-1),frameN,2); % 50% overlap
X = abs(trainSTFT)';
surf(log10(X),'EdgeColor','none'); axis xy; axis tight; view(0,90);

rev = overlapadd(irfft(trainSTFT,frameN,2),win,nf-1);
%soundsc(rev,Fs)

% Training
[V,W] = nnmf(X,nb);
figure()
surf(log10(V*W),'EdgeColor','none'); axis xy; axis tight; view(0,90);

rev = overlapadd(irfft((V*W)',frameN,2),win,nf-1);
soundsc(rev,Fs)

    