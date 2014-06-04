function extractFeaturesForList(fileList, output_dir)

band = 4;

addpath('./mp3readwrite');
addpath('./chord_Utils');
addpath('./ACR');
addpath('./MATLAB-Tempogram-Toolbox_1.0');

makedir(output_dir);

chordSet   = {'C:maj', 'C:min', 'C:7', 'C:min7', 'C:maj7', 'C:maj6', 'C:min6', 'C:sus4', 'C:dim', 'C:dim7', 'C:sus2', 'C:aug', 'C:hdim7', 'N'};

fprintf('Read fileList \n');
fid = fopen(fileList, 'r');
list = textscan(fid, '%s');
fclose(fid);

%% Extracting Features
fprintf('Extracting Features \n');
chordCounts = extractFeatures(list, output_dir, chordSet, band);
