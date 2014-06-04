function T = noteset_trans(orig, tr)

tr = rem(tr, 12);
if tr < 0; tr = 12 + tr; end
T = bitshift(orig, 12-tr, 'uint32');
T = bitand(bitshift(T, -12, 'uint32'), 4095, 'uint32') + bitand(T, 4095, 'uint32');