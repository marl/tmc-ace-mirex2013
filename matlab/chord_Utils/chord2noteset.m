function noteset = chord2noteset(chord, option)

if nargin < 2
    option = 'quad+bass';
end

cid = chord2cid(chord);
noteset = cid2noteset(cid, option);