function ncq = normcq(cq, option, zval, thresh)

if nargin < 3
    zval = 0;
end

if nargin < 4
    thresh = eps;
end

cq_mean = sum(abs(cq));
zero_idx = find(cq_mean < thresh);
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

if isempty(zval)
    ncq(:, zero_idx) = cq(zero_idx);
else
    ncq(:, zero_idx) = zval;
end