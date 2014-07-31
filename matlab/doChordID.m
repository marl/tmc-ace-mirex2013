function doChordID(fileList, features, model, results)
% Parameters
% ----------
% fileList: str
%   Audio file paths as strings in an array.
% features: str
%   Path to feature .mat files matching the given base filenames.
% model: str
%   Path to a directory to write out various model params.
% results: str
%   Path to a directory to write the resulting estimated labfiles.

addpath('./mp3readwrite');
addpath('./chord_Utils');
addpath('./ACR');
addpath('./MATLAB-Tempogram-Toolbox_1.0');

if nargin < 4
    results = model;
    gmm_path = sprintf('./pre-trained');
else
    gmm_path = sprintf('%s/model', model);
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

fprintf('Read fileList \n');
fid = fopen(fileList, 'r');
list = textscan(fid, '%s');
fclose(fid);
numSong = length(list{1});

count = 0;

for song = list{1}'
    tic
    count = count +1;
    fprintf('%s (%d/%d)\n', song{1}, count, numSong);
    [pathstr, name, ext] = fileparts(song{1});
    featureFileName = [features filesep name ext '.mat'];
    if exist(featureFileName, 'file')
        fprintf('-> Feature file exists, loading...');
        load(featureFileName);
    else
        [chroma, time_points, endT] = extractMultibandChroma(song{1}, band);

        labFile_name = [song{1} '.txt'];
        labseg = bs_lab2seg(labFile_name, time_points);

        save(featureFileName, 'chroma', 'time_points', 'labseg', 'endT');
    end

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
    if time_points(1) ~= 0
        time_points = [0; time_points];
        cd = [index_map('N') cd];
    end

    if time_points(end) < endT
        time_points = [time_points; endT];
        cd = [cd index_map('N')];
    end

    idx = find(diff([-1 cd]) ~=0);
    cd = cd(idx);
    time_points = [time_points(idx); endT];

    file = [results filesep name ext '.txt'];
    fid = fopen(file, 'w');
    for i = 1:length(time_points) - 1
        fprintf(fid,'%.3f\t%.3f\t%s\n', time_points(i), time_points(i+1), chords{cd(i)});
    end
    fclose(fid);
    toc
end

fprintf('Done\n');
