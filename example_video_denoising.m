clear all
close all

addpathrec('.')

% Load video
filename = 'data/video.mat';
video = importdata(filename);

% Generate noisy video
[video_nse, noise] = noisegen(video, 'gauss', 20);

% Perform denoising
param.wait = waitbar(0, 'RNL denoising...');
video_rnl = rnl(video_nse, noise, param);
close(param.wait);

% Show results
figure('Position', get(0, 'ScreenSize'));
subplot(1, 3, 1);
h(1) = plotvideo(video, [], 'Original video');
subplot(1, 3, 2);
h(2) = plotvideo(video_nse, video, 'Noisy video');
subplot(1, 3, 3);
h(3) = plotvideo(video_rnl, video, 'RNL');
playvideo(h, 0.2);
