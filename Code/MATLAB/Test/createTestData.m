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

% import libraries
MYTOOLS_LOC = '/Users/Ash/Dropbox/Uni/2014/Thesis/Code/MATLAB/mytools';
if isempty(strfind(path,MYTOOLS_LOC))
    path(MYTOOLS_LOC,path)
end

% suppress warnings thrown by existing dirs lib
warning('off','MATLAB:MKDIR:DirectoryExists')

ROOT_LOC = '/users/ash/documents/thesisdata/wsjcam0/rawdat/si_dt/';
%OUT_LOC = ['/Volumes/Gillman 1/Thesis/testdat/' testID '/'];
OUT_LOC = ['/users/ash/documents/thesisdata/testdat/' testID '/'];
FS = 16000;

%%% TEST PARAMS - Uncomment ONE of the following:

%testID = '1';
%SPKR = 'c3c'; % SoI ID used in this test
%COMPSPKR = 'c3f'; % ComSpkr ID(s) used in this test
%testLen = 10; % 10 samples for testing
%trainLens = [1 3 5 10 15 20 30 40 50 60 70 80];
%mixes = [-6 -3 0 3 6]; % dB
%seed1 = 2; seed2 = 5;

%testID = '2';
%SPKR = 'c3l'; % SoI ID used in this test
%COMPSPKR = 'c31'; % ComSpkr ID(s) used in this test
%testLen = 10; % 10 samples for testing
%trainLens = [1 3 5 10 15 20 30 40 50 60 70 80];
%mixes = [-6 -3 0 3 6]; % dB
%seed1 = 1; seed2 = 5;

%testID = '3';
%SPKR = 'c3s'; % SoI ID used in this test
%COMPSPKR = 'c31'; % ComSpkr ID(s) used in this test
%testLen = 10; % 10 samples for testing
%trainLens = [1 10 50 80];
%mixes = [-6 -3 0 3 6]; % dB
%seed1 = 1; seed2 = 2;

testID = '4';
SPKR = 'c3s'; % SoI ID used in this test
COMPSPKRS = {'c31' 'c34' 'c35'}; % ComSpkr ID(s) used in this test
testLen = 10; % 10 samples for testing
trainLens = [1 10 50 80];
mixes = [-6 -3 0 3 6]; % dB
seed1 = 1; seed2 = 2;

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
test_noiseWav = generateBabble(CompSpkrWavs,dirtyLen);

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
for i=1:numel(mixes)
    mix = mixes(i);
    test_dirtyWav = 10^(mix/20) * test_cleanWav + test_noiseWav;
    test_dirtyWav = 0.9 * normalise(test_dirtyWav);
    wavwrite(test_dirtyWav,FS,[OUT_LOC 'test_dirty' num2str(mix) ...
        'dB.wav']);
    disp([OUT_LOC 'test_dirty' num2str(mix) 'dB.wav']);
end

% training data
for i=1:numel(trainLens)
    trainLen = trainLens(i);
    
    % preallocate train wavs
    SoILen = sum(cellfun(@numel,SoIWavs((1:trainLen) + testLen)));
    compSpkrLen = sum(cellfun(@numel,CompSpkrWavs((1:trainLen) + testLen)));
    train_SoIWav = zeros(SoILen,1);
    train_comSpkrWav = zeros(compSpkrLen,1);
    
    % generate train data
    sPos = 1; % current position of SoI wav
    cPos = 1; % current position of compSpkr wav
    for j=(1:trainLen) + testLen
        newSPos = sPos + numel(SoIWavs{j}) - 1;
        newCPos = cPos + numel(CompSpkrWavs{j}) - 1;
        train_SoIWav(sPos:newSPos) = SoIWavs{j};
        train_comSpkrWav(cPos:newCPos) = CompSpkrWavs{j};
        sPos = newSPos + 1;
        cPos = newCPos + 1;
    end
    
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
% unsuppress warnings
warning('on','MATLAB:MKDIR:DirectoryExists')
end

function wav = generateBabble(inwavs,len)
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
    endpos = pos + numel(inwavs{i,curSpkr}) - 1;
    if endpos <= len
        wav(pos:endpos) = wav(pos:endpos) + inwavs{i,curSpkr};
    else
        wav(pos:end) = wav(pos:end) + inwavs{i,curSpkr}(endpos-len);
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