function cid = chordStruct2cid(chordStruct)

cid = chordStruct.root;
cid = bitshift(cid, 4, 'uint32') + chordStruct.bass;
cid = bitshift(cid, 12, 'uint32') + chordStruct.quality;
cid = bitshift(cid, 12, 'uint32') + chordStruct.ext;