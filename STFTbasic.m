function [a] = STFTbasic(rawdata, Fs)
%% setup variables
winlen      = 20;             % window length in ms           
winshft     = 10;             % window shift in ms
preemp  = 0.97;           % coefficient for pre-emphasis

s = rawdata;
fsamp = Fs;
wlen = round(winlen * 10^(-3) * fsamp);
inc = round(winshft * 10^(-3) * fsamp);
nfft = 2*(2^nextpow2(wlen)); % FFT size

%% preemphasis, enframe, windowing
s_preemp = filter([1 -preemp],1,s');  % preemphasis
s_frame = enframe(s_preemp,wlen,inc);   % enframe, each row is a frame 
NFrame = length(s_frame(:,1));      % number of frames
hamwin = hamming(wlen)';    % set hamming window
windowedFrames = zeros(NFrame,wlen); fftFrames = zeros(NFrame,nfft);
%% FFT
for n=1:NFrame                      % window each frame
    windowedFrames(n,:) = s_frame(n,:).*hamwin;
    fftFrames(n,:) = abs(fft(windowedFrames(n,:),nfft));
    a(n,:) = fftFrames(n,:);
end