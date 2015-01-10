function [time_points, noveltyCurve, featureRate] = beat_peter(audio, Fs)

%% compute novelty curve
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parameterNovelty = [];

[noveltyCurve, featureRate] = audio_to_noveltyCurve(audio, Fs, parameterNovelty);


%% compute fourier-based tempogram (log tempo axis)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

octave_divider =  120; %15, 30, 60 ,120
ref = 30;

tempoWin = 8;
tempoHop = 0.2;

parameterTempogram = [];
parameterTempogram.featureRate = featureRate;
parameterTempogram.tempoWindow = tempoWin;         % window length in sec
parameterTempogram.stepsize = ceil(featureRate * tempoHop);
parameterTempogram.BPM = ref*2.^(0:1/octave_divider:4); % log tempo axis

[tempogram, T, BPM] = noveltyCurve_to_tempogram_via_DFT(noveltyCurve,parameterTempogram);

[~, targetTempoIdx] = max(sum(abs(tempogram),2));

while BPM(targetTempoIdx) > 240
    newbpm = BPM(targetTempoIdx)/2;
    targetTempoIdx = bpm2idx(newbpm, ref, octave_divider);
end

refTempo = BPM(max(targetTempoIdx - octave_divider/2, 1));

%% derive cyclic tempogram
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


parameterCyclic = [];
parameterCyclic.refTempo = refTempo;
parameterCyclic.octave_divider = octave_divider;

[cyclicTempogram, cyclicAxis] = tempogram_to_cyclicTempogram(tempogram, BPM, parameterCyclic);
cyclicTempogram = normalizeFeature(cyclicTempogram,2, 0.0001);

oct = floor(targetTempoIdx/octave_divider);
BPM_c = cyclicAxis * ref * 2^oct;
%% viterbi

octRange = 1;
range = octave_divider * octRange;
prior = mean(cyclicTempogram, 2);

g = gausswin(range*2+1, 25);
g = g/sum(g);

transmat = zeros(range);
for i = 0:range-1
    transmat(i+1,:) = g(range+1-i: 2*range -i);
end

tempoIdxC = viterbi(prior, transmat, cyclicTempogram, 0);

tempoCurve = BPM_c(tempoIdxC);
%tempoIdx = bpm2idx(tempoCurve, ref, octave_divider);
%%

% imagesc(abs(cyclicTempogram))
% set(gca,'YTick',(1:25:size(cyclicTempogram,1)))
% set(gca,'YTickLabel',BPM_c(1:25:end));
% axis xy
% hold on
% plot(tempoIdxC, 'r')
%%
% imagesc(abs(tempogram))
% set(gca,'YTick',(1:25:length(BPM)))
% set(gca,'YTickLabel',BPM(1:25:end));
% axis xy
% hold on
% plot(tempoIdx, 'r')

%%
parameterPLP = [];
parameterPLP.featureRate = parameterTempogram.featureRate;
parameterPLP.tempoWindow = parameterTempogram.tempoWindow;
parameterPLP.stepsize = parameterTempogram.stepsize;

parameterPLP.useTempocurve = 1;
parameterPLP.tempocurve = tempoCurve;

[PLP, featureRate] = tempogram_to_PLPcurve(tempogram, T, BPM, parameterPLP);

[~, beats] = fpeaks(PLP); % get beat positions

time_points = beats / featureRate;
