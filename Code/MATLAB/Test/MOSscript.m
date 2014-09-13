% Prepares data for MOS evaluation, then runs the MOS function
%
% In each data location, "DAT_LOC", is a file 

clear all; close all;

%%% USER DEFINED - CHANGE THESE VARIABLES TO SUIT TEST

% Define test variation params (strings)
aName = 'testNo'; aVals = {'4'};
bName = 'Input.SNR'; bVals = {'-3' '00' '03'};
cName = 'algorithm'; cVals = {'mohammadiaSupervised' 'mohammadiaOnline'};
dName = 'utterances'; dVals = {'001' '010' '050' '080'};

% Set format such that this function will return the wav file to test
%enhanfile = @(a,b,c,d) sprintf( ...
%    '/Volumes/Gillman 1/Thesis/testdat/%s/enhanced/%s_%sut%sdB.wav', ...
%    a,c,d,b);
enhanfile = @(a,b,c,d) sprintf( ...
    '/users/ash/documents/thesisdata/testdat/%s/enhanced/%s_%sut%sdB.wav', ...
    a,c,d,b);
% Set format such that this function will return the unenhanced version of
% the sound
dirtyfile = @(a,b,c,d) sprintf( ...
    '/users/ash/documents/thesisdata/testdat/%s/test_dirty%sdB.wav', ...
    a,num2str(str2double(b)));
outcsv = '/users/ash/documents/thesisdata/testdat/MOSscores.csv';

% Tests to run
MOS = true;
MOSle = true;
MOSlp = false;
CCR = true;

%%% SCRIPT

% Form a matrix combining rows of all possible combinations of var params
[n,m,l,k] = ndgrid(1:length(aVals), 1:length(bVals), 1:length(cVals), ...
    1:length(dVals));
combs = [n(:) m(:) l(:) k(:)];

testLength = size(combs,1); % number of test points

fprintf('Test will run over %i test points\n',testLength)

TPs = cell(testLength,1);
for tp=1:testLength
    comb = combs(tp);
    a=aVals{combs(tp,1)}; b=bVals{combs(tp,2)};
    c=cVals{combs(tp,3)}; d=dVals{combs(tp,4)};
    
    % get files
    dirty = dirtyfile(a,b,c,d);
    enhan = enhanfile(a,b,c,d);
    
    % read files
    [dirtyWav,FS1] = wavread(dirty);
    [enhanWav,FS2] = wavread(enhan);
    
    if (FS1 ~= FS2)
        warning('Files have different sampling frequencies')
    end
    
    % Created Test Point structure
    TP.dirty = dirty;
    TP.enhan = enhan;
    TP.dirtyWav = dirtyWav;
    TP.enhanWav = enhanWav;
    TP.FS = FS1;
    TP.a=a; TP.b=b; TP.c=c; TP.d=d;
    TPs{tp} = TP;
end

% Start test
id = input('Welcome. Please enter your id given by examiner: ');
results = MOS(TPs,'doMOS',MOS,'doMOSle',MOSle,'doMOClp',MOSlp,'doCCR',CCR);

% Save results to file. Appends, so that multiple users can be tested
needsHeader = exist(outcsv,'file');
fid = open(outcsv,'a+');
if needsHeader
    fprintf(fid,'ID,%s,%s,%s,%s,MOS,MOSle,MOSlp,CCR\n', ...
        aName,bName,cName,dName);
end
for i=1:testLength
    fprintf(fid,'%s,%s,%s,%s,%s,%f,%f,%f,%f\n', ...
        id,TPs{i}.a,TPs{i}.b,TPs{i}.c,TPs{i}.d, ...
        results{i}.MOS,results{i}.MOSle,results{i}.MOSlp,results{i}.CCR);
end
fclose(fid);