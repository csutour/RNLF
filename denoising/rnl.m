%RNL denoise an image
%   IMG_FIL = RNL(IMG_NSE, NOISE) returns a denoised image or
%   video contained in the 2 or 3D array IMG_NSE using the noise
%   information contains in the structure NOISE (as provided by
%   NOISEGEN) using the method described in references [1].
%
%   [IMA_FIL, IMA_REDUCTION] = RNL(IMA_NSE, NOISE) returns an
%   approximation of the local reduction of the noise standard
%   deviation in the 2 or 3D-array IMG_REDUCTION before
%   regularization.
%
%   RNL(IMA_NSE, NOISE, PARAM) fields in the structure PARAM
%   override the default parameters as follow
%       PARAM.w          radius of spatial circular search windows
%                        (default 10 in 2D, 4 in 3D)
%       PARAM.w_temp     radius of temporal circular search windows
%                        (default 0 in 2D, 4 in 3D)
%       PARAM.p          radius of spatial patches
%                        (default 3)
%       PARAM.p_temp     radius of temporal patches
%                        (default 0 in 2D, 2 in 3D)
%       PARAM.shape      shape of patches (default 'circular')
%       PARAM.tau        non-local filtering parameter (default 1)
%       PARAM.blur       bandwidth of patch prefiltering (default 1)
%       PARAM.block      boolean for block reprojection (see [1])
%                        (default true)
%       PARAM.dejitter   boolean for dejittering (see [3])
%                        (default true)
%       PARAM.lambda     TV filtering parameter
%                        (default 0.015 in 2D, 0.0075 in 3D)
%       PARAM.N_iter     number of iterations of TV
%                        (default 100 except 500 for gamma noise)
%       PARAM.wait       not described yet.
%
%   References
%   ----------
%   [1] Sutour, C.; Deledalle, C.-A.; Aujol, J.-F., "Adaptive
%   Regularization of the NL-Means: Application to Image and Video
%   Denoising," Image Processing, IEEE Transactions on , vol.23,
%   no.8, pp.3506,3521, Aug. 2014
%
%   License
%   -------
%   This work is protected by the CeCILL-C Licence, see
%   - Licence_CeCILL_V2.1-en.txt
%   - Licence_CeCILL_V2.1-fr.txt
%
%   See also NLMEANS, TV.

%   Copyright 2015 Camille Sutour

function [ima_res ima_reduction] = rnl(ima_nse, noise, param)

[M, N, T] = size(ima_nse);

% Retrieve parameters
param.dejitter    = getoptions(param, 'dejitter', true);
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
[ima_res, ima_reduction] = nlmeans(ima_nse, noise, param);
param.W = ima_reduction;
ima_res = tv(ima_res, noise, param);
