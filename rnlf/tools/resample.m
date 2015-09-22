function img = resample(img, Mnew, Nnew)

[M, N, T] = size(img);
fimg = fft2(img);
fimg(end+1, :, :) = 0;
fimg(:, end+1, :) = 0;
hM = min(M / 2, Mnew / 2);
if hM == floor(hM)
    hMn = hM - 1;
    hMp = hM;
else
    hMn = floor(hM);
    hMp = floor(hM);
end
hN = min(N / 2, Nnew / 2);
if hN == floor(hN)
    hNn = hN - 1;
    hNp = hN;
else
    hNn = floor(hN);
    hNp = floor(hN);
end
fimg = fimg(   [1:(hMp+1) (M+1)*ones(1,max(Mnew-M,0)) (M-hMn+1):M], :, :);
fimg = fimg(:, [1:(hNp+1) (N+1)*ones(1,max(Nnew-N,0)) (N-hNn+1):N], :);
img = real(ifft2(fimg));
