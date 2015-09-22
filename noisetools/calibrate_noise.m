clear all
close all

addpath('..');
addpathrec('..');

img = double(imread('data/cameraman.png'));
strengh_list = logspace(log10(5), log10(200), 20);

for k = 1:length(strengh_list)
    strengh = strengh_list(k);

    n(k) = psnr(noisegen(img, 'gauss',    strengh), img);
    g(k) = psnr(noisegen(img, 'gamma',    strengh), img);
    p(k) = psnr(noisegen(img, 'poisson',  strengh), img);
    h(k) = psnr(noisegen(img, 'hybrid',   strengh, 'prop', [1 0.5 1]), img);
    o(k) = psnr(noisegen(img, 'poly2',    strengh, 'prop', [1 0.5 1]), img);
end

figure
hold all
plot(strengh_list, n);
plot(strengh_list, g);
plot(strengh_list, p);
plot(strengh_list, h);
plot(strengh_list, o);
legend('Gaussian', 'Gamma', 'Poisson', 'Hybrid', 'Poly2');

figure
subplot(2,5,1)
plotimage(noisegen(img, 'gauss', 10), img);
subplot(2,5,2)
plotimage(noisegen(img, 'gamma', 10), img);
subplot(2,5,3)
plotimage(noisegen(img, 'poisson', 10), img);
subplot(2,5,4)
plotimage(noisegen(img, 'hybrid', 10, 'prop', [1 0.5 1]), img);
subplot(2,5,5)
plotimage(noisegen(img, 'poly2', 10, 'prop', [1 0.5 1]), img);
subplot(2,5,6)
plotimage(noisegen(img, 'gauss', 200), img);
subplot(2,5,7)
plotimage(noisegen(img, 'gamma', 200), img);
subplot(2,5,8)
plotimage(noisegen(img, 'poisson', 200), img);
subplot(2,5,9)
plotimage(noisegen(img, 'hybrid', 200, 'prop', [1 0.5 1]), img);
subplot(2,5,10)
plotimage(noisegen(img, 'poly2', 200, 'prop', [1 0.5 1]), img);
linkaxes
