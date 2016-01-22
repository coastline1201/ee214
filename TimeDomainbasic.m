function [a] = TimeDomainbasic(rawdata, Fs)
%% setup variables
winlen      = 20;             % window length in ms           
winshft     = 10;             % window shift in ms
preemp  = 0.97;           % coefficient for pre-emphasis

s = rawdata;
fsamp = Fs;
wlen = round(winlen * 10^(-3) * fsamp);
inc = round(winshft * 10^(-3) * fsamp);

%% preemphasis, enframe, windowing
s_preemp = filter([1 -preemp],1,s');  % preemphasis
s_frame = enframe(s_preemp,wlen,inc);   % enframe, each row is a frame 
NFrame = length(s_frame(:,1));      % number of frames
hamwin = hamming(wlen)';    % set hamming window
windowedFrames = zeros(NFrame,wlen);

%% time domain feature extracting
stEnergy = zeros(NFrame, 1);
stZeroCros = zeros(NFrame, 1);
for n = 1 : NFrame
    windowedFrames(n,:) = s_frame(n,:).*hamwin;
    stEnergy(n) = sum(windowedFrames(n, :) .^ 2);
    stZeroCros(n) = length(zerocros(windowedFrames(n, :)));
end
a = [stEnergy, stZeroCros];