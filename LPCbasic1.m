function [a] = LPCbasic1(rawdata,Fs)
%% setup variables
winlen      = 20;             % window length in ms           
winshft     = 10;             % window shift in ms
lpcorder    = 12;
cepnum      = lpcorder;             % order of cepstral coefficients used (C0 - Ccepnum)
liftercoe   = 22;             % liftering coefficient
numchan     = 26;             % number of filters in the Mel filter bank
preemp  = 0.97;           % coefficient for pre-emphasis
deltawindow = 2;              % window length to calculate 1st derivative
accwindow   = 2;              % window length to calculate 2nd derivative
C0          = 0;              % to use zeroth cepstral coefficient or not 
% p = Fs/1000 + 2;                % LPC order
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
for n=1:NFrame                      % window each frame
    windowedFrames(n,:) = s_frame(n,:).*hamwin;
    %
end
%disp(size(fftFrames))
%% LPC 

for n = 1: NFrame
    [A,E]=lpc(windowedFrames(n,:),lpcorder);
    
    
    % Frame energy computation
    fftFrames(n,:) = fft(windowedFrames(n,:),nfft);
    energy = log(sum(abs(fftFrames(n,:)).^2));
    
    a(n,:) = [-A(2:end), energy];     % Ra = r, a(n,:) is the LPC of the nth frame
end