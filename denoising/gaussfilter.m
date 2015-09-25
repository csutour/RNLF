%GAUSSFILTER denoises an image
%   IMG_FIL = GAUSSFILTER(IMG_NSE, S) returns an image or video
%   contained in the 2 or 3D array IMG_NSE by a truncated Gaussain
%   convolution kernel of bandwidth S.
%
%   License
%   -------
%   This work is protected by the CeCILL-C Licence, see
%   - Licence_CeCILL_V2.1-en.txt
%   - Licence_CeCILL_V2.1-fr.txt
%
%   See also NLMEANS, RNL, TV.

%   Copyright 2015 Camille Sutour and Charles Deledalle

function img = gaussfilter(img, s)

[M, N, T] = size(img);

s = s * sqrt(2)/2;
cs = ceil(s);

cx = min(cs, floor(M/2));
cy = min(cs, floor(N/2));
cz = min(cs, floor(T/2));

[Y X Z] = meshgrid(-cx:cx, -cy:cy, -cz:cz);
disk = exp(-pi*(X.^2 + Y.^2 + Z.^2) / (s+1/2)^2);
kernel = disk / sum(disk(:));

kernel_zp = zeros(M, N, T);
kernel_zp(mod(-cx:cx, M) + 1, mod(-cy:cy, N) + 1, mod(-cz:cz, T) + 1) = kernel;
kernel_zp = conj(fftn(kernel_zp));
img = real(ifftn(fftn(img) .* kernel_zp));
