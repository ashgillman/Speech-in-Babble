function [overall_snr, segmental_snr] = snr(clean_speech, processed_speech,sample_rate)
% ----------------------------------------------------------------------
% Check the length of the clean and processed speech.  Must be the same.
% ----------------------------------------------------------------------

clean_length      = length(clean_speech);
processed_length  = length(processed_speech);
if (clean_length ~= processed_length)
  disp('Error: Both Speech Files must be same length.');
  return
end

% ----------------------------------------------------------------------
% Scale both clean speech and processed speech to have same dynamic
% range.  Also remove DC component from each signal
% ----------------------------------------------------------------------

%clean_speech     = clean_speech     - mean(clean_speech);
%processed_speech = processed_speech - mean(processed_speech);

%processed_speech = processed_speech.*(max(abs(clean_speech))/ max(abs(processed_speech)));

overall_snr = 10* log10( sum(clean_speech.^2)/sum((clean_speech-processed_speech).^2));

% ----------------------------------------------------------------------
% Global Variables
% ----------------------------------------------------------------------

% sample_rate = 8000;		   % default sample rate
% winlength   = 240;		   % window length in samples
% skiprate    = 60;		   % window skip in samples
winlength   = round(30*sample_rate/1000); %240;		   % window length in samples
skiprate    = floor(winlength/4);		   % window skip in samples
MIN_SNR     = -10;		   % minimum SNR in dB
MAX_SNR     =  35;		   % maximum SNR in dB

% ----------------------------------------------------------------------
% For each frame of input speech, calculate the Segmental SNR
% ----------------------------------------------------------------------

num_frames = clean_length/skiprate-(winlength/skiprate); % number of frames
start      = 1;					% starting sample
window     = 0.5*(1 - cos(2*pi*(1:winlength)'/(winlength+1)));

for frame_count = 1: num_frames

   % ----------------------------------------------------------
   % (1) Get the Frames for the test and reference speech. 
   %     Multiply by Hanning Window.
   % ----------------------------------------------------------

   clean_frame = clean_speech(start:start+winlength-1);
   processed_frame = processed_speech(start:start+winlength-1);
   clean_frame = clean_frame.*window;
   processed_frame = processed_frame.*window;

   % ----------------------------------------------------------
   % (2) Compute the Segmental SNR
   % ----------------------------------------------------------

   signal_energy = sum(clean_frame.^2);
   noise_energy  = sum((clean_frame-processed_frame).^2);
   segmental_snr(frame_count) = 10*log10(signal_energy/(noise_energy+eps)+eps);
   segmental_snr(frame_count) = max(segmental_snr(frame_count),MIN_SNR);
   segmental_snr(frame_count) = min(segmental_snr(frame_count),MAX_SNR);

   start = start + skiprate;

end