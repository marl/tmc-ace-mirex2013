function [pitch, pitch36] = audio_to_pitch_STCQ(audio, Fs, win, hop, pmin, pmax)
% 
% convert audio to pitchgram using Constant Q transform
% 
% inputs:
%       audio - mono audio signal
%       Fs - samplerage
%       win - window size or window function (default hanning)
%       hop - hop size
%       pmin - minimum pitch should be extracted
%       pmax - maximum pitch should be extracted
%
% by Taemin Cho (tmc323@nyu.edu) 5/6/2012
%

if nargin < 5, pmin = 21; end
if nargin < 6, pmax = 108; end

if ~isvector(audio)
    error('audio must be a mono signal');
end
    
if ~isscalar(win)
    error('win must be a sclarar value');
end

audio = reshape(audio, length(audio),1);
[~, ~, tuningSemitones] = estimateTuning_10cent(audio);

kernelfilename = sprintf('./ACR/CQ_KERNEL_pitch_%d_%d_%.2f.mat', pmin, pmax, tuningSemitones);

if exist(kernelfilename, 'file')               
    load(kernelfilename);
else
    kernel = sparseKernel(midi2hz(pmin - 1/3 +tuningSemitones), ...
        midi2hz(pmax + 1/3 +tuningSemitones), 36, Fs);
    
    save(kernelfilename, 'kernel');
end                            

fftLength = size(kernel,1);

audio = [zeros(fix(win/2),1); audio];
numSeg = floor(length(audio) / hop);
nz = win - rem(length(audio), hop);

audio = [audio; zeros(nz,1)];
pitch = zeros(120, numSeg);
if nargout == 2, pitch36 = zeros((pmax-pmin+1)*3,numSeg); end

csp = ceil((fftLength - win)/2);
cep = csp + win -1;
seg = zeros(fftLength,1);

for i = 1:numSeg
    sp = (i-1) * hop + 1;
    ep = sp + win -1;
    seg(csp:cep) = audio(sp:ep);
    seg = seg.*hamming(length(seg));
    X = fft(seg', fftLength);
    p = X * kernel;
    if nargout == 2
        pitch36(:,i) = abs(p);
    end
    pitch(pmin:pmax, i) = reshape(abs(p), 3, pmax-pmin+1)' * gausswin(3);
end