%subplot(numel(numberRecs),1,num);
figure()

data = getaudiodata(phoneticRec); % get the waveform
data = data(find(data,1,'first'):find(data,1,'last')); % trim

[y,f,t,p] = spectrogram(data,50);
surf(t,f,10*log10(abs(p)),'EdgeColor','none');
axis xy; axis tight; colormap(jet); view(0,90);
title('The beige hue...');
xlabel('Time');
ylabel('Frequency Bin');