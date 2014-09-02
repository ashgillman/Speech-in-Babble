close all
clear all

testname = '1';
mix = 0; % dB

% const params
DAT_LOC = ['/Volumes/Gillman/Thesis/testdat/' testname '/'];
OUT_LOC = [DAT_LOC 'enhanced/']; mkdir(OUT_LOC);
FS = 16000;

% variation params
trainLens = [1 3 5 10 15 20 30 40 50 60 70 80];
mixes = [-6 -3 0 3];
%numInBabble = [1 2 3];
enhAlgs = {@mohammadiaSupervised};

% logging
logfile = [DAT_LOC 'enhPerf.csv'];
fid = fopen(logfile,'w+');
fprintf(fid,'Input SNR, Algorithm, Utterances, Time\n');
fclose(fid);

for mixNo = 1:numel(mixes)
    mix = mixes(mixNo);
    fprintf('===%idB Mix Test===\n',mix);
    
    % read dirty to be cleaned
    dirtyWav = wavread([DAT_LOC 'test_dirty' num2str(mix) 'dB.wav']);

    for algNo = 1:numel(enhAlgs)
        enhAlg = enhAlgs{algNo};
        enhAlgName = func2str(enhAlg);
        fprintf('--Testing %s algorithm--\n',enhAlgName);
        
        for i=1:numel(trainLens)
            trainLen = trainLens(i);
            fprintf('testing for %i utterances\n',trainLen);

            % load train data
            fprintf('loading training data...  '); tic;
            SoIWav = wavread([DAT_LOC '/' num2str(trainLen) 'ut/' ...
                'train_SoI.wav']);
            CompSpkrWav = wavread([DAT_LOC '/' num2str(trainLen) 'ut/' ...
                'train_compSpkr.wav']);
            disp(toc)

            % enhance
            fprintf('extracting for %i utterances...  ',trainLen); tic;
            MSenhWav = enhAlg(SoIWav,CompSpkrWav,dirtyWav);
            enhTime = toc;
            disp(enhTime);

            % norm and save
            MSenhWav = 0.9 * normalise(MSenhWav);
            wavwrite(MSenhWav,FS, ...
                sprintf('%s%s_%03iut%02idB.wav', ...
                OUT_LOC, enhAlgName, trainLen, mix));
            fprintf('%s%s_%03iut%02idB.wav\n', ...
                OUT_LOC, enhAlgName, trainLen, mix);
            
            %log
            fid = fopen(logfile,'a');
            fprintf(fid,'%i,%s,%i,%f\n',mix,enhAlgName,trainLen,enhTime);
            fclose(fid);
        end
    end
end
