allPhonemes = {'p' 't' 'k' 'pcl' 'tcl' 'kcl' 'dx' 'm' 'n' 'ng' 'nx' 's' 'z'...
    'ch' 'th' 'f' 'l' 'r' 'y' 'pau' 'hh' 'eh' 'ao' 'aa' 'uw' 'er' 'ay'...
    'ey' 'aw' 'ax' 'ix' 'b' 'd' 'g' 'bcl' 'dcl' 'gcl' 'q' 'em' 'en' ...
    'eng' 'sh' 'zh' 'jh' 'dh' 'v' 'el' 'w' 'h#' 'epi' 'hv' 'ih' 'ae'...
    'ah' 'uh' 'ux' 'oy' 'iy' 'ow' 'axr' 'ax-h' ... up to here from web
    'sil' 'oh' 'ia' 'ea' 'ua'}; % these last few from inspection
timeslice = 1e-2; %10ms slices
maxNumSamples = 10;

%get all training speaker folders
trainingDir = '/Users/Ash/Documents/ThesisData/wsjcam0/rawdat/si_tr/';
speakerDirs = dir(trainingDir);

% randomly draw a speaker, get files
speakerID = datasample(speakerDirs(4:end),1);
phnFiles = dir([trainingDir speakerID.name '/*.phn']);
wavFiles = dir([trainingDir speakerID.name '/*.wav']);

%randomly draw a recording, open files
currentRecPhnFilename = datasample(phnFiles,1);
currentRecPhnFID = fopen([trainingDir speakerID.name '/'...
    currentRecPhnFilename.name]);
phnData = textscan(currentRecPhnFID,'%u %u %s','delimiter','\t');
fclose(currentRecPhnFID);
[y,fs,wmode,fidx]=readwav([trainingDir speakerID.name '/'...
    currentRecPhnFilename.name(1:end-4) '.wav']);

numSamples = ceil(timeslice * 1/fs);

phonemeSamples = cell(numel(allPhonemes),1);
for phonemeNum = 1:numel(allPhonemes)
    phoneme = allPhonemes{phonemeNum};
    %do we need more of this phoneme?
    if numel(phonemeSamples{phonemeNum}) < maxNumSamples
        % find any present occurences of current phone
        phoneOccurences = find(strcmp(phoneme,phnData{3}));
        for k = 1:numel(phoneOccurences)
            index = phoneOccurences(k);
            %choose a random point to sample phoneme
            firstSamp = phnData{1}(index);
            lastSamp = phnData{2}(index);
            if lastSamp-firstSamp > numSamples
                samplestart = randi([firstSamp lastSamp-numSamples]);
                samplePoints = samplestart:samplestart+10;
            else
                samplePoints = firstSamp:lastSamp;
            end
            phonemeSamples{phonemeNum}{end+1} = y(samplePoints);
        end
    end
end

numSamples = cellfun(@size,phonemeSamples,'UniformOutput',false);
numSamples2 = cellfun(@(x) x(2),numSamples);
stem(numSamples2);
set(gca,'XLim',[1 numel(allPhonemes)],'XTick',1:numel(allPhonemes),...
    'XTickLabel',allPhonemes)

