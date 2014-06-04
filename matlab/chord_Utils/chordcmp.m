function result = chordcmp(chord1, chord2, option)

if nargin < 3
    option = 'quad+bass';
end

if chord2noteset(chord1,option) == chord2noteset(chord2, option)
    result = true;
else
    result = false;
end