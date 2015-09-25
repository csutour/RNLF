%EXAMPLE_NOISE_ESTIMATION ( script )
%   Estimate automatically the noise level function of a noisy
%   image.
%
%   References
%   ----------
%   Sutour, C., Deledalle, C.-A. & Aujol, J.-F. "Estimation of the
%   noise level function based on a non-parametric detection of
%   homogeneous image regions." SIAM Journal on Imaging Sciences
%   (in press)
%
%   License
%   -------
%   This work is protected by the CeCILL-C Licence, see
%   - Licence_CeCILL_V2.1-en.txt
%   - Licence_CeCILL_V2.1-fr.txt
%
%   See also NOISE_ESTIMATION.

%   Copyright 2015 Camille Sutour

clear all
close all

addpathrec('.')

% Load image
filename = 'data/lena.png';
img = double(imread(filename));

% Generate noisy image
[img_nse, noisegen] = noisegen(img, 'poly2', 20, 'prop', [0.2 0.5 0.3]);

% Estimate a 2nd order polynomial NLF
[noise, noise_info] = noise_estimation(img_nse);

% Show results
figure('Position', get(0, 'ScreenSize'));
subplot(1, 3, 1);
plotimage(img_nse, img, 'Noisy image');
subplot(1, 3, 2);
plothomogeneous(img_nse, noise_info.W, noise_info.hom, img)
subplot(1, 3, 3);
scatterplot(noise_info.stats.m, noise_info.stats.s, ...
            linspace(min(img(:)), max(img(:)), 100), ...
            noise.nlf, noisegen.nlf);
axis square;
legend('Stats', 'Estimated NLF', 'True NLF');
