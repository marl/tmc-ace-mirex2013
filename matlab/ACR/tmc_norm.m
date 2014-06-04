function ncq = tmc_norm(cq, option)

[n,m] = size(cq);

ncq = zeros(n,m);
switch option
    case -2
        ncq = cq;
        return
    case -1
        ncq = cq ./ max(max(cq));
    case 0
        ncq = bsxfun(@rdivide, cq, max(cq));    
    otherwise
        for col = 1:m
            ncq(:,col) = cq(:,col) / norm(cq(:,col), option);
        end
end
