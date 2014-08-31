% Generates sound files for testing.
% Will output 4 files:
%   - SoI_train.wav
%   - CompSpkr_train.wav
%   - test_clean.wav
%   - test_dirty.wav

function createTestData()
clear all

ROOT_LOC = '/users/ash/documents/thesisdata/wsjcam0/rawdat/si_dt/';
OUT_LOC = '/Volumes/Gillman/Thesis/testdat/1/';

SPKR = 'c3c'; % SoI ID used in this test
COMPSPKR = {'c3f'}; % ComSpkr ID(s) used in this test

testLen = 10; % 10 samples for testing
trainLens = [1 3 5 10 15 20 30 40 50 60 70 80 90];

wavs = regexp('$.wav',dir([ROOT_LOC SPKR]))

for i=1:numel(trainLens)
    trainLen = trainLens(i);
end
end

function fileList = getAllFiles(dirName)

  dirData = dir(dirName);      %# Get the data for the current directory
  dirIndex = [dirData.isdir];  %# Find the index for directories
  fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files
  if ~isempty(fileList)
    fileList = cellfun(@(x) fullfile(dirName,x),...  %# Prepend path to files
                       fileList,'UniformOutput',false);
  end
end