% Generates sound files for testing.
% Will output files:
%   - train_SoI.wav
%   - train_compSpkr.wav
%   - test_clean.wav
%   - test_noise.wav
%   - test_dirty.wav

function createTestData()
MYTOOLS_LOC = '/Users/Ash/Dropbox/Uni/2014/Thesis/Code/MATLAB/mytools';
if isempty(strfind(path,MYTOOLS_LOC))
    path(MYTOOLS_LOC,path)
end

ROOT_LOC = '/users/ash/documents/thesisdata/wsjcam0/rawdat/si_dt/';
OUT_LOC = '/Volumes/Gillman/Thesis/testdat/1/';
FS = 16000;

SPKR = 'c3c'; % SoI ID used in this test
COMPSPKR = 'c3f'; % ComSpkr ID(s) used in this test

testLen = 10; % 10 samples for testing
trainLens = [1 3 5 10 15 20 30 40 50 60 70 80];

SoIWavFiles = getAllFiles([ROOT_LOC SPKR], '/*.wav');
emptyWavs = ~cellfun(@isempty, regexp(SoIWavFiles, '101.wav'));
SoIWavFiles = SoIWavFiles(~emptyWavs);
[SoIWavs,fs] = cellfun(@wavread,SoIWavFiles,'UniformOutput',false);
fprintf('Loaded %f minutes of wav data.\n',...
    sum(cellfun(@numel,SoIWavs)./cell2mat(fs))/60);

ComSpkrWavFiles = getAllFiles([ROOT_LOC COMPSPKR], '/*.wav');
emptyWavs = ~cellfun(@isempty, regexp(ComSpkrWavFiles, '101.wav'));
ComSpkrWavFiles = ComSpkrWavFiles(~emptyWavs);
[CompSpkrWavs,fs] = cellfun(@wavread,ComSpkrWavFiles,'UniformOutput',false);
fprintf('Loaded %f minutes of wav data.\n',...
    sum(cellfun(@numel,CompSpkrWavs)./cell2mat(fs))/60);

% preallocate test wavs
cleanLen = sum(cellfun(@numel,SoIWavs(1:testLen)));
noiseLen = sum(cellfun(@numel,CompSpkrWavs(1:testLen)));
dirtyLen = min(cleanLen,noiseLen);
test_cleanWav = zeros(dirtyLen,1);
test_noiseWav = zeros(dirtyLen,1);

% generate test data
cPos = 1; % current position of clean wav
dPos = 1; % current position of dirty wav
for i=1:testLen
    newCPos = cPos + numel(SoIWavs{i}) - 1;
    newDPos = dPos + numel(CompSpkrWavs{i}) - 1;
    if newCPos <= dirtyLen
        test_cleanWav(cPos:newCPos) = SoIWavs{i};
    else
        test_cleanWav(cPos:end) = SoIWavs{i}(newCPos-dirtyLen);
    end
    if newDPos <= dirtyLen
        test_noiseWav(dPos:newDPos) = CompSpkrWavs{i};
    else
        test_noiseWav(dPos:end) = CompSpkrWavs{i}(newDPos-dirtyLen);
    end
    cPos = newCPos + 1;
    dPos = newDPos + 1;
end
test_dirtyWav = test_cleanWav + test_noiseWav;

% normalise signals
test_cleanWav = normalise(test_cleanWav);
test_noiseWav = normalise(test_noiseWav);
test_dirtyWav = normalise(test_dirtyWav);

% save test wavs
mkdir(OUT_LOC);
wavwrite(test_cleanWav,FS,[OUT_LOC 'test_clean.wav']);
wavwrite(test_noiseWav,FS,[OUT_LOC 'test_noise.wav']);
wavwrite(test_dirtyWav,FS,[OUT_LOC 'test_dirty.wav']);

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
    train_SoIWav = normalise(train_SoIWav);
    train_comSpkrWav = normalise(train_comSpkrWav);

    % save train wavs
    mkdir([OUT_LOC '/' num2str(trainLen)]);
    wavwrite(train_SoIWav,FS,[OUT_LOC '/' num2str(trainLen) '/' ...
        'train_SoI.wav']);
    wavwrite(train_comSpkrWav,FS,[OUT_LOC '/' num2str(trainLen) '/' ...
        'train_compSpkr.wav']);
end
end

function fileList = getAllFiles(dirName, type)

  dirData = dir([dirName type]);      %# Get the data for the current directory
  dirIndex = [dirData.isdir];  %# Find the index for directories
  fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files
  if ~isempty(fileList)
    fileList = cellfun(@(x) fullfile(dirName,x),...  %# Prepend path to files
                       fileList,'UniformOutput',false);
  end
end