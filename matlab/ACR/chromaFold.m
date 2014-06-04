function chromagram = chromaFold(pitchSpec, varargin)
%
% chromagram = chromaFold(pitchSpec, varargin)
% 

[minNote, maxNote, bpo] = ...
    process_options(varargin, 'minNote', 21, 'maxNote', 108, 'bpo', 12);

[n, seg_num] = size(pitchSpec);
if n == 120
    blankSpec = pitchSpec;
else
    blankSpec = zeros(120, seg_num);
    blankSpec(minNote:maxNote, :) = pitchSpec((minNote:maxNote)-20,:);
end
chromagram = zeros(bpo, seg_num);
for p=1:120
    chroma = mod(p, bpo)+1;
    chromagram(chroma,:) = chromagram(chroma,:) + blankSpec(p,:);
end