%TV denoises an image
%   IMG_FIL = TV(IMG_NSE, NOISE) returns a denoised image or
%   video contained in the 2 or 3D array IMG_NSE using the noise
%   information contains in the structure NOISE (as provided by
%   NOISEGEN) using the method described in references [1].
%
%   TV(IMA_NSE, NOISE, PARAM) fields in the structure PARAM
%   override the default parameters as follow
%       PARAM.lambda     TV filtering parameter
%                        (default 0.075 in 2D, 0.0375 in 3D)
%       PARAM.N_iter     number of iterations of TV
%                        (default 1000)
%       PARAM.wait       not described yet.
%
%   References
%   ----------
%   [1] To complete
%
%   License
%   -------
%   This work is protected by the CeCILL-C Licence, see
%   - Licence_CeCILL_V2.1-en.txt
%   - Licence_CeCILL_V2.1-fr.txt
%
%   See also NLMEANS, RNL.

%   Copyright 2015 Camille Sutour

function img_fil = tv(img_nse, noise, param)

[M, N, T] = size(img_nse);

if T==1
    param.lambda = getoptions(param, 'lambda', 0.075);
else
    param.lambda = getoptions(param, 'lambda', 0.0375);
end

switch noise.type
  case { 'gauss', 'poisson', 'hybrid', 'poly2' }
    img_fil = tv_primal_dual(img_nse, noise, param);
  case { 'gamma' }
    img_fil = tv_forward_backward(img_nse, noise, param);
  otherwise
    error(['TV for ' noise ' noise non implemented']);
    return;
end