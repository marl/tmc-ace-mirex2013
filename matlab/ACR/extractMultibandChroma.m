function [chroma, beats_in_time, endT] = extractMultibandChroma(song, band)

Fs = 22050;
win = 4096;
hop = 1024;

if ~isempty(regexp(song, '.mp3', 'match', 'ignorecase'))
    [x, fs] = mp3read(song);
elseif ~isempty(regexp(song, '.wav', 'match', 'ignorecase'))
    [x, fs] = wavread(song);
else
    error('Can''t read %s', song);
end

if size(x,2) > 1
    x = mean(x,2); % mono
end

if fs ~= 22050
    fprintf('-> Resample to 22050 ');
    x = resample(x, Fs, fs, 100);
end

endT = length(x)/Fs;

% beat synchronization
fprintf('-> Beat Synchronization ');
beats_in_time = beat_peter(x, Fs);
%beats_in_time = beat2(x, Fs);

fprintf('-> Generating Pitchgram for Beat-sync ');
pitch = audio_to_pitch_STCQ(x, Fs, win, hop, 21, 108);
[pitch, beats_in_time] = audio_to_pitch_MedianCQ(x, Fs, beats_in_time, hop, pitch);

chroma = pitch2multi_chroma(pitch, band);

for b = 1:size(chroma,1)
    chroma{b} = normcq(chroma{b}, 2);
end