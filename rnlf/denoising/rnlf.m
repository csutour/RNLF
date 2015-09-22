function [ima_res ima_weight] = rnlf(ima_nse, noise, param)

% Input
% img_nse : noisy image
% param : noise estimation and denoising parameters

% This is a simple implementation of RNL means (2D or 3D):
%
%   Sutour, C.; Deledalle, C.-A.; Aujol, J.-F.,
%   "Adaptive Regularization of the NL-Means: Application to Image and Video Denoising,"
%   Image Processing, IEEE Transactions on , vol.23, no.8, pp.3506,3521, Aug. 2014
%
% Author: Camille Sutour

[M, N, T] = size(ima_nse);

% Retrieve parameters
param.dejitter    = getoptions(param, 'dejitter', true);
param.renormalize = getoptions(param, 'renormalize', true);
if T==1
    param.w       = getoptions(param, 'w', 10);
    param.w_temp  = getoptions(param, 'w_temp', 0);
    param.lambda  = getoptions(param, 'lambda', 0.015);
else
    param.w       = getoptions(param, 'w', 4);
    param.w_temp  = getoptions(param, 'w_temp', 4);
    param.lambda  = getoptions(param, 'lambda', 0.0075);
end
switch noise.type
  case 'gamma'
    param.N_iter = getoptions(param, 'N_iter', 500);
  otherwise
    param.N_iter = getoptions(param, 'N_iter', 100);
end
param.nsteps = getoptions(param, 'nsteps', (2*param.w+1)^2 *(2*param.w_temp+1) + param.N_iter);

% Run NLmeans and TV
[ima_res, ima_weight] = nlmeans3d(ima_nse, noise, param);
param.W = ima_weight;
ima_res = tv(ima_res, noise, param);
