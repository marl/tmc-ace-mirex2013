function [bspitch time_points] = audio_to_pitch_MedianCQ(audio, Fs, time_points, hop, pitch)
%
% convert audio to beat synchronized pitchgram using FFT and log scale
% energy kernel
%
% audio is segmented by times in time_points and converted into pitchspectrum
%
% inputs:
%       audio - mono audio signal
%       Fs - samplerage
%       time_points - information for time segmentation in sec.
%       pmin - minimum pitch should be extracted
%       pmax - maximum pitch should be extracted
%
% by Taemin Cho (tmc323@nyu.edu) 5/6/2012
%

if ~isvector(audio)
    error('audio must be a mono signal');
end

audio = reshape(audio, length(audio),1);

time_points = reshape(time_points, length(time_points),1);
if time_points(1) ~= 0
    time_points = [0; time_points]; % insert zero
end

beats_in_sample = round(time_points * Fs);
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

time_points = beats_in_sample(1:end-1)/Fs;