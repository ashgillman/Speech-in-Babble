function createTestData()
% Generates sound files for testing.
% Generates a range of training data, varying by the number of utterances
% (sentences) provided to train on.
% Generates a range of test data, varying by the SNR.
%
% Will output files:
%   - <x>ut/train_SoI.wav, where x is the number of utterances
%   - <x>ut/train_compSpkr.wav, where x is the number of utterances
%   - test_clean.wav
%   - test_noise.wav
%   - test_dirty<x>dB.wav, where x is the SNR

%%% TEST PARAMS - Uncomment ONE of the following:
%testID = '1';
%SPKR = 'c3c'; % SoI ID used in this test
%COMPSPKR = {'c3f'}; % ComSpkr ID(s) used in this test
%testLen = 10; % 10 samples for testing
%trainLens = [1 3 5 10 15 20 30 40 50 60 70 80];
%mixes = [-6 -3 0 3 6]; % dB
%seed1 = 2; seed2 = 5;

%testID = '2';
%SPKR = 'c3l'; % SoI ID used in this test
%COMPSPKR = {'c31'}; % ComSpkr ID(s) used in this test
%testLen = 10; % 10 samples for testing
%trainLens = [1 3 5 10 15 20 30 40 50 60 70 80];
%mixes = [-6 -3 0 3 6]; % dB
%seed1 = 1; seed2 = 5;

%testID = '3';
%SPKR = 'c3s'; % SoI ID used in this test
%COMPSPKR = {'c31'}; % ComSpkr ID(s) used in this test
%testLen = 10; % 10 samples for testing
%trainLens = [1 10 50 80];
%mixes = [-6 -3 0 3 6]; % dB
%seed1 = 1; seed2 = 2;

%testID = '4';
%SPKR = 'c3s'; % SoI ID used in this test
%COMPSPKRS = {'c31' 'c34' 'c35'}; % ComSpkr ID(s) used in this test
%testLen = 10; % 10 samples for testing
%trainLens = [1 10 50 80];
%mixes = [-6 -3 0 3 6]; % dB
%seed1 = 1; seed2 = 2;

%testID = '5';
%SPKR = 'c3s'; % SoI ID used in this test
%COMPSPKRS = {'c3c' 'c3f' 'c35'}; % ComSpkr ID(s) used in this test
%testLen = 10; % 10 samples for testing
%trainLens = [1 5 10 50 80];
%mixes = [-6 -3 0 3 6]; % dB
%seed1 = 1; seed2 = 2;

%testID = '6';
%SPKR = 'c3s'; % SoI ID used in this test
%COMPSPKRS = {'c3c' 'c3f'}; % ComSpkr ID(s) used in this test
%testLen = 10; % 10 samples for testing
%trainLens = [1 5 10 50 80];
%mixes = [-6 -3 0 3 6]; % dB
%seed1 = 1; seed2 = 2;

testID = '7';
SPKR = 'c3s'; % SoI ID used in this test
COMPSPKRS = {'c3f'}; % ComSpkr ID(s) used in this test
testLen = 10; % 10 samples for testing
trainLens = [1 5 10 50 80];
mixes = [-6 -3 0 3 6]; % dB
phnSampleCounts = [1 5 10 50 100 500 999];
seed1 = 2; seed2 = 1;

% import libraries
MYTOOLS_LOC='/Users/Ash/Dropbox/Uni/2014/Thesis/Code/MATLAB/mytools';
if isempty(strfind(path,MYTOOLS_LOC))
    path(MYTOOLS_LOC,path)
end
VOICEBOX_LOC='/Users/Ash/Dropbox/Uni/2014/Thesis/Code/MATLAB/voicebox';
if isempty(strfind(path,VOICEBOX_LOC))
    path(VOICEBOX_LOC,path)
end
PHN_LOC='/Users/Ash/Dropbox/Uni/2014/Thesis/Code/MATLAB/phonemeDependent';
if isempty(strfind(path,PHN_LOC))
    path(PHN_LOC,path)
end
ALL_PHNS = {'p' 't' 'k' 'pcl' 'tcl' 'kcl' 'dx' 'm' 'n' 'ng' 'nx' 's'...
    'z' 'ch' 'th' 'f' 'l' 'r' 'y' 'pau' 'hh' 'eh' 'ao' 'aa' 'uw' 'er'...
    'ay' 'ey' 'aw' 'ax' 'ix' 'b' 'd' 'g' 'bcl' 'dcl' 'gcl' 'q' 'em' 'en'...
    'eng' 'sh' 'zh' 'jh' 'dh' 'v' 'el' 'w' 'h#' 'epi' 'hv' 'ih' 'ae'...
    'ah' 'uh' 'ux' 'oy' 'iy' 'ow' 'axr' 'ax-h' ...
    'oh' 'ia' 'ea' 'ua'}; % ignore sil

% suppress warnings thrown by existing dirs lib
warning('off','MATLAB:MKDIR:DirectoryExists')

ROOT_LOC = '/users/ash/documents/thesisdata/wsjcam0/rawdat/si_dt/';
%OUT_LOC = ['/Volumes/Gillman 1/Thesis/testdat/' testID '/'];
OUT_LOC = ['/users/ash/documents/thesisdata/testdat/' testID '/'];
FS = 16000;
alen=512; % analysis length, used for phoneme length drawn

% load Soi Files
files = getAllFiles([ROOT_LOC SPKR], '/*.wav');
emptyWavs = ~cellfun(@isempty, regexp(files, '101.wav'));
files = files(~emptyWavs);
fprintf('%s: Found %i files, using %i... ',SPKR,length(files), ...
    max(trainLens) + testLen);
rng(seed1); % set seed and shuffle
SoIWavFiles = files(randperm(length(files),max(trainLens) + testLen));
[SoIWavs,fs] = cellfun(@wavread,SoIWavFiles,'UniformOutput',false);
fprintf('Loaded %f minutes of wav data.\n',...
    sum(cellfun(@numel,SoIWavs)./cell2mat(fs))/60);

% Load ComSpkr files
rng(seed2); % set seed
CompSpkrWavFiles = cell(max(trainLens) + testLen,numel(COMPSPKRS));
CompSpkrWavs = cell(max(trainLens) + testLen,numel(COMPSPKRS));
for spkNo = 1:numel(COMPSPKRS)
    COMPSPKR = COMPSPKRS{spkNo};
    files = getAllFiles([ROOT_LOC COMPSPKR], '/*.wav');
    emptyWavs = ~cellfun(@isempty, regexp(files, '101.wav'));
    files = files(~emptyWavs);
    fprintf('%s: Found %i files, using %i... ',COMPSPKR,length(files), ...
        max(trainLens) + testLen);
    CompSpkrWavFiles(:,spkNo) = files(randperm(length(files), ...
        max(trainLens) + testLen)); %  shuffle
    [CompSpkrWavs(:,spkNo),fs] = cellfun(@wavread,CompSpkrWavFiles(:,spkNo), ...
        'UniformOutput',false);
    fprintf('Loaded %f minutes of wav data.\n',...
        sum(cellfun(@numel,CompSpkrWavs(:,spkNo))./cell2mat(fs))/60);
end

% preallocate test wavs
cleanLen = sum(cellfun(@numel,SoIWavs(1:testLen)));
noiseLen = min(sum(cellfun(@numel,CompSpkrWavs(1:testLen,:))));
dirtyLen = min(cleanLen,noiseLen);
test_cleanWav = zeros(dirtyLen,1);
test_noiseWav = generateBabble(CompSpkrWavs,dirtyLen,fs{1});

% generate test data
cPos = 1; % current position of clean wav
for i=1:testLen
    newCPos = cPos + numel(SoIWavs{i}) - 1;
    if newCPos <= dirtyLen
        test_cleanWav(cPos:newCPos) = SoIWavs{i};
    else
        test_cleanWav(cPos:end) = SoIWavs{i}(newCPos-dirtyLen);
    end
    cPos = newCPos + 1;
end

% normalise signals
test_cleanWav = 0.9 * normalise(test_cleanWav);
test_noiseWav = 0.9 * normalise(test_noiseWav);

% save test wavs
mkdir(OUT_LOC);
wavwrite(test_cleanWav,FS,[OUT_LOC 'test_clean.wav']);
disp([OUT_LOC 'test_clean.wav']);
wavwrite(test_noiseWav,FS,[OUT_LOC 'test_noise.wav']);
disp([OUT_LOC 'test_noise.wav']);

% save each mix
test_cleanWav = test_cleanWav / activlev(test_cleanWav,fs{1});
test_noiseWav = test_noiseWav / activlev(test_noiseWav,fs{1});
for i=1:numel(mixes)
    mix = mixes(i);
    test_dirtyWav = 10^(mix/20) * test_cleanWav + test_noiseWav;
    test_dirtyWav = 0.9 * normalise(test_dirtyWav);
    wavwrite(test_dirtyWav,FS,[OUT_LOC 'test_dirty' num2str(mix) ...
        'dB.wav']);
    disp([OUT_LOC 'test_dirty' num2str(mix) 'dB.wav']);
end

% normal training data
for i=1:numel(trainLens)
    trainLen = trainLens(i);
    
    % preallocate train wavs
    SoILen = sum(cellfun(@numel,SoIWavs((1:trainLen) + testLen)));
    train_SoIWav = zeros(SoILen,1);
    
    % generate SoI train data
    sPos = 1; % current position of SoI wav
    for j=(1:trainLen) + testLen
        newSPos = sPos + numel(SoIWavs{j}) - 1;
        train_SoIWav(sPos:newSPos) = SoIWavs{j};
        sPos = newSPos + 1;
    end
    train_comSpkrWav = generateBabble(CompSpkrWavs,SoILen,fs{1});
    
    % normalise signals
    train_SoIWav = 0.9 * normalise(train_SoIWav);
    train_comSpkrWav = 0.9 * normalise(train_comSpkrWav);

    % save train wavs
    mkdir([OUT_LOC num2str(trainLen) 'ut']);
    wavwrite(train_SoIWav,FS,[OUT_LOC num2str(trainLen) 'ut/' ...
        'train_SoI.wav']);
    disp([OUT_LOC num2str(trainLen) 'ut/' 'train_SoI.wav']);
    wavwrite(train_comSpkrWav,FS,[OUT_LOC num2str(trainLen) 'ut/' ...
        'train_compSpkr.wav']);
    disp([OUT_LOC num2str(trainLen) 'ut/' 'train_compSpkr.wav']);
end

% generate phoneme training data
for phnSampleCount=phnSampleCounts
    % draw phones
    phonemeSamples = drawPhnSamples([ROOT_LOC SPKR '/'],...
        alen/FS,phnSampleCount,ALL_PHNS);
    numSamplesByPhn = cellfun(@(x) size(x,2),phonemeSamples);
    
    % concatenate wav
    wav = zeros(alen*sum(numSamplesByPhn),1);
    loc = 1;
    for a = 1:numel(phonemeSamples)
        for b = 1:numel(phonemeSamples{a})
            len = numel(phonemeSamples{a}{b});
            wav(loc:loc+len-1) = phonemeSamples{a}{b};
            loc=loc+len;
        end
    end
    
    % plot for user reference
    Vspeaker = constructVMatrix(phonemeSamples,ceil(alen));
    numSamples = cellfun(@(x) size(x,2),phonemeSamples);
    presentPhonemes = ALL_PHNS(numSamples~=0);
    for i=1:numel(presentPhonemes)
        presentPhonemes{i} = sprintf('/%s/', presentPhonemes{i});
    end
    presentPhonemes{end+1} = '';
    p = 10*log10(abs(Vspeaker(1:ceil(alen)/2,:)));
    p(p<-30)=-30;
    figure(); surf(p,'EdgeColor','none'); 
    axis xy; axis tight; colormap(jet); view(0,90);
    set(gca,'XTick',[unique(cumsum(numSamples))],...
        'XTickLabel',presentPhonemes)
    title([num2str(phnSampleCount) ' samples per phone']);
    xlabel('components');
    ylabel('Frequency Bin');
    
    % save
    saveFile = [OUT_LOC num2str(phnSampleCount) 'phntrain_SoI.wav'];
    wavwrite(wav,FS,saveFile);
    disp(saveFile);
end

% unsuppress warnings
warning('on','MATLAB:MKDIR:DirectoryExists')
end

function wav = generateBabble(inwavs,len,fs)
% Generates babble from a give cell of speakers each of which is cell of
% wavs.
% i.e. inwav:{spkr1:{rec1:[],rec2:[]},spkr2:{rec1:[],rec2:[]}}

noSpkr = size(inwavs,2);
avgLen = mean(mean(cellfun(@numel,inwavs)));
step = round(avgLen / noSpkr);
wav = zeros(len,1);

curSpkr = 1; % to alternate which speaker
pos=1; % index in wav file
i=1; % rec no
while pos < len && i <= size(inwavs,1)
    speech = inwavs{i,curSpkr}; % new speech to add
    endpos = pos + length(speech) - 1;
    al = activlev(speech,fs); % power level
    speech = speech / al; % normalise on power
    if endpos <= len
        wav(pos:endpos) = wav(pos:endpos) + speech;
        %wav(pos:endpos) = v_addnoise(wav(pos:endpos),fs,0,'', ...
        %    inwavs{i,curSpkr},fs);
    else
        wav(pos:end) = wav(pos:end) + speech(endpos-len);
        %wav(pos:end) = v_addnoise(wav(pos:end),fs,0,'', ...
        %    inwavs{i,curSpkr}(endpos-len),fs);
    end
    if curSpkr == noSpkr
        i = i+1; % incr recording after used all speakers
    end
    curSpkr = mod(curSpkr+1,noSpkr) + 1; % step through speakers
    pos = pos + step;
end
end

function fileList = getAllFiles(dirName, type)
% Get the contents of the given directory that are of the given type.

dirData = dir([dirName type]); % Get the data for the current directory
dirIndex = [dirData.isdir];  %# Find the index for directories
fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files
if ~isempty(fileList)
fileList = cellfun(@(x) fullfile(dirName,x),...  Prepend path to files
                   fileList,'UniformOutput',false);
end
end