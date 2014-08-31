path(path, '/Users/Ash/Dropbox/Uni/2014/Thesis/Code/MATLAB/voicebox');
wsjcam0 = '/Users/Ash/Documents/ThesisData/wsjcam0/rawdat/';

[y,fs,wmode,fidx]=readwav([wsjcam0 'si_et_1/c3b/c3ba010a.wav']);
fid = fopen([wsjcam0 'si_et_1/c3b/c3ba010a.phn']);
phnData = textscan(fid,'%u %u %s','delimiter','\t');

%soundsc(y,fs);
aplayer = audioplayer(y,fs);

startstops = [phnData{1}+1 phnData{2}+1];

% backspaces = '';
% for index = 1:numel(phnData{1})
%     fprintf([backspaces phnData{3}{index}]);
%     playblocking(aplayer,startstops(index,:));
%     backspaces = repmat('\b',1,numel(phnData{3}{index}));
% end

callbackData.backspaces = '';
callbackData.phones = phnData{3};
callbackData.startstops = startstops;

set(aplayer, 'UserData', callbackData);
set(aplayer, 'TimerFcn', @apCallback);
set(aplayer, 'TimerPeriod', 0.1);

playblocking(aplayer);