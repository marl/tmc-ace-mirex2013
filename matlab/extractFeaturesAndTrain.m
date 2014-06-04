function extractFeaturesAndTrain(trainFileList, scratch)

band = 4;

addpath('./mp3readwrite');
addpath('./chord_Utils');
addpath('./ACR');
addpath('./MATLAB-Tempogram-Toolbox_1.0');

makedir(scratch);

chordSet   = {'C:maj', 'C:min', 'C:7', 'C:min7', 'C:maj7', 'C:maj6', 'C:min6', 'C:sus4', 'C:dim', 'C:dim7', 'C:sus2', 'C:aug', 'C:hdim7', 'N'};

fprintf('Read trainFileList \n');
fid = fopen(trainFileList, 'r');
list = textscan(fid, '%s');
fclose(fid);

%% Extracting Features

fprintf('Extracting Features \n');
chordCounts = extractFeatures(list, scratch, chordSet, band);

%% Generating Training Data

fprintf('Generating Training Data from the extracted features \n');
[tr_set, transmat] = genTrainingSet(list, scratch, chordCounts, chordSet, band);

%% Generating Chord Models
k = 5; % num Gaussians
reg = 1e-4; % regularization

fprintf('Generating Chord Models \n');

gmmfileDir = [scratch filesep 'model'];
gmm_name = sprintf('chordModel_%d_%.e.mat', k, reg);
gmmfile = [gmmfileDir filesep gmm_name];

gmm_set = cell(length(chordSet), band);
options = statset('Display','iter', 'MaxIter', 300); %, 'UseParallel', 'always');

for n = 1:length(chordSet)
    samplesize = size(tr_set{n, 1}, 2);
    if samplesize < 50
        error('Too small training data for %s chord', chordSet{n});
    end

    for b = 1:band
        fprintf('initialize %s chord model for %d band on %d samples\n', chordSet{n}, b, samplesize);
        IDX = kmeans(tr_set{n, b}',k,'Options',options, 'EmptyAction', 'singleton');
        fprintf('training %s chord model for %d band on %d samples\n', chordSet{n}, b, samplesize);
        gmm_set{n, b} = gmdistribution.fit(tr_set{n, b}',k,'Start', IDX, 'Regularize', reg, 'Options', options);
    end
end

makedir(gmmfileDir);
save(gmmfile, 'gmm_set', 'chordSet', 'transmat');

%% Optimize penalty

load(gmmfile);

fprintf('Optimizing Transition penalty \n');
opt_penalty = find_opt_penalty(list, scratch, gmmfile, 1, 'bi');

save(gmmfile, 'gmm_set', 'chordSet', 'transmat', 'opt_penalty');
