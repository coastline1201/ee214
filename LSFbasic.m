function [ls] = LSFbasic(rawdata, Fs)
%% setup variables
winlen      = 20;             % window length in ms           
winshft     = 10;             % window shift in ms
lpcorder    = 12;
preemp  = 0.97;           % coefficient for pre-emphasis 
% p = Fs/1000 + 2;                % LPC order
s = rawdata;
fsamp = Fs;
wlen = round(winlen * 10^(-3) * fsamp);
inc = round(winshft * 10^(-3) * fsamp);
%% preemphasis, enframe, windowing
s_preemp = filter([1 -preemp],1,s');  % preemphasis
%s_frame = enframe(s_preemp,wlen,inc);   % enframe, each row is a frame 
%NFrame = length(s_frame(:,1));      % number of frames
%hamwin = hamming(wlen)';    % set hamming window
%windowedFrames = zeros(NFrame,wlen);
%for n=1:NFrame                      % window each frame
%    windowedFrames(n,:) = s_frame(n,:).*hamwin;
%end
%% LPC, LSF 
%for n = 1: NFrame
%    [A,E]=lpc(windowedFrames(n,:),lpcorder); 
%    ls(n,:) = lpcar2ls(A);
%    
%end
ar = lpcauto(s_preemp, lpcorder, [inc, wlen]);
ls = lpcar2ls(ar);