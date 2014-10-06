close all
Fs = 16000;

[y,FsIn] = audioread('example.wav');
y = resample(y,Fs,FsIn);


y = y(22500:22500+Fs*0.04*8-2); % get word 'levels'
playblocking(audioplayer(y,Fs));

figure
plot((1:numel(y)) / Fs * 1000,y)
axis tight
xlabel('Time (ms)')
ylabel('Amplitude')
title('Female Voice Saying "Levels"')
set(gcf, 'paperpositionmode', 'auto');
print -depsc formSTFT1.eps

splitVals = 0:Fs*0.04:numel(y);
splitVals = splitVals(2:end);
splits = zeros(size(y));
splits2 = zeros(size(y));
splits(splitVals) = max(y);
splits2(splitVals) = min(y);
figure
hold on
stem((1:numel(y)) / Fs * 1000,splits,'r','Marker','none')
stem((1:numel(y)) / Fs * 1000,splits2,'r','Marker','none')
plot((1:numel(y)) / Fs * 1000,y)
axis tight
xlabel('Time (ms)')
ylabel('Amplitude')
title('Female Voice Saying "Levels"')
set(gcf, 'paperpositionmode', 'auto');
print -depsc formSTFT2.eps


fftVals = zeros(size(y));
fftVals(1:splitVals(1)) = fft(y(1:splitVals(1)));
%freqs = linspace(0,Fs/1000,0.04*Fs);
for i = 1:numel(splitVals)-1
    fftVals(splitVals(i):splitVals(i+1)) = ...
        fft(y(splitVals(i):splitVals(i+1)));
end
%freqs = repmat(freqs,1,numel(splitVals));
fftVals(splitVals(end):end) = fft(y(splitVals(end):end));
%freqs = [freqs linspace(0,Fs/1000,numel(fftVals)-numel(freqs))];
figure
hold on
plot(abs(fftVals));
splits(splitVals) = max(abs(fftVals));
stem(splits,'r','Marker','none')
ticks = sort([1, splitVals / 2, splitVals/2+floor(numel(fftVals)/2)]);
set(gca,'XTick', ticks)
tickLabels = [0 repmat([Fs/1000/2 Fs/1000],1,numel(splitVals))];
set(gca,'XTickLabel',tickLabels)
axis tight
xlabel('Frequency (kHz)')
ylabel('FFT Amplitude')
title('Short Time Fourier Transform: Female Voice Saying "Levels"')
set(gcf, 'paperpositionmode', 'auto');
print -depsc formSTFT3.eps

figure
subplot(1,numel(splitVals)+1,1)
fftVal = abs(fft(y(1:splitVals(1))));
fftVal = fftVal(floor(1:numel(fftVal)/2 + 1));
plot(fftVal,linspace(0,Fs/1000/2,0.04*Fs/2+1));
for i = 1:numel(splitVals)-1
    subplot(1,numel(splitVals)+1,i+1)
    fftVal = abs(fft(y(splitVals(i):splitVals(i+1))));
    fftVal = fftVal(floor(1:numel(fftVal)/2 + 1));
    plot(fftVal,linspace(0,Fs/1000/2,0.04*Fs/2+1));
end
subplot(1,numel(splitVals)+1,numel(splitVals)+1)
fftVal = abs(fft(y(splitVals(end):end)));
fftVal = fftVal(floor(1:numel(fftVal)/2 + 1));
plot(fftVal,linspace(0,Fs/1000/2,numel(fftVal)));
subplot(1,numel(splitVals)+1,1)
ylabel('Frequency (kHz)')
subplot(1,numel(splitVals)+1,floor((numel(splitVals)+1)/2))
xlabel('FFT Amplitude')
title('Short Time Fourier Transform: Female Voice Saying "Levels"')
set(gcf, 'paperpositionmode', 'auto');
print -depsc formSTFT4.eps

figure
[s,f,t,p] = spectrogram(y,Fs*0.04,0,Fs*0.04,Fs);
surf(t*1000,f/1000,10*log10(abs(p)),'EdgeColor','none');   
axis xy; axis tight; colormap(jet); view(0,90);
title('Spectrogram: Female Voice Saying "Levels"')
xlabel('Time (ms)');
ylabel('Frequency (kHz)');
set(gcf, 'paperpositionmode', 'auto');
print -depsc formSTFT5.eps