function [bspitch beats_in_time] = audio_to_pitch_MedianCQ(audio, Fs, beats_in_time, hop, pitch)
% 
% convert audio to beat synchronized pitchgram using FFT and log scale 
% energy kernel
%
% audio is segmented by times in beats_in_time and converted into pitchspectrum
%
% inputs:
%       audio - mono audio signal
%       Fs - samplerage
%       beats_in_time - information for time segmentation in sec.
%       pmin - minimum pitch should be extracted
%       pmax - maximum pitch should be extracted
%
% by Taemin Cho (tmc323@nyu.edu) 5/6/2012
%

if ~isvector(audio)
    error('audio must be a mono signal');
end

audio = reshape(audio, length(audio),1);

beats_in_time = reshape(beats_in_time, length(beats_in_time),1);
if beats_in_time(1) ~= 0
    beats_in_time = [0; beats_in_time]; % insert zero
end

beats_in_sample = round(beats_in_time * Fs);
beats_in_sample = beats_in_sample(beats_in_sample < length(audio));
nBeats = length(beats_in_sample);

beats_in_sample = [beats_in_sample; length(audio)]; % add end position

%pitchstcq = audio_to_pitch_STCQ(audio, Fs, win, hop);

% P = load(pitchname);
% pitch = P.pitch;

nFrame = size(pitch,2);
bspitch = zeros(120, nBeats);

for i = 1:nBeats
    sp = beats_in_sample(i);
    ep = beats_in_sample(i + 1);

    sp = floor(sp/hop);
    if rem(sp,hop) < hop/2
        sp = sp + 1;
    end
    ep = floor(ep/hop);
    if rem(ep,hop) > hop/2
        ep = ep + 1;
    end

    if sp == 0, sp = 1; end
    if ep > nFrame, ep = nFrame; end
    if sp > ep, ep = sp; end
    bspitch(:, i) = median(abs(pitch(:,sp:ep)),2);
end

beats_in_time = beats_in_sample(1:end-1)/Fs;