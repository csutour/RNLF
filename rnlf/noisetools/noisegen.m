function [img_nse, param] = noisegen(img, varargin)

% [img_nse, param] = noisegen(img, type, strengh)
%    Generate a noisy image 'img_nse' of with noise of type 'type',
%    such that E[img_nse] = img.
%    and its PSNR is 10 log10 255^2 / strengh^2.
%    'param' provides a description of the generated noise.
%
% img_nse = noisegen(img, 'gauss', 'sig', sig)
%    Set V[img_nse] = sig.
%
% img_nse = noisegen(img, 'gamma', 'L', L)
%    Set V[img_nse] = img_nse^2 / L.
%
% img_nse = noisegen(img, 'poisson', 'Q', Q)
%    Set V[img_nse] = Q * img_nse.
%
% img_nse = noisegen(img, 'hybrid', 'prop', prop, 'sig', sig, 'Q', Q, 'L', L)
%    Sum of Gaussian, Poisson and Gamma noise,
%    'prop' are multiplicative factors,
%    'sig', 'Q' and 'L' are the respective parameters.
%
% img_nse = noisegen(img, 'hybrid', strengh, 'prop', prop)
%    Sum of Gaussian, Poisson and Gamma noise,
%    'prop' are proportions,
%    The PSNR will be 10 log10 255^2 / strengh^2.
%
% img_nse = noisegen(img, 'poly2', 'coefs', coefs)
%    Gaussian noise with 2nd order polynomial,
%    'coefs' are the coefficients of the polynomial,
%
% img_nse = noisegen(img, 'poly2', strengh, 'prop', prop)
%    Gaussian noise with 2nd order polynomial,
%    'prop' are proportional to the coefficients of the polynomial,
%    The PSNR will be 10 log10 255^2 / strengh^2.
%
% [img_nse, param] = noisegen(img, param_noise)
%    Use the 'param_noise' stucture to generate noise


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
