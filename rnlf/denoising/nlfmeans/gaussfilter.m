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
