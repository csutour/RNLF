function res = psnr(ima1, ima2)

res = 10 * log10(255^2 / mean((ima1(:) - ima2(:)).^2));
