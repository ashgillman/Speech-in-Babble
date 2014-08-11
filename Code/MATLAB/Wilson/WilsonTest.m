%% Init
clear all;

% Test parameters
Fs = 16000;
nf = 513;
nb = 80;
nsLvl = 0.5;
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
NMFLIB_LOC = '/Users/Ash/Dropbox/Uni/2014/Thesis/Code/MATLAB/nmflib';
if isempty(strfind(path,NMFLIB_LOC))
    path(NMFLIB_LOC,path)
end

%% Data retrieval and training
trainWav = cell(size(SPKRS));
spkrData = cell(size(SPKRS));
X_train = cell(size(SPKRS));
V_train = cell(size(SPKRS));
W_train = cell(size(SPKRS));
testWav = cell(size(SPKRS));
X_test = cell(size(SPKRS));
V_test = cell(size(SPKRS));
W_test = cell(size(SPKRS));
figure()
set(gca, 'LooseInset', get(gca,'TightInset'))
for spkrI = 1:numel(SPKRS)
    % Training data
    speaker = SPKRS{spkrI};
    wav = trainWav{spkrI};
    spkrData{spkrI} = getfromifo( ...
        sprintf('%s%s/%sa0100.ifo',ROOT_LOC,speaker,speaker));
    age = spkrData{spkrI}.Talker_Age;
    sex = spkrData{spkrI}.Talker_Sex(1); % f or m
    fprintf(    ['Training on speaker %3s (%2s %1s):' ...
        blanks(numel(ROOT_LOC)-10) '| start |  end  |\n'],speaker,age,sex)
    for recIndex = 1:8 % first 8 for training
        recNum = REC_VALS(recIndex);
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
    frameN = (nf-1)*2; % frame length (no. samples)
    win = hamming(frameN,'periodic');
    trainSTFT = rfft(enframe(wav,win,nf-1),frameN,2); % 50% overlap
    X_train{spkrI} = abs(trainSTFT)';
    subplot(numel(SPKRS),2,2*spkrI-1);
    surf(log10(X_train{spkrI}),'EdgeColor','none');
    axis xy; axis tight; view(0,90);
    title(sprintf('%s: X \rightarrow Input Signal',speaker));

    rev = overlapadd(irfft(trainSTFT,frameN,2),win,nf-1);
    %soundsc(rev,Fs)

    % Training
    [V,W] = nnmf(X_train{spkrI},nb);
    V_train{spkrI} = V; W_train{spkrI} = W;
    subplot(numel(SPKRS),2,2*spkrI);
    surf(log10(V*W),'EdgeColor','none');
    axis xy; axis tight; view(0,90);
    title(['V_{all} \times W_{all} \rightarrow Approximation by ' ...
        'factorisation']);

    %recovered = overlapadd(irfft((V*W)',frameN,2),win,nf-1);
    %soundsc(recovered,Fs)

    % Test Data
    recIndex = recIndex + 1;
    recNum = REC_VALS(recIndex);
    [rec,FsIn] = audioread(sprintf('%s%s/%sa010%s.wav',ROOT_LOC, ...
        speaker,speaker,recNum));
    testWav{spkrI} = resample(rec,FsIn,Fs);
end

speech = testWav{1}; noise = testWav{2};
Vspeech = V_train{1}; Vnoise = V_train{2};
Wspeech = W_train{1}; Wnoise = W_train{2};

% get speech and noise same length
if numel(speech) > numel(noise)
    noise = [noise;zeros(numel(speech)-numel(noise),1)];
else
    speech = [speech;zeros(numel(noise)-numel(speech),1)];
end

%% Statistics
mu_speech = mean(log(Wspeech),2); mu_noise = mean(log(Wnoise),2);
mu_all = [mu_speech;mu_noise];
Lambda_speech = cov(log(Wspeech)'); Lambda_noise = cov(log(Wnoise)');
%Lambda_all = [Lambda_speech 0;0 Lambda_noise];

%% Mix
mixed = speech + nsLvl*noise;
%soundsc(mixed,Fs)

frameN = (nf-1)*2; % frame length (no. samples)
win = hamming(frameN,'periodic');
sigSTFT = rfft(enframe(mixed,win,nf-1),frameN,2); % 50% overlap
X_sig = abs(sigSTFT)';

%% Denoise
Vall = [Vspeech Vnoise];
[ignore,Wall_est] = nmf_kl(X_sig,2*nb,'W',Vall);
XspeechEst = Vspeech*Wall_est(1:nb,:);
recovered = overlapadd(irfft((XspeechEst)',frameN,2),win,nf-1);
soundsc(recovered,Fs);

before = 'before.wav';
after = 'after.wav';
audiowrite(before,mixed,Fs)
audiowrite(after,recovered,Fs)

[pesq_mos] = pesq(Fs,after,before)
    