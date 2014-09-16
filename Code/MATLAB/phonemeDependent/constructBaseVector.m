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
sliceT = timeslice * fs;

% construct a plot of the number of samples drawn by phoneme
numSamples = cellfun(@(x) x(2),...
    cellfun(@size,phonemeSamples,'UniformOutput',false));

% Get V - spectal component matrix
Vspeaker = constructVMatrix(phonemeSamples,ceil(sliceT));

% Get X - output, by concatenating all samples together, taking FFTs
Y = [];
for a = 1:numel(wavFiles)
    Y = [Y;readwav([trainingDir  speakerID.name '/'...
        wavFiles(a).name])];
end
X = zeros(ceil(sliceT/2+1),floor(numel(Y))/sliceT);
Xindex = 1;
for Yindex = 1:sliceT:numel(Y)-sliceT
    X(:,Xindex) = rfft(Y(Yindex:Yindex+sliceT-1),sliceT);
    Xindex = Xindex+1;
end

% Calculate W - occurences matrix
%W = ones(size(Vspeaker,2),size(X,1));
%W=W.*(Vspeaker'*(X./(Vspeaker*W)))./(Vspeaker');


presentPhonemes = allPhonemes(numSamples~=0);
for (i=1:numel(presentPhonemes))
    presentPhonemes{i} = sprintf('/%s/', presentPhonemes{i});
end
presentPhonemes{end+1} = '';

figure()
hold all
p = 10*log10(abs(Vspeaker(1:ceil(sliceT)/2,:)));
p(p<-30)=-30;
%subplot(2,1,1);
surf(p,'EdgeColor','none'); 
axis xy; axis tight; colormap(jet); view(0,90);
set(gca,'XTick',[1;unique(cumsum(numSamples))],...
    'XTickLabel',presentPhonemes)
title('Vspeaker');
xlabel('components');
ylabel('Frequency Bin');

% p = 10*log10(abs(X));
% p(p<-30)=-30;
% subplot(2,1,2);
% surf(p,'EdgeColor','none'); 
% axis xy; axis tight; colormap(jet); view(0,90);
% title('Speech');
% xlabel('Time');
% ylabel('Frequency Bin');
