function cid = chord2cid(chord)

% cid is 32 bit integer 1-4 bits for root, 5-8 bits for bass, 9-20 bits for
% quality, 21-32 bits for extensions(tension)
global root_map  degree_map  qualityMap  convertMap;

if exist('root_map', 'var') && isempty(root_map)
    [root_map,  degree_map,  qualityMap,  convertMap] = chordDic();
end

chord = regexp(chord, '[^ \f\n\r\t\v.;]*', 'match');
chord = [chord{:}]; %remove white space

bass = regexp(chord, '\/', 'split');

if length(bass) > 1
    chord = bass{1};
    bass = bass{end};
else
    bass = [];
end

quality = regexp(chord, '\:', 'split');
if length(quality) > 1
    chord = quality{1};
    quality = quality{end};
else
    quality = [];
end
root = chord;

rbits = 0;
for r = root
    switch r
        case '#'
            rbits = rbits +1;
            rbits = mod(rbits, 12);
        case 'b'
            rbits = rbits -1;
            rbits = mod(rbits+12, 12);
        case 'N'
            cid = 0;
            return;
        otherwise
            if isKey(root_map, r)
                rbits = root_map(r);
            else
                error('chord2cid:err', root);
            end
    end
end

bbits = 0;
if ~isempty(bass)
    [degree, acc] = regexp(bass, '[1-9]*', 'match', 'split');
    if isKey(degree_map, degree{1})
        bbits = bbits + degree_map(degree{1});
    else
        error('chord2cid:err', ['bass:' bass]);
    end
    
    if strcmp(acc{2}, '') ~=1
        error('chord2cid:err', ['bass:' bass]);
    end
    
    for a = acc{1}
        switch a
            case '#'
                bbits = bbits +1;
            case 'b'
                bbits = bbits -1;
            otherwise
                error('chord2cid:err', ['bass:' bass]);
        end
    end
    bbits = mod(bbits+rbits+12, 12);
else
    bbits = rbits;
end

qbits = 0;
ebits = 0;

if isempty(quality)
    qbits = qualityMap('maj'); % maj triad
elseif strcmp(quality(1), '(') % intervalic expression
    [Q, ~] = regexp(quality, '([\w#*]*)', 'match', 'split');
    
    qbits = bitset(qbits, 12); %set root
    
    for i=1:length(Q)
        pos = 0;
        [degree, acc] = regexp(Q{i}, '[1-9]*', 'match', 'split');
        if isKey(degree_map, degree{1})
            pos = pos + degree_map(degree{1});
        else
            error('chord2cid:err', ['quality:' quality]);
        end
        
        if strcmp(acc{2}, '') ~=1
            error('chord2cid:err', ['quality:' quality]);
        end
        
        bitval = 1;
        for a = acc{1}
            switch a
                case '#'
                    pos = pos +1;
                case 'b'
                    pos = pos -1;
                case '*'
                    bitval = 0;
                otherwise
                    error('chord2cid:err', ['quality:' quality]);
            end
        end
        pos = mod(pos+12, 12);
        
        if str2double(degree) < 9
            qbits = bitset(qbits, 12-pos, bitval);
        else
            ebits = bitset(ebits, 12-pos, bitval);
        end
    end
    
    if bitor(bitget(qbits, 12-3), bitget(qbits, 12-4)) % if exist 3rd
        ebits = bitset(ebits, 12-5, bitor(bitget(qbits, 12-5), bitget(ebits, 12-5))); % 4 to 11
        ebits = bitset(ebits, 12-2, bitor(bitget(qbits, 12-2), bitget(ebits, 12-2))); % 2 to 9
        qbits = bitset(qbits, 12-5, 0);
        qbits = bitset(qbits, 12-2, 0);
    end
else
    [Q, ~] = regexp(quality, '([\w#*]*)', 'match', 'split');
    if isKey(convertMap, Q{1})
        [q, ~] = regexp(convertMap(Q{1}), '([\w#*]*)', 'match', 'split');
        Q(1) = q(1);
        Q = {Q{:}, q{2:end}};
    end
    
    if isKey(qualityMap, Q{1})
        qbits = qualityMap(Q{1});
    else
        error('chord2cid:err', ['quality:' quality]);
    end

    % extensions
    for i=2:length(Q)
        pos = 0;
        [degree, acc] = regexp(Q{i}, '[1-9]*', 'match', 'split');
        if isKey(degree_map, degree{1})
            pos = pos + degree_map(degree{1});
        else
            error('chord2cid:err', ['quality:' quality]);
        end
        
        if strcmp(acc{2}, '') ~=1
            error('chord2cid:err', ['quality:' quality]);
        end
        
        bitval = 1;
        for a = acc{1}
            switch a
                case '#'
                    pos = pos +1;
                case 'b'
                    pos = pos -1;
                case '*'
                    bitval = 0;
                otherwise
                    error('chord2cid:err', ['quality:' quality]);
            end
        end
        pos = mod(pos+12, 12);
        
        if bitval == 0 
            qbits = bitset(qbits, 12-pos, bitval);
%         elseif str2double(degree) == 7
%             qbits = bitset(qbits, 12-pos, bitval);
        else
            ebits = bitset(ebits, 12-pos, bitval);
        end
    end
end

cid = rbits;
cid = bitshift(cid, 4, 'uint32') + bbits;
cid = bitshift(cid, 12, 'uint32') + qbits;
cid = bitshift(cid, 12, 'uint32') + ebits;















