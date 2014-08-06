%% Init
clear all;

Fs = 16000;
nf = 513;
nb = 80;
TEST_ID = 'alphatesting';
SPKRS = {'c3c','c3f'}; % Speaker IDs used in this test
REC_VALS = ['2':'9' 'a':'z']; % 34 recordings. Ignore '1', it's silence
ROOT_LOC = '/users/ash/documents/thesisdata/wsjcam0/rawdat/si_dt/';

% Include Libraries
VOICEBOX_LOC = '/Users/Ash/Dropbox/Uni/2014/Thesis/Code/MATLAB/voicebox';
if isempty(strfind(path,VOICEBOX_LOC))
    path(VOICEBOX_LOC,path)
end
WSJTOOLS_LOC = '/Users/Ash/Dropbox/Uni/2014/Thesis/Code/MATLAB/wsjtools';
if isempty(strfind(path,WSJTOOLS_LOC))
    path(WSJTOOLS_LOC,path)
end
PESQ_LOC = '/Users/Ash/Dropbox/Uni/2014/Thesis/Code/MATLAB/pesq';
if isempty(strfind(path,PESQ_LOC))
    path(PESQ_LOC,path)
end

%% Training
% Form SoI training data
trainWav = cell(size(SPKRS));
spkrData = cell(size(SPKRS));
X_spkr = cell(size(SPKRS));
V_spkr = cell(size(SPKRS));
W_spkr = cell(size(SPKRS));
figure()
set(gca, 'LooseInset', get(gca,'TightInset'))
for spkrI = 1:numel(SPKRS)
    speaker = SPKRS{spkrI};
    wav = trainWav{spkrI};
    spkrData{spkrI} = getfromifo( ...
        sprintf('%s%s/%sa0100.ifo',ROOT_LOC,speaker,speaker));
    age = spkrData{spkrI}.Talker_Age;
    sex = spkrData{spkrI}.Talker_Sex(1); % f or m
    fprintf(    ['Training on speaker %3s (%2s %1s):' ...
        blanks(numel(ROOT_LOC)-10) '| start |  end  |\n'],speaker,age,sex)
    for recIndex1 = 1:8 % first 8 for training
        recNum = REC_VALS(recIndex1);
        [rec,FsIn] = audioread(sprintf('%s%s/%sa010%s.wav',ROOT_LOC, ...
            speaker,speaker,recNum));
        rec = resample(rec,FsIn,Fs);
        fprintf('    %s%s/%sa010%s.wav |%7d|%7d|\n',ROOT_LOC, ...
            speaker,speaker,recNum,length(wav)+1, ...
            length(wav)+length(rec));
        wav = [wav;rec];
    end
    trainWav{spkrI} = wav;

    % STFT
    frameN = (nf-1)*2;
    win = hamming(frameN,'periodic');
    trainSTFT = rfft(enframe(wav,win,nf-1),frameN,2); % 50% overlap
    X_spkr{spkrI} = abs(trainSTFT)';
    subplot(numel(SPKRS),2,2*spkrI-1);
    surf(log10(X_spkr{spkrI}),'EdgeColor','none');
    axis xy; axis tight; view(0,90);
    title(sprintf('%s: X \rightarrow Input Signal',speaker));

    rev = overlapadd(irfft(trainSTFT,frameN,2),win,nf-1);
    %soundsc(rev,Fs)

    % Training
    [Vspeech,Wspeech] = nnmf(X_spkr{spkrI},nb);
    subplot(numel(SPKRS),2,2*spkrI);
    surf(log10(Vspeech*Wspeech),'EdgeColor','none');
    axis xy; axis tight; view(0,90);
    title('V_{all} \times W_{all} \rightarrow Approximation by factorisation');

    recovered = overlapadd(irfft((Vspeech*Wspeech)',frameN,2),win,nf-1);
    %soundsc(recovered,Fs)
end

%% Test Data
recIndex1 = recIndex1 + 1;
recNum = REC_VALS(recIndex1);
[rec,FsIn] = audioread(sprintf('%s%sa010%s.wav',SOI_LOC,speaker,recNum));
desired = resample(rec,FsIn,Fs);

recIndex1 = recIndex2 + 1;
recNum = REC_VALS(recIndex2);
[rec,FsIn] = audioread(sprintf('%s%sa010%s.wav',COMP_LOC,compspk,recNum));
noise = resample(rec,FsIn,Fs);

if numel(desired) > numel(noise)
    noise = [noise;zeros(numel(desired)-numel(noise),1)];
else
    desired = [desired;zeros(numel(noise)-numel(desired),1)];
end

mixed = desired + 0.1*noise;
soundsc(mixed,Fs)

%% Extract
%estimate = 

before = 'before.wav';
after = 'after.wav';
audiowrite(before,trainWav,Fs)
audiowrite(after,recovered,Fs)

[pesq_mos] = pesq(Fs,after,before)
    