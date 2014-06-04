function doChordID(trainFileList, scratch, results)

addpath('./chord_Utils');
addpath('./ACR');
addpath('./MATLAB-Tempogram-Toolbox_1.0');

if nargin < 3
    results = scratch;
    gmm_path = sprintf('./pre-trained');
else
    gmm_path = sprintf('%s/model', scratch);
end

makedir(results);

k = 5;
reg = 1e-4;

gmmfile = sprintf('%s/chordModel_%d_%.e.mat', gmm_path, k, reg);
load(gmmfile);

band = size(gmm_set, 2);

chords = {};
for m = 1:length(chordSet)
    cs = cid2chordStruct(chord2cid(chordSet{m}));
    chords = [chords chordSet{m}];
    if cs.quality ~= 0
        for key = 1:11
            cs.bass = rem(cs.bass + 1, 12);
            cs.root = rem(cs.root + 1, 12);
            chords = [chords, cid2chord(chordStruct2cid(cs))];
        end
    end
end

Q = size(transmat,1);
model_map = containers.Map(chordSet, (1:length(chordSet)));
index_map = containers.Map(chords, 1:length(chords));

fprintf('Read trainFileList \n');
fid = fopen(trainFileList, 'r');
list = textscan(fid, '%s');
fclose(fid);
numSong = length(list{1});

count = 0;

for song = list{1}'
    tic
    count = count +1;
    fprintf('%s (%d/%d)\n', song{1}, count, numSong);
    [pathstr, name, ext] = fileparts(song{1});
    [chroma, beats_in_time, endT] = extractMultibandChroma(song{1}, band);
    
    fprintf(' -> Analyzing chords\n');
    
    w = 1/band;
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
    
    obslik = obslik.^w;
    
    cd = viterbi(ones(Q,1)/Q, transmat, obslik, opt_penalty);
    if beats_in_time(1) ~= 0
        beats_in_time = [0; beats_in_time];
        cd = [index_map('N') cd];
    end
    
    if beats_in_time(end) < endT
        beats_in_time = [beats_in_time; endT];
        cd = [cd index_map('N')];
    end
    
    idx = find(diff([-1 cd]) ~=0);
    cd = cd(idx);
    beats_in_time = [beats_in_time(idx); endT];
    
    file = [results filesep name ext '.txt'];
    fid = fopen(file, 'w');
    for i = 1:length(beats_in_time) - 1
        fprintf(fid,'%.3f\t%.3f\t%s\n', beats_in_time(i), beats_in_time(i+1), chords{cd(i)});
    end
    fclose(fid);
    toc
end

fprintf('Done\n');