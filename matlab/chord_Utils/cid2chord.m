function chord = cid2chord(cid, option)

if nargin < 2
    option = 'flat';
end

if cid == 0
    chord = 'N';
    return
end

global inv_root_map_sharp inv_root_map_flat inv_degree_map inv_qualityMap inv_ext_degree_map;

if exist('inv_root_map_sharp', 'var') && isempty(inv_root_map_sharp)
    [inv_root_map_sharp, inv_root_map_flat, inv_degree_map, inv_qualityMap, inv_ext_degree_map] = inv_chordDic();
end

chord_struct = cid2chordStruct(cid);

chord = [];

if strcmp(option, 'flat')
    chord = inv_root_map_flat(chord_struct.root);
else
    chord = inv_root_map_sharp(chord_struct.root);
end

ext =[];

if isKey(inv_qualityMap, chord_struct.quality)
    chord = [chord ':' inv_qualityMap(chord_struct.quality)];
else
    chord = [chord ':'];
    for i = keys(inv_degree_map)
        if bitget(chord_struct.quality, 12-i{1})
            ext = [ext inv_degree_map(i{1}) ','];
        elseif i{1} == 0
            ext = [ext '*1,'];
        end
    end
end

for i = setdiff(cell2mat(keys(inv_degree_map)), cell2mat(keys(inv_ext_degree_map)))
    if bitget(chord_struct.ext, 12-i)
        ext = [ext inv_degree_map(i) ','];
    end
end

for i = keys(inv_ext_degree_map)
    if bitget(chord_struct.ext, 12-i{1})
        ext = [ext inv_ext_degree_map(i{1}) ','];
    end
end

if ~isempty(ext)
    chord = [chord '(' ext(1:end-1) ')'];
end

if  chord_struct.bass ~= chord_struct.root
    bass = rem(chord_struct.bass - chord_struct.root + 12, 12);
    if isKey(inv_degree_map, bass)
        chord = [chord '/' inv_degree_map(bass)];
    elseif isKey(inv_ext_degree_map, bass)
        chord = [chord '/' inv_ext_degree_map(bass)];
    else
        error(['unknown bass ' chord_struct.bass]);
    end
end

