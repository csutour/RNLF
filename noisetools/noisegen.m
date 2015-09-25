%NOISEGEN generator of noisy image
%   IMG_NSE = NOISEGEN(IMG, TYPE, ARGS) returns a generate
%   noisy image with a specific noise. IMG is a 2-D array
%   containing the noise-free pixel values. NOISE can be 'gauss',
%   'gamma', 'poisson', 'hybrid', or 'poly2'. Noise is zero-mean,
%   ie, E[IMG_NSE] = IMG. ARGS are mandatory arguments described
%   below.
%
%   [IMG_NSE, PARAM] = NOISEGEN(...) returns a description of the
%   nature of the generated noise in the structure PARAM containing
%   at least the following fields
%       PARAM.type   TYPE of noise,
%       PARAM.coefs  COEFS of the 2nd order polynomial of the nlf,
%       PARAM.nlf    handle function of the nlf.
%
%   NOISEGEN(IMG, TYPE, STRENGH, ...). STRENGH sets the level of
%   noise such that IMG_NSE has an approximative PSNR of
%       PSNR = 10 log10 255^2 / STRENGH^2.
%
%   NOISEGEN(IMG, 'gauss', 'sig', SIG) returns an image damaged by
%   Gaussian noise such that V[IMG_NSE|IMG] = SIG.
%
%   NOISEGEN(IMG, 'poisson', 'Q', Q) returns an image damaged by
%   Poisson noise such that V[IMG_NSE|IMG] = Q * IMG_NSE.
%
%   NOISEGEN(IMG, 'gamma', 'L', L) returns an image damaged by
%   gamma noise such that V[IMG_NSE|IMG] = IMG_NSE.^2 / L.
%
%   NOISEGEN(IMG, 'hybrid', 'prop', PROP, 'sig', SIG, 'Q', Q, 'L', L)
%   returns an image damaged by a sum of Gaussian, Poisson and
%   gamma noise where PROP are multiplicative factors and SIG, Q
%   and L are their respective parameters.
%
%   NOISEGEN(IMG, 'hybrid', STRENGH, 'prop', PROP) returns an
%   image damaged by a sum of Gaussian, Poisson and gamma noise
%   where PROP are multiplicative factors.
%
%   NOISEGEN(IMG, 'poly2', 'coefs', COEFS) returns an image
%   damaged by a Gaussian noise such that
%       V[IMG_NSE|IMG] = COEFS(3) IMG.^2 + COEFS(2) IMG + COEFS(1)
%
%   NOISEGEN(IMG, 'poly2', STRENGH, 'prop', PROP) returns an image
%   damaged by a Gaussian noise such that V[IMG_NSE|IMG] is
%   proportionnal to PROP(3) IMG.^2 + PROP(2) IMG + PROP(1).
%
%   NOISEGEN(IMG, PARAM) returns an image damaged by the noise
%   described in the structure PARAM.
%
%   Example:
%       img        = double(imread('lena.png'));
%       img_gauss  = noisegen(img, 'gauss', 20);
%       img_gamma  = noisegen(img, 'gamma', 'L', 20);
%       img_poiss  = noisegen(img, 'poisson', 'Q', 1);
%       img_hybrid = noisegen(img, 'poly2', 5, 'prop', [.8 .1 .1]);
%
%   License
%   -------
%   This work is protected by the CeCILL-C Licence, see
%   - Licence_CeCILL_V2.1-en.txt
%   - Licence_CeCILL_V2.1-fr.txt
%
%   See also NOISE_ESTIMATION.

%   Copyright 2015 Camille Sutour and Charles Deledalle


function [img_nse, param] = noisegen(img, varargin)

[M, N, T] = size(img);

% Retrieve arguments
if length(varargin) == 0
    error('Missing arguments');
else
    if ischar(varargin{1})
        param.type = varargin{1};
        varargin = varargin(2:end);
        if isnumeric(varargin{1})
            strengh = varargin{1};
            varargin = varargin(2:end);
        end
    elseif isstruct(varargin{1})
        param = varargin{1};
        varargin = varargin(2:end);
    else
        error('Wrong arguments');
    end
    for k = 1:2:length(varargin)
        if ischar(varargin{k})
            param = setfield(param, varargin{k}, varargin{k+1});
        else
            error('Wrong arguments');
        end
    end
end

% Generate noise and identify noise parameters
switch param.type
  case 'gauss'
    if exist('strengh', 'var')
        param.sig = strengh;
    elseif ~isfield(param, 'sig')
        error('Missing sig');
    end
    param.coefs = [param.sig^2 0 0];
    img_nse = img + param.sig * randn(M, N, T);
  case 'gamma'
    if exist('strengh', 'var')
        param.L = mean(img(:).^2) / strengh^2;
    elseif ~isfield(param, 'L')
        error('Missing L');
    end
    param.coefs = [0 0 1 / param.L];
    img_nse = mygamrnd(img, param.L);
  case 'poisson'
    if exist('strengh', 'var')
        param.Q = strengh^2 / mean(img(:));
    elseif ~isfield(param, 'Q')
        error('Missing Q');
    end
    param.coefs = [0 param.Q 0];
    img_nse = mypoissrnd(img, param.Q);
  case 'hybrid'
    if ~isfield(param, 'prop')
        param.prop = [1 1 1] / 3;
    end
    if exist('strengh', 'var')
        param.prop = param.prop / sum(param.prop);
        strengh = strengh * sqrt(1./sum(param.prop.^2));
        [n pn] = noisegen(img, 'gauss',   strengh);
        [p pp] = noisegen(img, 'poisson', strengh);
        [g pg] = noisegen(img, 'gamma',   strengh);
    else
        [n pn] = noisegen(img, 'gauss',   varargin{:});
        [p pp] = noisegen(img, 'poisson', varargin{:});
        [g pg] = noisegen(img, 'gamma',   varargin{:});
    end
    img_nse   = param.prop(1) * n + param.prop(2) * p + param.prop(3) * g;
    param.sig = pn.sig;
    param.Q   = pp.Q;
    param.L   = pg.L;
    param.coefs = ...
        param.prop(1)^2 * pn.coefs + ...
        param.prop(2)^2 * pp.coefs + ...
        param.prop(3)^2 * pg.coefs;
  case 'poly2'
    r = 1;
    if exist('strengh', 'var')
        if ~isfield(param, 'prop')
            error('Should provide prop');
        end
        r = (param.prop(3) * mean(img(:).^2) + ...
             param.prop(2) * mean(img(:)) + ...
             param.prop(1)) / strengh^2;
        param.coefs = param.prop / r;
    else
        if ~isfield(param, 'coefs')
            error('Should provide coefs');
        end
    end
    param.nlf = @(x) param.coefs(3) * x.^2 + param.coefs(2) * x + param.coefs(1);
    img_nse = img + sqrt(param.nlf(img)) .* randn(M, N, T);
  otherwise
    error(['Noise generation for ' param.type ' noise non implemented']);
    return;
end
param.nlf = @(x) param.coefs(3) * x.^2 + param.coefs(2) * x + param.coefs(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function img_nse = mygamrnd(img, L)

if L <= 0
    error('L should be postive');
    return
end
if min(img(:)) <= 0
    error('Image contains non-positive values');
    return
end
[M, N, T] = size(img);
[lic, ~] = license('checkout', 'Statistics_Toolbox');
if lic
    img_nse = gamrnd(L, img / L);
else
    img_nse = ahrens_dieter_gamrnd(L, img / L);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function img_nse = mypoissrnd(img, Q)

if Q <= 0
    error('Q should be postive');
    return
end
if min(img(:)) < 0
    error('Image contains negative values');
    return
end
[lic, ~] = license('checkout', 'Statistics_Toolbox');
if lic
    img_nse = Q * poissrnd(img / Q);
else
    img_nse = Q * knuth_poissrnd(img / Q);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function k = knuth_poissrnd(lambda)

[M,N,T] = size(lambda);

L = -lambda;
m = zeros(M, N, T);
p = zeros(M, N, T);
nonstop = ones(M, N, T);
while sum(nonstop(:)) > 0
    m = m + nonstop;
    u = rand(M, N, T);
    p = p + log(u);
    nonstop = nonstop & p > L;
end
k = m - 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function img_nse = ahrens_dieter_gamrnd(L, img)

[M, N, T] = size(img);
delta = L - floor(L);

nonstop = ones(M, N, T);
zeta = zeros(M, N, T);
eta = zeros(M, N, T);
while sum(nonstop(:)) > 0
    V3 = rand(M, N, T);
    V2 = rand(M, N, T);
    V1 = rand(M, N, T);
    v0 = exp(1) / (exp(1) + delta);
    idx1 = nonstop & V3 <= v0;
    idx2 = nonstop & V3 > v0;
    zeta(idx1) = V2(idx1).^(1 / delta);
    eta(idx1) = V1(idx1) .* zeta(idx1).^(delta-1);
    zeta(idx2) = 1 - log(V2(idx2));
    eta(idx2) = V1(idx2) .* exp(-zeta(idx2));
    nonstop = eta > zeta.^(delta-1) .* exp(-zeta);
end
img_nse = zeros(M, N, T);
for k = 1:floor(L)
    img_nse = img_nse + log(rand(M, N, T));
end
img_nse = img .* (zeta - img_nse);
