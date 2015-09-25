clear all
close all

addpathrec('.')

% Load image
filename = 'data/lena.png';
img = double(imread(filename));

% Generate noisy image
[img_nse, noise] = noisegen(img, 'gamma', 20);

% Perform denoising
param.wait = waitbar(0, 'RNL denoising...');
img_rnl = rnl(img_nse, noise, param);
close(param.wait);

% Show results
figure('Position', get(0, 'ScreenSize'));
subplot(1, 2, 1);
plotimage(img_nse, img, 'Noisy image');
subplot(1, 2, 2);
plotimage(img_rnl, img, 'RNL');
