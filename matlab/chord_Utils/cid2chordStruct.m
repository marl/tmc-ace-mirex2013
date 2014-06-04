function chordStruct = cid2chordStruct(cid)

chordStruct.ext = bitand(cid,4095,'uint32');
cid = bitshift(cid,-12);
chordStruct.quality = bitand(cid,4095,'uint32');
cid = bitshift(cid,-12);
chordStruct.bass = bitand(cid,15,'uint32');
cid = bitshift(cid,-4);
chordStruct.root = cid;