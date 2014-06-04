function noteset = cid2noteset(cid, option)

if nargin < 2
    option = 'quad+bass';
end

global inv_root_map_sharp inv_root_map_flat inv_degree_map inv_qualityMap inv_ext_degree_map;

if exist('inv_root_map_sharp', 'var') && isempty(inv_root_map_sharp)
    [inv_root_map_sharp, inv_root_map_flat, inv_degree_map, inv_qualityMap, inv_ext_degree_map] = inv_chordDic();
end


[option, bass] = regexp(option, '+', 'split');

chordStruct = cid2chordStruct(cid);
noteset = chordStruct.quality;

if ~isempty(bass)
    bass_pos = 12 - rem(chordStruct.bass - chordStruct.root + 12, 12);
    temp = bitset(noteset, bass_pos);
    if isKey(inv_qualityMap, temp)
        noteset = bitset(noteset, bass_pos);
    else
        chordStruct.ext = bitset(chordStruct.ext, bass_pos);
    end
end

switch option{1}
    case 'quad'
        noteset = bitor(noteset, bitand(chordStruct.ext, 3)); % '000000000011' seventh
    case 'triad'
        count = 0;
        noteset_copy = noteset;
        
        % count bits
        while noteset_copy
            noteset_copy = bitand(noteset_copy, noteset_copy -1, 'uint32');
            count = count + 1;
        end
        
        while count > 3
            noteset = bitand(noteset, noteset -1, 'uint32');
            count = count - 1;
        end
        
    case 'full'
        noteset = bitor(noteset, chordStruct.ext, 'uint32');
    otherwise
        error(['there is no option for ' option]);
end

noteset = trans(noteset, chordStruct.root);

function T = trans(orig, tr)
    T = bitshift(orig, 12-tr, 'uint32');
    T = bitand(bitshift(T, -12, 'uint32'), 4095, 'uint32') + bitand(T, 4095, 'uint32');

