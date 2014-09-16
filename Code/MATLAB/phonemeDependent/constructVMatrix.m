function [V] = constructVMatrix(phonemeRecordings,pointsPerSample)
%CONSTRUCTVMATRIX construct spectral component matrix (V) from
%phonemeRecordings.
%   PhonemeRecordings are short recordings of phonemes to contruct V from
%   in the format of a cell array of cell arrays of waveforms, where each
%   item in the outer cell array corresponds to a phoneme.
%   PointsPerSample is the max number of points in a given recording.

% get the sizes to preallocate
numSamples = cellfun(@(x) x(2),...
    cellfun(@size,phonemeRecordings,'UniformOutput',false));
V = zeros(pointsPerSample/2+1,sum(numSamples));

% step through every phoneme recording, take the FFT, and construct a
% matrix
c=1;
for a = 1:numel(phonemeRecordings)
    for b = 1:numel(phonemeRecordings{a})
        phonemeRecordings{a}{b} = [phonemeRecordings{a}{b};...
            zeros(pointsPerSample-numel(phonemeRecordings{a}{b}),1)];
        V(:,c) = rfft(phonemeRecordings{a}{b});
        c=c+1;
    end
end