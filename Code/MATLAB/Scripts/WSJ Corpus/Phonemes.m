phonemes = {'p' 't' 'k' 'pcl' 'tcl' 'kcl' 'dx' 'm' 'n' 'ng' 'nx' 's' 'z'...
    'ch' 'th' 'f' 'l' 'r' 'y' 'pau' 'hh' 'eh' 'ao' 'aa' 'uw' 'er' 'ay'...
    'ey' 'aw' 'ax' 'ix' 'b' 'd' 'g' 'bcl' 'dcl' 'gcl' 'q' 'em' 'en' ...
    'eng' 'sh' 'zh' 'jh' 'dh' 'v' 'el' 'w' 'h#' 'epi' 'hv' 'ih' 'ae'...
    'ah' 'uh' 'ux' 'oy' 'iy' 'ow' 'axr' 'ax-h' ... up to here from web
    'sil' 'oh' 'ia' 'ea' 'ua'}; % these last few from inspection

counts = zeros(numel(phonemes),1);

for k = 1:100
    %verify
    %get all training speaker folders
    trainingDir = '/Users/Ash/Documents/ThesisData/wsjcam0/rawdat/si_tr/';
    speakerDirs = dir(trainingDir);

    % randomly draw a speaker, get files
    currentDir = datasample(speakerDirs(4:end),1);
    phnFiles = dir([trainingDir currentDir.name '/*.phn']);

    %randomly draw a recording, open files
    currentRecPhnFilename = datasample(phnFiles,1);
    currentRecPhnFID = fopen([trainingDir currentDir.name '/'...
        currentRecPhnFilename.name]);
    phnData = textscan(currentRecPhnFID,'%u %u %s','delimiter','\t');
    fclose(currentRecPhnFID);

    for phoneI = 1:numel(phnData{3})
        phone = phnData{3}{phoneI};
        phoneNum = find(strcmp(phone,phonemes));
        if isempty(phoneNum)
            disp(['missing ' phone])
        else
            counts(phoneNum) = counts(phoneNum) + 1;
        end
    end
end