function [values, pidx] = fpeaks(x)
%
% Find local maxima
%
% [values, pidx] = fpeaks(x)finds local maxima or peaks values in the input
% 'x'. 'x' must be a row or column vector with real-valued elements and
% have a minimum length of three. findpeaks compares each element of x
% to its neighboring values. If an element of data is larger than both of
% its neighbors, it is a local peak. 
% If there is flat top peak (e.g. [ 1 2 3 3 3 2 1 ]), the center of the top
% is assumed as a peak.
%
% by Taemin Cho (tmc323@nyu.edu) 5/17/2012
%

dx = diff(x);
signs = sign(dx);


pidx = [];

midx_flag = 0;
for i = 1:length(signs)-1
    cp = signs(i);
    np = signs(i+1);
    
    % peaks
    if cp == 1 && np == -1
        pidx = [pidx i];
    end
    
    % left peaks
    if cp == 1 && np == 0
        lidx = i;
        midx_flag = true;
    end
    
    % right peaks
    
    if cp == 0 && np == -1
        if midx_flag
            midx_flag = false;
            pidx = [pidx i-round((i - lidx)/2)];
        end
    end
end

pidx = pidx + 1;

values = x(pidx);