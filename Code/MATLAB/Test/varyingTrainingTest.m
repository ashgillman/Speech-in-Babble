close all
clear all

% variation params
trainLens = [1 5 10 50 80];
mixes = [-6 -3 0 3 6];
enhAlgs = {@mohammadiaOnline @mohammadiaSupervised};
tests = [6 7];

numtests = length(trainLens) * length(mixes) * length(enhAlgs) + ...
    length(tests);
fits = cell(numtests,1);
times = cell(numtests,1);
testCount = 0;
for testNo = 1:numel(tests)
    testname = num2str(tests(testNo));
    fprintf('###Test %s###\n',testname);

    % const params
    %DAT_LOC = ['/Volumes/Gillman 1/Thesis/testdat/' testname '/'];
    DAT_LOC = ['/users/ash/documents/thesisdata/testdat/' testname '/'];
    OUT_LOC = [DAT_LOC 'enhanced/']; mkdir(OUT_LOC);
    FS = 16000;

    % logging
    logfile = [DAT_LOC 'enhPerf.csv'];
    if exist(logfile,'file') ~= 0
        fid = fopen(logfile,'w+');
        fprintf(fid,'Input SNR, Algorithm, Utterances, Time\n');
        fclose(fid);
    end

    for mixNo = 1:numel(mixes)
        mix = mixes(mixNo);
        fprintf('==%idB Mix Test==\n',mix);

        % read dirty to be cleaned
        dirtyWav = wavread([DAT_LOC 'test_dirty' num2str(mix) 'dB.wav']);

        for algNo = 1:numel(enhAlgs)
            enhAlg = enhAlgs{algNo};
            enhAlgName = func2str(enhAlg);
            fprintf('-Testing %s algorithm-\n',enhAlgName);

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
                [MSenhWav data] = enhAlg(SoIWav,CompSpkrWav,dirtyWav);
                testCount = testCount+1;
                enhTime = toc;
                disp(enhTime);
                
                % save fit
                fits{testCount} = data;
                times{testCount} = enhTime;
                save([OUT_LOC 'fitted.mat'],'fits','times');

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
end