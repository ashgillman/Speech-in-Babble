close all
clear all

% import libraries
MYTOOLS_LOC='/Users/Ash/Dropbox/Uni/2014/Thesis/Code/MATLAB/mytools';
if isempty(strfind(path,MYTOOLS_LOC))
    path(MYTOOLS_LOC,path)
end

% variation params
trainLens = [];
mixes = [-6 -3 0 3 6];
enhAlgs = {@mohammadiaOnline @mohammadiaSupervised};
tests = [8];
phnSampleCounts = [1 5 10 50 100 500 999];

numtests = (length(trainLens)+length(phnSampleCounts)) * length(mixes) * ...
    length(enhAlgs) + length(tests);
fits = cell(numtests,1);
times = cell(numtests,1);
testParms = cell(numtests,1);
testCount = 0;
for testNo = 1:numel(tests)
    testname = num2str(tests(testNo));
    fprintf('###Test %s###\n',testname);

    % const params
    %DAT_LOC = ['/Volumes/Gillman 1/Thesis/testdat/' testname '/'];
    DAT_LOC = ['/users/ash/documents/thesisdata/testdat/' testname '/'];
    OUT_LOC = [DAT_LOC 'enhanced/']; mkdir(OUT_LOC);
    FS = 16000;

    % create performance logginf file if non-existant
    logfile = [DAT_LOC 'enhPerf.csv'];
    if exist(logfile,'file') == 0
        fid = fopen(logfile,'w+');
        fprintf(fid,'Input SNR, Algorithm, Utterances, Total Time, Speech Time, Noise Time, Enhance Time\n');
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
                SoIWav = wavread([DAT_LOC '/' num2str(trainLen) ...
                    'ut/train_SoI.wav']);
                CompSpkrWav = wavread([DAT_LOC '/' num2str(trainLen) ...
                    'ut/train_compSpkr.wav']);
                disp(toc)

                % enhance
                fprintf('extracting...  '); tic;
                [MSenhWav,data] = enhAlg(SoIWav,CompSpkrWav,dirtyWav);
                testCount = testCount+1;
                enhTime = toc;
                disp(enhTime);
                
                % save fit
                fits{testCount} = data;
                times{testCount} = enhTime;
                testParms{testCount}.testNo = testname;
                testParms{testCount}.mix = mix;
                testParms{testCount}.alg = enhAlgName;
                testParms{testCount}.trainLen = trainLen;
                save([OUT_LOC 'fitted.mat'],'fits','times','testParms');

                % norm and save
                MSenhWav = 0.9 * normalise(MSenhWav);
                wavwrite(MSenhWav,FS, ...
                    sprintf('%s%s_%03iut%02idB.wav', ...
                    OUT_LOC, enhAlgName, trainLen, mix));
                fprintf('%s%s_%03iut%02idB.wav\n', ...
                    OUT_LOC, enhAlgName, trainLen, mix);

                % log performance
                fid = fopen(logfile,'a');
                fprintf(fid,'%i,%s,%i,%f,%f,%f,%f\n',mix,enhAlgName, ...
                    trainLen,enhTime,data.speechTrainTime, ...
                    data.noiseTrainTime,data.enhTime);
                fclose(fid);
            end
            enhAlgName = ['phoneme' enhAlgName];
            for phnSampleCount=phnSampleCounts
                fprintf('testing for %i phones\n',phnSampleCount);

                % load train data
                fprintf('loading training data...  '); tic;
                SoIWav = wavread([DAT_LOC '/' num2str(phnSampleCount) ...
                    'phntrain_SoI.wav']);
                CompSpkrWav = wavread([DAT_LOC '/5ut/train_compSpkr.wav']);
                disp(toc)

                % enhance
                fprintf('extracting...  '); tic;
                [MSenhWav,data] = enhAlg(SoIWav,CompSpkrWav,dirtyWav);
                testCount = testCount+1;
                enhTime = toc;
                disp(enhTime);
                
                % save fit
                fits{testCount} = data;
                times{testCount} = enhTime;
                testParms{testCount}.testNo = testname;
                testParms{testCount}.mix = mix;
                testParms{testCount}.alg = enhAlgName;
                testParms{testCount}.phnSampleCount = phnSampleCount;
                save([OUT_LOC 'fitted.mat'],'fits','times','testParms');

                % norm and save
                MSenhWav = 0.9 * normalise(MSenhWav);
                wavwrite(MSenhWav,FS, ...
                    sprintf('%s%s_%03iph%02idB.wav', ...
                    OUT_LOC, enhAlgName, phnSampleCount, mix));
                fprintf('%s%s_%03iph%02idB.wav\n', ...
                    OUT_LOC, enhAlgName, phnSampleCount, mix);

                % log performance
                fid = fopen(logfile,'a');
                fprintf(fid,'%i,%s,%i,%f,%f,%f,%f\n',mix,enhAlgName, ...
                    phnSampleCount,enhTime,data.speechTrainTime, ...
                    data.noiseTrainTime,data.enhTime);
                fclose(fid);
            end
        end
    end
end

% notify
for i=1:5
    beep
    pause(0.5)
end