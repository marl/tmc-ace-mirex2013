function [labseg, lab] = bs_lab2seg(labFile, beats_in_time, tolerance)

if nargin < 3
    tolerance = 0.7;
end

[startT, endT, labChord] = textread(labFile,'%f %f %s');
labChordCid = zeros(size(labChord));

for i = 1:length(labChord)
    labChord{i} = strrep(labChord{i}, '*', '');
end

for i = 1:length(labChord)
    labChordCid(i) = chord2cid(labChord{i}); 
end


if size(beats_in_time, 2) ~=1
    beats_in_time = beats_in_time';
end

templab = [[startT; endT(end)], [labChordCid; labChordCid(end)]];
lab = templab(1,:);
for i = 2:length(templab)
    if templab(i,2) ~= templab(i-1,2)
        lab = [lab; templab(i,:)];
    end
end

beat_dur = diff(beats_in_time);
if beats_in_time(end) < endT(end)
    beat_dur = [beat_dur; endT(end) - beats_in_time(end)];
end

beats = [beats_in_time, ones(size(beats_in_time)) * -1];
lab = [lab; beats];
lab = sortrows(lab);

labseg = [];
b_idx = 1;
if(lab(1,2) == -1 && lab(1,1) == 0)
    lab = lab(2:end,:); % remove duplicated 0 time
    labseg = labChordCid(1);
end
%%
for i = 2:length(lab)-1
    if lab(i,2) == -1 % if it is from beats
        b_idx = b_idx + 1; % current beat index
        
        % if next is also from beats or from ground truth but the same
        % chord label
        if (lab(i+1, 2) == -1 || lab(i+1, 2) == lab(i-1,2)) 
            lab(i,2) = lab(i-1,2);
        else
            dur_to_next_chord = lab(i+1,1) - lab(i,1);
            dur_to_next_beat = beat_dur(b_idx);
            
            if (dur_to_next_chord / dur_to_next_beat > tolerance)
                lab(i,2) = lab(i-1,2);
            end
        end
        labseg = [labseg; lab(i,2)];
    else % if from ground truth
        if lab(i-1,2) == -1 && lab(i+1,2) == -1 % ground truth time is in between beats.
            chord_dur_to_next_beat = lab(i+1,1) - lab(i,1);
            if (chord_dur_to_next_beat / dur_to_next_beat > tolerance)
                lab(i-1,2) = lab(i, 2);
                labseg(end) = lab(i-1,2);
            end
        end
    end
end

if lab(i+1, 2) == -1
    labseg = [labseg; lab(i,2)];
elseif labseg(end) == -1
    lab(i, 2) = lab(i+1, 2);
    labseg(end) = lab(i+1, 2);
end


