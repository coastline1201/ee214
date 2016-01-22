function [c] = MFCCbasic(rawdata, Fs)
%% setup variables
winlen      = 20;             % window length in ms           
winshft     = 10;             % window shift in ms
cepnum      = 12;             % order of cepstral coefficients used (C0 - Ccepnum)
numchan     = 26;             % number of filters in the Mel filter bank
preemp  = 0.97;           % coefficient for pre-emphasis 
s = rawdata;
fsamp = Fs;
wlen = round(winlen * 10^(-3) * fsamp);
inc = round(winshft * 10^(-3) * fsamp);
%% preemphasis, enframe, windowing
%s_preemp = filter([1 -preemp],1,s');  % preemphasis
%s_frame = enframe(s_preemp,wlen,inc);   % enframe, each row is a frame 
%NFrame = length(s_frame(:,1));      % number of frames
%hamwin = hamming(wlen)';    % set hamming window
%windowedFrames = zeros(NFrame,wlen);
%for n=1:NFrame                      % window each frame
%    windowedFrames(n,:) = s_frame(n,:).*hamwin;
%    C = melcepst(windowedFrames(n,:), fsamp, '0', cepnum, numchan, wlen, inc);
%    c(n,:) = C;
%end
s_preemp = filter([1 -preemp],1,s');
c = melcepst(s_preemp, fsamp, 'e0dD', cepnum, numchan, wlen, inc);