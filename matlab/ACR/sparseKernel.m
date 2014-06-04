function sparKernel= sparseKernel(fmin, fmax, bpo, fs, win)
% SPARSEKERNEL Generate Sparse Kernels for performing a fast Constant Q transform.
%
%   SPARSEKERNEL(fmin, fmax, bpo, Fs, thresh)
%
%   fmin = frequency of bottom bin
%   fmax = top frequency
%   bpo  = bins per octave
%   Fs   = sampling frequency
%   thresh = threshold
%   win  = analysis window size
%
%
% by Taemin Cho (tmc323@nyu.edu) 5/6/2012
%

if nargin < 5, win = Inf; end

thresh= 0.0054;    % for Hamming window

Q= 1/(2^(1/bpo)-1);                                                  
K= ceil( bpo * log2(fmax/fmin) );
maxCenterFq = (fmin * 2^((K-1)/bpo));
if maxCenterFq < fmax - 1e-3
    K = K +1;
end

fftLen= 2^nextpow2( ceil(Q*fs/fmin) );  
sparKernel= []; 
for k= K:-1:1; 
   len = ceil( Q * fs / (fmin*2^((k-1)/bpo)) );
   tempKernel= zeros(fftLen, 1);
   sp = ceil((fftLen - len)/2);
   
   if len > win
       N = win;
   else
       N = len;
   end
   
   tempKernel(sp:sp+len-1)= hamming(len)/N .* exp(2*pi*1i*Q*(0:len-1)'/len);
   specKernel= fft(tempKernel);
   specKernel(abs(specKernel)<=thresh) = 0; 
   sparKernel= sparse([specKernel sparKernel]); 
end 
sparKernel= conj(sparKernel) / fftLen;
