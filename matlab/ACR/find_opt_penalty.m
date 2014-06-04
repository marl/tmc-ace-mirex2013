function opt_penalty = find_opt_penalty(list, scratch, gmmfile, penalty, T)

nFold = 3;
nSongs = size(list{1}, 1);
list = list{1}(randperm(nSongs));

nSongsPerFold = ceil(nSongs/3);
folds = cell(nFold,1);

for i=1:nFold
    sp = (i-1) * nSongsPerFold + 1;
    if i < nFold
        folds{i} = list(sp:sp + nSongsPerFold - 1);
    else
        folds{i} = list(sp:end);
    end
end


prev = crossval(folds, scratch, gmmfile, penalty-1, T);
next = crossval(folds, scratch, gmmfile, penalty, T);

direction = sign(next - prev);

if direction > 0
    prev_penalty = penalty;
    prev = next;
else
    prev_penalty = penalty-1;
end


while(1)
    next_penalty = prev_penalty + 1 * direction;
    next = crossval(folds, scratch, gmmfile, next_penalty, T);
    
    if next < prev
        fprintf('Optimal penalty is %d\n\n', -prev_penalty);
        opt_penalty = prev_penalty;
        break;
    end
    
    prev_penalty = next_penalty;
    prev = next;
end


