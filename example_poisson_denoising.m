clear all
close all

addpathrec('.')

% Load video
filename = 'data/lena.png';
img = double(imread(filename));

% Generate noisy image
[img_nse, noise] = noisegen(img, 'poisson', 20);

% Perform denoising
param.wait = waitbar(0, 'RNL denoising...');
img_rnlf = rnlf(img_nse, noise, param);
close(param.wait);

% Show results
figure
subplot(1, 2, 1);
plotimage(img_nse, img, 'Noisy image');
subplot(1, 2, 2);
plotimage(img_rnlf, img, 'RNLF');

