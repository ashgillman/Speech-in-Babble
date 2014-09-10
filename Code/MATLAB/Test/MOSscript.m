% Prepares data for MOS evaluation, then runs the MOS function
%
% In each data location, "DAT_LOC", is a file 

clear all; close all;

%%% USER DEFINED - CHANGE THESE VARIABLES TO SUIT TEST

% Define test variation params
aVals = {'1' '2' '3'}; % test numbers
bVals = {'00'}; % SNRs
cVals = {'mohammadiaSupervised'}; % enhancement Algorithms
dVals = {'001' '003' '005' '010' '020' '030' '050' '080'}; % utterances

% Set format such that this function will return the wav file to test
enhanfile = @(a,b,c,d) sprintf( ...
    '/Volumes/Gillman 1/Thesis/testdat/%s/enhanced/%s_%sut%sdB.wav', ...
    a,c,d,b);
% Set format such that this function will return the unenhanced version of
% the sound
dirtyfile = @(a,b,c,d) sprintf( ...
    '/Volumes/Gillman 1/Thesis/testdat/%s/test_dirty%sdB.wav', ...
    a,num2str(str2num(b)));

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
    [dirtyWav FS1] = audioread(dirty);
    [enhanWav FS2] = audioread(enhan);
    
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

results = MOS(TPs);
%

N = 10 ;
A = rand(1,N) ;
B = randperm(N) ;
C = A(B) ;

% reverse randperm
[usused,R] = sort(B) ;
D = C(R) ;

A2 = []; A2(B) = C;

all(A2==A)