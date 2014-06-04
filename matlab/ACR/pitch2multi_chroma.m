function chroma = pitch2multi_chroma(pitch, band, logFactor)

if nargin < 3
    logFactor = 1000;
end

range = 28:99;

myGaussian = @(n, mu, theta) exp(-0.5*((n-mu)/theta).^2);

centers = zeros(band,1);

for i = 1:band  
    centers(i) = i*length(range)/(band+1);
end
    
if logFactor
    pitch = normcq(abs(pitch), 1);
    pitch = log(1 + pitch * logFactor);
else
    pitch = normcq(abs(pitch), -1);
end

mid = length(range)/2;
offset = 60 - mid;

theta = 15/((band+1)/2);

chroma = cell(band,1);

for b = 1:band
    c = centers(b) + offset;
    gwin = myGaussian(1:120, c, theta)';
    fpitch = bsxfun(@times, pitch, gwin);
    chroma{b} = chromaFold(fpitch);
end
