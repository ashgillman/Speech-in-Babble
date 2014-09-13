close all
clear all

testID = '6';

% Include Libraries
PESQ_LOC = '/Users/Ash/Dropbox/Uni/2014/Thesis/Code/MATLAB/pesq';
if isempty(strfind(path,PESQ_LOC))
    path(PESQ_LOC,path)
end
MYTOOLS_LOC = '/Users/Ash/Dropbox/Uni/2014/Thesis/Code/MATLAB/mytools';
if isempty(strfind(path,MYTOOLS_LOC))
    path(MYTOOLS_LOC,path)
end

% tools for the program
subindex = @(A,i) A(i); % An anonymous function to index a matrix
subcindex = @(A,i) A{i}; % An anonymous function to index a cell

% suppress warnings thrown by pesq lib
warning('off','MATLAB:oldPfileVersion')

% const params
%DAT_LOC = ['/Volumes/Gillman 1/Thesis/testdat/' testID '/'];
DAT_LOC = ['/users/ash/documents/thesisdata/testdat/' testID '/'];
ENH_LOC = [DAT_LOC 'enhanced/'];
FS = 16000;

% test params
mixes = [-6 -3 0 3 6]; % dB

% load non-varying data (clean/dirty test data)
clean = [DAT_LOC 'test_clean.wav'];
cleanWav = wavread(clean);

% calculate pre-enhanced improvements
pesqDirty = zeros(size(mixes));
segSNRDirty = zeros(size(mixes));
for mixNo = 1:numel(mixes)
    mix = mixes(mixNo);
    
    % PESQ before enhancement
    dirty = [DAT_LOC 'test_dirty'  num2str(mix) 'dB.wav'];
    pesqDirty(mixNo) = pesq(FS,clean,dirty);
    
    % SegSNR Before Enhancement
    dirtyWav = wavread(dirty);
    len = min(numel(cleanWav),numel(dirtyWav));
    [snr_dist, segsnr_dist]= snr(cleanWav(1:len),dirtyWav(1:len),FS);
    segSNRDirty(mixNo) = mean(segsnr_dist);
end

% Get cleaned wav files (exclude hidden files)
fileList = getAllFiles(ENH_LOC,'*.wav');
hiddenFiles = ~cellfun(@isempty, regexp(fileList, '/\.'));
fileList = fileList(~hiddenFiles);

% Calculations for each enhanced file
pesqAft = zeros(size(fileList));
pesqBef = zeros(size(fileList));
segSNRAft = zeros(size(fileList));
segSNRBef = zeros(size(fileList));
inputSNR = zeros(size(fileList));
alg = cell(size(fileList));
utterances = zeros(size(fileList));
for i = 1:numel(fileList)
    file = fileList{i};
    
    % Get test info from filename
    path = strsplit(subcindex(strsplit(file,'_'),1),'/');
    alg(i) = path(end);
    utterances(i) = str2num(subindex(subcindex(strsplit(file,'_'),2),1:3));
    inputSNR(i) = str2num(subindex(subcindex(strsplit(file,'_'),2),6:7));

    % PESQ
    pesqAft(i) = pesq(FS,clean,file);
    pesqBef(i) = pesqDirty(mixes==inputSNR(i));

    % SegSNR
    fileWav = wavread(file);
    len = min(numel(cleanWav),numel(fileWav));
    [snr_dist, segsnr_dist]= snr(cleanWav(1:len),fileWav(1:len),FS);
    segSNRAft(i)= mean(segsnr_dist);
    segSNRBef(i) = segSNRDirty(mixes==inputSNR(i));
end

pesqImp = pesqAft - pesqBef;
SegSNRImp = segSNRAft - segSNRBef;
warning('on','MATLAB:oldPfileVersion')

% get extra test data
%meta = loadjson([DAT_LOC 'testmeta.json']);

% save to csv
names = cellfun(@(x) subindex(strsplit(x,'/'), ...
    length(strsplit(fileList{1},'/'))), fileList);
dat = cat(1,{'algorithm' 'filename' 'Input SNR' 'utterances' ...
    'pesq' 'pesqImp' 'segSNR' 'segSNRImp'}, ...
    cat(2, alg, names, num2cell(inputSNR), num2cell(utterances), ...
    num2cell(pesqAft), ...
    num2cell(pesqImp), num2cell(segSNRAft), num2cell(SegSNRImp)));
%# write line-by-line
if ~exist([DAT_LOC 'resultsd.csv'],'file')
    fid = fopen([DAT_LOC 'results.csv'],'w+');
    fprintf(fid, '%s,%s,%s,%s,%s,%s,%s,%s\n', dat{1,:});
else
    fid = fopen([DAT_LOC 'results.csv'],'a');
end
for i=2:size(dat,1)
    fprintf(fid, '%s,%s,%i,%i,%f,%f,%f,%f\n', dat{i,:});
end
fclose(fid);