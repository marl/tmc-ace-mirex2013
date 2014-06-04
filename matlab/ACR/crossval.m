function [result] = crossval(folds, scratch, gmmfile, penalty, T)

addpath('./chord_Utils');

nFold = size(folds, 1);

load(gmmfile);

band = size(gmm_set, 2);

cids = {};
for m = 1:length(chordSet)
    cs = cid2chordStruct(chord2cid(chordSet{m}));
    cids = [cids chord2cid(chordSet{m})];
    if cs.quality ~= 0
        for key = 1:11
            cs.bass = rem(cs.bass + 1, 12);
            cs.root = rem(cs.root + 1, 12);
            cids = [cids, chordStruct2cid(cs)];
        end
    end
end

Q = size(transmat,1);
index_map = containers.Map(cids, 1:length(cids));

obslik_root = [scratch filesep 'Obslik'];
%%

confusionMat = cell(nFold, 1);

results = zeros(nFold, 1);

w = 1/band;

for i = 1:nFold
    confusionMat{i} = zeros(Q+1,Q+1);
    
    for song = folds{i}'
        
        [~, name, ext] = fileparts(song{1});
        
        obslik_name = [obslik_root filesep name '.mat'];
            
        labChord = [];
        
        
        if exist(obslik_name, 'file')
            load(obslik_name);
        else
            
            chroma_name = [scratch filesep name ext '.mat'];
            load(chroma_name);
                
            for b = 1:band
                if b == 1
                    obslik = zeros((length(chordSet)-1)*12 + 1, size(chroma{1}, 2));
                end
                
                c_idx = 1;
                for m = 1:length(chordSet)
                    gmm = gmm_set{m, b};
                    if strcmp(chordSet{m}, 'N')
                        if b == 1
                            obslik(c_idx, : ) = pdf(gmm, chroma{b}')';
                        else
                            obslik(c_idx, : ) = obslik(c_idx, : ) .* pdf(gmm, chroma{b}')';
                        end
                        c_idx = c_idx+1;
                    else
                        for key = 0:11
                            if b == 1
                                obslik(c_idx, : ) = pdf(gmm, circshift(chroma{b}, -key)')';
                            else
                                obslik(c_idx, : ) = obslik(c_idx, : ) .* pdf(gmm, circshift(chroma{b}, -key)')';
                            end
                            
                            c_idx = c_idx+1;
                        end
                    end
                end
                
            end
            
            labFile_name = [song{1} '.txt'];
            
            [startT, endT, labChord] = textread(labFile_name,'%f %f %s');
            
            for s = 1:length(labChord)
                labChord{s} = strrep(labChord{s}, '*', '');
            end
            
            labCid = zeros(size(labChord));
            for s = 1:length(labChord)
                cid = chord2cid(labChord{s});
                cs = cid2chordStruct(cid);
                cs.ext = 0;
                cs.bass = cs.root;
                labCid(s) = chordStruct2cid(cs);
            end
            
            to_be_removed = find(beats_in_time > endT(end));
            beats_in_time = beats_in_time(1:end-length(to_be_removed));
            
            makedir(obslik_root);
            save(obslik_name, 'obslik', 'beats_in_time', 'labCid', 'startT', 'endT');
        end
             
        
        labChordIndex = zeros(size(labChord));
        
        for s = 1:length(labCid)
            if isKey(index_map, labCid(s))
                labChordIndex(s) = index_map(labCid(s));
            else
                labChordIndex(s) = Q+1;
            end
        end
        
        obslik = obslik.^w;
        
        switch T
            case {'bi'}
                cd = viterbi(ones(Q,1)/Q, transmat, obslik, penalty);
            case 'uni'
                cd = viterbi(ones(Q,1)/Q, ones(Q)/Q, obslik, penalty);
            case 'none'
                [~, cd] = max(obslik);
        end
              
        chord_idx = 2;
        beat_idx = 2;
        
        song_confMat = zeros(Q+1,Q+1);
        
        current_time = 0;
        chord_dur = 0;
        while(1)  
            if beats_in_time(beat_idx) < startT(chord_idx)
                chord_dur = beats_in_time(beat_idx) - current_time;
                current_time = beats_in_time(beat_idx);
                
                song_confMat(labChordIndex(chord_idx-1), cd(beat_idx-1)) = song_confMat(labChordIndex(chord_idx-1), cd(beat_idx-1)) + chord_dur;
                beat_idx = beat_idx + 1;
            else
                chord_dur = startT(chord_idx) - current_time;
                current_time = startT(chord_idx);

                song_confMat(labChordIndex(chord_idx-1), cd(beat_idx-1)) = song_confMat(labChordIndex(chord_idx-1), cd(beat_idx-1)) + chord_dur;
                chord_idx = chord_idx +1;
            end
            
            
            if chord_idx > length(startT)
                for remain = beat_idx:length(beats_in_time)
                    chord_dur = beats_in_time(remain) - current_time;
                    current_time = beats_in_time(remain);

                    song_confMat(labChordIndex(end), cd(remain-1)) = song_confMat(labChordIndex(end), cd(remain-1)) + chord_dur;                                
                end
                chord_dur = endT(end) - current_time;

                song_confMat(labChordIndex(end), cd(remain)) = song_confMat(labChordIndex(end), cd(remain)) + chord_dur; 
                break;
            end
            
            if beat_idx > length(beats_in_time)
                for remain = chord_idx:length(startT)
                    chord_dur = startT(remain) - current_time;
                    current_time = startT(remain);

                    song_confMat(labChordIndex(remain-1), cd(end)) = song_confMat(labChordIndex(remain-1), cd(end)) + chord_dur;            
                end
                chord_dur = endT(end) - current_time;

                song_confMat(labChordIndex(remain), cd(end)) = song_confMat(labChordIndex(remain), cd(end)) + chord_dur;  
                
                break;
            end
        end
        
        confusionMat{i} = confusionMat{i} + song_confMat;
        
        song_correct_time =  sum(diag(song_confMat));
        song_total_time = sum(sum(song_confMat));
        song_total_valid_time = sum(sum(song_confMat(1:Q, 1:Q)));
        Precision = song_correct_time/song_total_time*100;
        Recall = song_correct_time/song_total_valid_time*100;
        
        
        fprintf('%s %.2f/%.2f (%.2f) Precision: %.2f %%, Recall: %.2f %%\n', name, ...
            song_correct_time, song_total_time, song_total_valid_time, Precision, Recall);
        
    end
    
    set_correct_time =  sum(diag(confusionMat{i}));
    set_total_time = sum(sum(confusionMat{i}));
    set_total_valid_time = sum(sum(confusionMat{i}(1:Q, 1:Q)));
    Precision = set_correct_time/set_total_time*100;
    Recall = set_correct_time/set_total_valid_time*100;
    
    fprintf('Set %d  %.2f/%.2f (%.2f) Precision: %.2f %% , Recall: %.2f %%\n\n', i, ...
        set_correct_time, set_total_time, set_total_valid_time, Precision, Recall);
    
    results(i) = Recall;
end

totalConfusion = zeros(Q+1,Q+1);

for i = 1:nFold
    totalConfusion = totalConfusion + confusionMat{i};
end

total_correct_time =  sum(diag(totalConfusion));
total_total_time = sum(sum(totalConfusion));
total_total_valid_time = sum(sum(totalConfusion(1:Q, 1:Q)));
Precision = total_correct_time/total_total_time*100;
Recall = total_correct_time/total_total_valid_time*100;

result = mean(results);

fprintf('Total %.2f/%.2f (%.2f) Precision: %.2f %%, Recall:  %.2f %% with penalty %d\n\n', ...
    total_correct_time, total_total_time, total_total_valid_time, Precision, Recall, -penalty);


