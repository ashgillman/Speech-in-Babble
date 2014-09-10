function results = MOS(testParams,varargin)
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
    runMins = runMins + TP.enhan / TP.FS / 60;
    % CCR extra time
    if doCCR
        runMins = runMins + TP.dirty / TP.FS / 60;
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

% Begin Test
fprintf('Beginning test\nPress Enter to Begin\n');
pause
for TP=1:numTests
    TP = testParams{tp};
    
    if doCCR
        fprintf('Playing the unenhanced waveform...\nEnter to skip')
        ap = audioplayer(TP.dirtyWav,TP.FS);
        play(ap);
        while isplaying(ap)
            
    end
end

disp(MOSscale);