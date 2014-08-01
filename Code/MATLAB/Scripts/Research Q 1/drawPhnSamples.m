function [phonemeSamples,fs] = drawPhnSamples(directory,time,...
    wavSamplesPerPhn,phnList)
%DRAWPHNSAMPLES Draws a given number of randon samples of phonemes
%   Directory is the directory in which phn and wav files are kept.
%   Time is the length (in seconds) of the samples taken for each phoneme,
%   actual lengths may be shorter.
%   WavSamplesPerPhn is the number of waveform samples to take for each
%   phoneme in phnList.
%   phonemeSamples is the resultant samples drawn.
phonemeSamples = cell(numel(phnList),1);
[phnFiles,wavFiles] = getSpeakerFiles(directory);

%randomly draw a recording, open files
for k = randperm(numel(phnFiles))
    currentRecPhnFilename = phnFiles(k); %for all files, rand order
    [recordingPhns,startstops] = getPhnData([directory...
        currentRecPhnFilename.name]);
    [y,fs,wmode,fidx]=readwav([directory...
        currentRecPhnFilename.name(1:end-4) '.wav']);

    numSamples = ceil(time * fs);

    for phonemeNum = 1:numel(phnList)
        phoneme = phnList{phonemeNum};
        % find any present occurences of current phone
        phoneOccurences = find(strcmp(phoneme,recordingPhns));
        for l = randperm(numel(phoneOccurences))
            %do we need more of this phoneme?
            if numel(phonemeSamples{phonemeNum}) < wavSamplesPerPhn
                index = phoneOccurences(l); %for all occurences, rand order
                %choose a random point to sample phoneme
                firstSamp = startstops(index,1);
                lastSamp = startstops(index,2);
                if lastSamp-firstSamp > numSamples
                    samplestart = randi([firstSamp lastSamp-numSamples]);
                    samplePoints = samplestart:samplestart+numSamples-1;
                else
                    samplePoints = firstSamp:lastSamp;
                end
                phonemeSamples{phonemeNum}{end+1} = y(samplePoints);
            end
        end
    end
end