close all
clear all

testID = '1';

% Include Libraries
PESQ_LOC = '/Users/Ash/Dropbox/Uni/2014/Thesis/Code/MATLAB/pesq';
if isempty(strfind(path,PESQ_LOC))
    path(PESQ_LOC,path)
end
MYTOOLS_LOC = '/Users/Ash/Dropbox/Uni/2014/Thesis/Code/MATLAB/mytools';
if isempty(strfind(path,MYTOOLS_LOC))
    path(MYTOOLS_LOC,path)
end

% suppress warnings thrown by pesq lib
warning('off','MATLAB:oldPfileVersion')

% params
DAT_LOC = ['/Volumes/Gillman/Thesis/testdat/' testID '/'];
ENH_LOC = [DAT_LOC 'enhanced/'];
FS = 16000;

% load non-varying data (clean/dirty test data)
clean = [DAT_LOC 'test_clean.wav'];
dirty = [DAT_LOC 'test_dirty.wav'];
pesqBef = pesq(FS,clean,dirty);
cleanWav = wavread(clean);
dirtyWav = wavread(dirty);
len = min(numel(cleanWav),numel(dirtyWav));
[snr_dist, segsnr_dist]= snr(cleanWav(1:len),dirtyWav(1:len),FS);
segSNRBef = mean(segsnr_dist);

% Get cleaned wav files (exclude hidden files)
fileList = getAllFiles(ENH_LOC,'*.wav');
hiddenFiles = ~cellfun(@isempty, regexp(fileList, '/\.'));
fileList = fileList(~hiddenFiles);

% Calculations for each file
pesqAft = zeros(size(fileList));
segSNRAft = zeros(size(fileList));
for i = 1:numel(fileList)
    file = fileList{i};
    
    % PESQ
    pesqAft(i) = pesq(FS,clean,file);
    
    % SegSNR
    fileWav = wavread(file);
    len = min(numel(cleanWav),numel(fileWav));
    [snr_dist, segsnr_dist]= snr(cleanWav(1:len),fileWav(1:len),FS);
    segSNRAft(i)= mean(segsnr_dist);
end
pesqImp = pesqAft - pesqBef;
SegSNRImp = segSNRAft - segSNRBef;
warning('on','MATLAB:oldPfileVersion')

% get extra test data
meta = loadjson([DAT_LOC 'testmeta.json']);

% save to csv
subindex = @(A,i) A(i); % An anonymous function to index a matrix
names = cellfun(@(x) subindex(strsplit(x,'/'), ...
    length(strsplit(fileList{1},'/'))), fileList);
dat = cat(1,{'cleanedname' 'Input SNR' 'No. in Babble' 'pesq' 'pesqImp' ...
    'segSNR' 'segSNRImp'}, ...
    cat(2, names, num2cell(repmat(meta.InputSNR,size(names))), ...
    num2cell(repmat(meta.NoInBabble,size(names))), num2cell(pesqAft), ...
    num2cell(pesqImp), num2cell(segSNRAft), num2cell(SegSNRImp)));
%# write line-by-line
if ~exist([DAT_LOC 'resultsd.csv'])
    fid = fopen([DAT_LOC 'results.csv'],'w+');
    fprintf(fid, '%s,%s,%s,%s,%s\n', dat{1,:});
else
    fid = fopen([DAT_LOC 'results.csv'],'a');
end
for i=2:size(dat,1)
    fprintf(fid, '%s,%f,%f,%f,%f\n', dat{i,:});
end
fclose(fid);