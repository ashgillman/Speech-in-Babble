allPhonemes = {'p' 't' 'k' 'pcl' 'tcl' 'kcl' 'dx' 'm' 'n' 'ng' 'nx' 's'...
    'z' 'ch' 'th' 'f' 'l' 'r' 'y' 'pau' 'hh' 'eh' 'ao' 'aa' 'uw' 'er'...
    'ay' 'ey' 'aw' 'ax' 'ix' 'b' 'd' 'g' 'bcl' 'dcl' 'gcl' 'q' 'em' 'en'...
    'eng' 'sh' 'zh' 'jh' 'dh' 'v' 'el' 'w' 'h#' 'epi' 'hv' 'ih' 'ae'...
    'ah' 'uh' 'ux' 'oy' 'iy' 'ow' 'axr' 'ax-h' ... up to here from web
    'sil' 'oh' 'ia' 'ea' 'ua'}; % these last few from inspection
timeslice = 4e-2; %40ms slices
wavSamplesPerPhn = 10;

%get all training speaker folders
trainingDir = '/Users/Ash/Documents/ThesisData/wsjcam0/rawdat/si_tr/';
speakerDirs = dir(trainingDir);

% randomly draw a speaker, get files
speakerID = datasample(speakerDirs(4:end),1);
[phnFiles,wavFiles] = getSpeakerFiles(trainingDir,speakerID.name);

% draw a random set of phoneme samples
[phonemeSamples,fs] = drawPhnSamples([trainingDir speakerID.name '/'],...
    timeslice,wavSamplesPerPhn,allPhonemes);

% construct a plot of the number of samples drawn by phoneme
numSamples = cellfun(@(x) x(2),...
    cellfun(@size,phonemeSamples,'UniformOutput',false));
stem(numSamples);
set(gca,'XLim',[1 numel(allPhonemes)],'XTick',1:numel(allPhonemes),...
    'XTickLabel',allPhonemes)
