function [results,testParams] = MOS(testParams,varargin)
% MOS Perform a Mean Opinion Score, ITU P.800 [1] Annex B and Annex E
% 
% It is up to the user to ensure recording are in line line with B.1. This
% test aligns with the experimental design in B.3
% It is recommended that listeners use professional quality over-ear
% headphones (without internal filtering or effects), unless experimental
% design dictates otherwise (e.g. for conditions to match the use case).
p = inputParser;
p.addParamValue('doMOS',true);
p.addParamValue('doMOSle',false);
p.addParamValue('doMOSlp',false);
p.addParamValue('doCCR',false);
p.addParamValue('MOSscale',{'Excellent','Good','Fair','Poor','Bad'});
p.addParamValue('MOSlescale',{ ...
    'Complete relaxation possible; no effort required', ...
    'Attention necessary; no appreciable effort required', ...
    'Moderate effort required', ...
    'Considerable effort required', ...
    'No meaning understood with any feasible effort'});
p.addParamValue('MOSlpscale',{'Much louder than preferred', ...
    'Louder than preferred', ...
    'Preferred', ...
    'Quieter than preferred', ...
    'Much quieter than preferred'});
p.addParamValue('CCRscale',{ ...
    'Much Better', ...
    'Better', ...
    'Slightly Better', ...
    'About the Same', ...
    'Slightly Worse', ...
    'Worse', ...
    'Much Worse'});
p.parse(varargin{:});
doMOS = p.Results.doMOS;
doMOSle = p.Results.doMOSle;
doMOSlp = p.Results.doMOSlp;
doCCR = p.Results.doCCR;
MOSscale = p.Results.MOSscale;
MOSlescale  = p.Results.MOSlescale;
MOSlpscale = p.Results.MOSlpscale;
CCRscale = p.Results.CCRscale;

% B.3 recommends session length limited to 20 mins, absolute maximum 45mins
numTests = length(testParams);
% calc runtime
runMins = 0;
for tp=1:numTests
    TP = testParams{tp};
    % MOS time
    runMins = runMins + length(TP.enhan) / TP.FS / 60;
    % CCR extra time
    if doCCR
        runMins = runMins + length(TP.dirty) / TP.FS / 60;
    end
end
if runMins > 45
    warning('Estimated runtime over critical recommended 45 mins');
elseif runMins > 20
    warning('Estimated runtime over recommended 20 mins');
end

% Shuffle, in alignment with [1] B.3
order = randperm(numTests);
testParams = testParams(order);
results = cell(size(testParams,1),1);

% Begin Test
fprintf('Beginning test\nPress Enter to Begin\n');
pause
for TP=1:numTests
    TP = testParams{tp};
    
    enhanAP = audioplayer(TP.enhanWav,TP.FS);
    if doCCR
        dirtyAP = audioplayer(TP.dirtyWav,TP.FS);
        CCR = NaN;
        while ~any(CCR == -3:3)
            play(dirtyAP);
            fprintf('Playing the unenhanced waveform...\nEnter to skip')
            pause;
            stop(dirtyAP);
            play(enhanAP);
            fprintf('Playing the enhanced waveform...\n')
            for i=3:-1:-3
                fprintf('%2i: %s\n',i,CCRscale{10-i});
            end
            CCR = str2double(input('>','s'));
        end
        result.CCR = CCR;
    else
        result.CCR = '-';
    end
    if doMOS
        result.MOS = doTest(MOSscale,enhanAP);
    else
        result.MOS = '-';
    end
    if doMOSle
        result.MOSle = doTest(MOSlescale,enhanAP);
    else
        result.MOSle = '-';
    end
    if doMOSlp
        result.MOSlp = doTest(MOSlpscale,enhanAP);
    else
        result.MOSlp = '-';
    end
    results{i} = result;
end
fprintf('Test complete, thank you.\n');

% Unshuffle
testParams(order) = testParams;
results(order) = results;
end

function score = doTest(scale,ap)
% Do MOS test
%   scale: scale values (cell string array)
%   ap: audioplayer with recording loaded
%   returns score, user input
score = NaN;
while ~any(score == 1:5)
    if ~isplaying(ap)
        play(ap)
        fprintf('Playing the waveform...\n')
    end
    for i=5:-1:1
        fprintf('%2i: %s\n',i,scale{6-i});
    end
    score = str2double(input('>','s'));
end
end