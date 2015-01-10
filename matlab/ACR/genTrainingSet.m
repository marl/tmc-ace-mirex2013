function [tr_set, transmat] = genTrainingSet(list, features, model, chordCounts, chordSet, band)
% Parameters
% ----------
% list: cell array?
%   Audio file paths as strings in an array
% features: str
%   Path to feature .mat files matching the base filenames of the items in list.
% model: str
%   Path to a directory to write out various model params.
% chordCounts: ?
% chordSet: set
%   String quality types for the classifier to fit.
% band: int
%   Number of subband chroma features.

trainingSetFile = [model filesep 'tr_set.mat'];
transmatFile = [model filesep 'transmat.mat'];

if exist(trainingSetFile, 'file') && exist(transmatFile, 'file')
    load(trainingSetFile);
    totalSamples = 0;
    for m = 1:length(chordSet)
        totalSamples = totalSamples + size(tr_set{m,1}, 2);
    end

    if totalSamples == sum(chordCounts)
        return;
    end
    clear tr_set
end

qualitySet = zeros(size(chordSet));
for i = 1:length(chordSet)
    cs = cid2chordStruct( chord2cid(chordSet{i}));
    qualitySet(i) = cs.quality;
end

cids = [];
for m = 1:length(chordSet)
    cs = cid2chordStruct(chord2cid(chordSet{m}));
    cids = [cids chord2cid(chordSet{m})];
    if cs.quality ~= 0
        for key = 1:11
            cs.bass = rem(cs.bass + 1, 12);
            cs.root = rem(cs.root + 1, 12);
            cids = [cids chordStruct2cid(cs)];
        end
    end
end

Q = length(cids);
cid_index_map = containers.Map(cids, 1:length(cids));

transmat = zeros(Q);


numSong = length(list{1});

tr_set = cell(length(chordSet), band);

% preserve memory
for n = 1:length(chordSet)
    for b = 1:band
        tr_set{n, b} = zeros(12, chordCounts(n));
    end
end

chordIdx = zeros(size(qualitySet));

count = 0;
for song = list{1}'
    count = count +1;
    fprintf('%s (%d/%d)\n', song{1}, count, numSong);

    [~, name, ext] = fileparts(song{1});
    featureFileName = [features filesep name ext '.mat'];
    fprintf('-> Load features ');
    load(featureFileName);

    labFile_name = [song{1} '.txt'];
    labseg = bs_lab2seg(labFile_name, time_points);

    fprintf('-> Updating bigrams and training Data\n');

    initial = true;

    nochord_idx = cid_index_map(0);

    for m = 1:length(labseg)
        if labseg(m) >= 0
            cs = cid2chordStruct(labseg(m));
            for n = 1:length(chordSet)
                if qualitySet(n) == cs.quality
                    chordIdx(n) = chordIdx(n) + 1;
                    for b = 1:band
                        tr_set{n, b}(:, chordIdx(n)) = circshift(chroma{b}(:, m), cs.root * -1);
                    end
                end
            end

            % calculate transmat
            cs.ext = 0;
            cs.bass = cs.root;
            chord = chordStruct2cid(cs);

            if isKey(cid_index_map, chord)
                if initial == true
                    previous = cs;
                    initial = false;
                else
                    from = previous;
                    to = cs;

                    prev = chordStruct2cid(from);
                    next = chordStruct2cid(to);

                    if from.quality == 0
                        transmat(cid_index_map(prev), cid_index_map(next)) = transmat(cid_index_map(prev), cid_index_map(next)) + 1;
                    else
                        prev_idx = cid_index_map(prev);
                        next_idx = cid_index_map(next);

                        prev_base = fix((prev_idx-1)/12) * 12;

                        if next_idx == nochord_idx
                            for t = 0:11
                                prev_r = rem(prev_idx - 1 + t, 12) + 1;
                                transmat(prev_base + prev_r, next_idx) = transmat(prev_base + prev_r, next_idx) + 1;
                            end
                        else
                            next_base = fix((next_idx-1)/12) * 12;
                            for t = 0:11
                                prev_r = rem(prev_idx - 1 + t, 12) + 1;
                                next_r = rem(next_idx - 1 + t, 12) + 1;
                                transmat(prev_base + prev_r, next_base + next_r) = transmat(prev_base + prev_r, next_base + next_r) + 1;
                            end
                        end
                    end
                    previous = cs;
                end
            else
                initial = true;
            end
        end
    end
end

fprintf('Save the transition matrix \n');

transmat = tmc_norm(transmat', 1)';
transmat(isnan(transmat)) = 0;
idx = find(transmat ~= 0);
mv = min(transmat(idx));
transmat = transmat + mv;
transmat = tmc_norm(transmat', 1)';

save(transmatFile, 'transmat', 'chordSet');

fprintf('Save the training Data \n');

save(trainingSetFile, 'tr_set', 'chordSet');
