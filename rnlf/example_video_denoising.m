clear all
close all

addpathrec('.')

% Load video
filename = 'data/ref_short.mat';
img = importdata(filename);

% Generate noisy video
[img_nse, noise] = noisegen(img, 'gauss', 20);

% Perform denoising
param.wait = waitbar(0, 'RNL denoising...');
img_rnlf = rnlf(img_nse, noise, param);
close(param.wait);

% Show results
dispvideo(img_rnlf,img_nse,img);

