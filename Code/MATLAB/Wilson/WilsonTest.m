Fs = 16000;
nf = 513;
nb = 80;

% Include Voicebox Library
VOICEBOX_LOC = '/Users/Ash/Dropbox/Uni/2014/Thesis/Code/MATLAB/voicebox';
if ~strfind(path,VOICEBOX_LOC)
    path(VOICEBOX_LOC,path)
end

[trainData,FsIn] = audioread(['/users/ash/documents/thesisdata/' ...
    'wsjcam0/rawdat/si_dt/c3c/c3ca010a.wav']);
trainData = resample(trainData,FsIn,Fs);
soundsc(trainData,Fs);

frameN = (nf-1)*2;
win = hamming(frameN);
trainSTFT = abs(rfft(enframe(trainData,win,nf-1),frameN,2))';
surf(trainSTFT,'EdgeColor','none'); axis xy; axis tight; view(0,90);