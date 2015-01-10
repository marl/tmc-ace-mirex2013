function chordCounts = extractFeatures(list, features, chordSet, band)

qualitySet = zeros(size(chordSet));
for i = 1:length(chordSet)
    cs = cid2chordStruct( chord2cid(chordSet{i}));
    qualitySet(i) = cs.quality;
end

numSong = length(list{1});

makedir(features);

chordCounts = zeros(length(chordSet), 1); % for containing a sample count for each chord

count = 0;
for song = list{1}'
    count = count +1;
    fprintf('%s (%d/%d)\n', song{1}, count, numSong);

    [~, name, ext] = fileparts(song{1});
    featureFileName = [features filesep name ext '.mat'];

    if exist(featureFileName, 'file')
        fprintf('-> Feature file exists');
        load(featureFileName);
    elseif strncmp(song{1}, '#', 1)
        fprintf('-> Skipping');
        continue
    else
        [chroma, time_points, endT] = extractMultibandChroma(song{1}, band);

        labFile_name = [song{1} '.txt'];
        labseg = bs_lab2seg(labFile_name, time_points);

        save(featureFileName, 'chroma', 'time_points', 'labseg', 'endT');
    end

    for m = 1:length(labseg)
        if labseg(m) >= 0
            cs = cid2chordStruct(labseg(m));

            % update chordQualityCount to measure the training data size
            for n = 1:length(qualitySet)
                if qualitySet(n) == cs.quality
                    chordCounts(n) = chordCounts(n) + 1;
                end
            end

        end
    end

    fprintf('-> Done\n');
end

