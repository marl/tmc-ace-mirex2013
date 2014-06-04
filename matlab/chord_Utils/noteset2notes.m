function notes = noteset2notes(noteset)

global inv_root_map_sharp inv_root_map_flat inv_degree_map inv_qualityMap inv_ext_degree_map;

if exist('inv_root_map_sharp', 'var') && isempty(inv_root_map_sharp)
    [inv_root_map_sharp, inv_root_map_flat, inv_degree_map, inv_qualityMap, inv_ext_degree_map] = inv_chordDic();
end

notes = [];
for i = 12:-1:1
    if bitget(noteset, i);
        notes = [notes {inv_root_map_flat(12-i)}];
    end
end

