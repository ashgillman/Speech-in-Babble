function [enSpeech,fit] = mohammadiaSupervised(cleanTrain,noiseTrain,dirtyTest)
% Performs Mohammadia's Supervised NMF speech enhancement on dirtyTest,
% after using cleanTrain and noiseTrain to build a model.
%
% cleanTrain - clean speaker's wav to train on
% noiseTrain - noise wav to train on
% dirtyTest - mixed signal to enhance
%
% N. Mohammadiha, P. Smaragdis and A. Leijon, Supervised and Unsupervised
% Speech Enhancement Using Nonnegative Matrix Factorization, IEEE Trans.
% Audio, Speech, and Language Process., vol. 21, no. 10, pp. 2140-2151,
% oct. 2013.
%
% Written by Ashley Gillman

alen=512;ulen=256;%analysis and update length
fs=16000;%sampling frequency

% Include Libraries
BNMF_LOC = '/Users/Ash/Dropbox/Uni/2014/Thesis/Code/MATLAB/BNMF';
if isempty(strfind(path,BNMF_LOC))
    path(BNMF_LOC,path)
end

speech = cleanTrain/std(cleanTrain);
noise = noiseTrain/std(noiseTrain);
mixed = dirtyTest/std(dirtyTest);

%learn speech model, use separate training data for test and train.

spec_scale=5; %scale spectrograms to reduce rounding effect.
%Setting of this parameter is done experimentally.
%For normalized training data, and normalized analysis window (which is
%done here) spec_scale=5 is suitable.
num_speech_basis=60; %number of basis for speech nmf model
speechTr_Spect=spec_scale*MySpectrogram(speech,alen,ulen); %mag spectrogram
speech_nmf=NMF(speechTr_Spect,num_speech_basis);% nmf for speech model
setParameters(speech_nmf,'max_it',100,'update_boundFlag',1);
tic;
speech_nmf.train;%train the speech model
speechTrainTime = toc;

noise_name='my noise';%just give a name
a_noise=10;%
%learn separate model for each noise beforehand using some training data
num_noise_basis=100;%number of basis for noise nmf model
noiseTr_Spect=spec_scale*MySpectrogram(noise,alen,ulen);
noise_nmf=NMF(noiseTr_Spect,num_noise_basis);
setParameters(noise_nmf,'max_it',100,'update_boundFlag',1);
tic;
noise_nmf.train;
noiseTrainTime = toc;
noise_data=[];

%nmf model for the mixed signal
mixed_nmf.OutputDistr(1)=NMF(speech_nmf,noise_nmf,[]);%combine two nmf models
mixed_nmf.UserData{1,1}=[0 a_noise]; %\phi^(s) and \phi^(n) in the paper in section III.C. Should be set emprically for each noise
mixed_nmf.UserData{1,2}=noise_name;

%-----------------------------Enahancement---------------------------------
tic;
estimatedSNR=0;%initial value
win=hann(alen,'periodic');
norm_coef=sqrt(sum(win.^2));
win=win/norm_coef; %normalize window
n1 = 1;n2 = alen;
enSpeech=zeros(floor(length(mixed)/ulen)*ulen,1);%memory allocation
for n=1:floor(length(mixed)/ulen)-1
    Y=fft(mixed(n1:n2).*win);Y=Y(1:alen/2+1);
    MagIn=spec_scale*abs(Y);
    
    %run the main estimation function
    if n==1
        [mixed_nmf,Est_MagOut]=BNMF_Factorization_oneFrame(mixed_nmf,MagIn,n,estimatedSNR,spec_scale,noise_data);
    else
        [mixed_nmf,Est_MagOut]=BNMF_Factorization_oneFrame(mixed_nmf,MagIn,n,estimatedSNR,spec_scale);
    end
    
    %reconstruct enhanced signal using overlap-add framework
    X1=1/spec_scale*Est_MagOut.*exp(1i*angle(Y));
    X1(1,:)=real(X1(1,:));    X1(end,:)=real(X1(end,:));%has to be real
    X=[X1; conj(X1(end-1:-1:2,:))]; %coeff 0 and alen/2 are unique and others symmetric
    enSpeech(n1:n2)=enSpeech(n1:n2)+ifft(norm_coef*X);
    
    n1 = n1 + ulen;        n2 = n2 + ulen;
end
enhTime = toc;

fit.speechV = speech_nmf.Et;
fit.speechW = speech_nmf.Ev;
fit.noiseV = noise_nmf.Et;
fit.noiseW = noise_nmf.Ev;
fit.speechTrainTime = speechTrainTime;
fit.noiseTrainTime = noiseTrainTime;
fit.enhTime = enhTime;