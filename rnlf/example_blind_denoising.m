clear all
close all

addpathrec('.')

% Load video
filename = 'data/lena.png';
img = double(imread(filename));

% Generate noisy image
[img_nse, noisegen] = noisegen(img, 'hybrid', 20);

% Estimate a 2nd order polynomial NLF
[noise, noise_info] = noise_estimation(img_nse);

% Perform denoising
param.wait = waitbar(0, 'RNLF denoising...');
img_rnlf   = rnlf(img_nse, noise, param);
close(param.wait);

% Show results
figure
subplot(2, 2, 1);
plotimage(img_nse, img, 'Noisy image');
subplot(2, 2, 2);
plotimage(img_rnlf, img, 'RNLF');
subplot(2, 2, 3);
plothomogeneous(img_nse, noise_info.W, noise_info.hom, img)
subplot(2, 2, 4);
scatterplot(noise_info.stats.m, noise_info.stats.s, ...
            linspace(min(img(:)), max(img(:)), 100), ...
            noise.nlf, noisegen.nlf)
legend('Stats', 'Estimated NLF', 'True NLF');
