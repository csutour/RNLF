function [noise, param] = noise_estimation(img_nse, param)

% Input
% img_nse : noisy image
% stat : statistics computed from homogeneous areas
% param.noise : noise model, if specified
% param.W : block size for homogeneous detection

[M, N, T] = size(img_nse);

% Retrieve arguments
if ~exist('param', 'var')
    param = {};
end
param.W          = getoptions(param, 'W', 16);
param.nlftype    = getoptions(param, 'nlftype', 'poly2');
param.auto       = getoptions(param, 'auto',   true);
param.refine     = getoptions(param, 'refine', false);
if ~isfield(param, 'hom') || param.refine
    param.hom = homogeneous_detection(img_nse, param);
end
W = param.W;
if ~isfield(param, 'stats') || param.refine
    if ~isfield(param, 'stats')
        param.stats.m = zeros(1, 0);
        param.stats.s = zeros(1, 0);
    end
    for t = 1:T
        for i = 1:W:(M-W+1)
            for j = 1:W:(N-W+1)
                if param.hom(i, j, t)
                    a = img_nse(mod(i+(1:W) - 2, M) + 1, ...
                                mod(j+(1:W) - 2, N) + 1, t);
                    param.stats.m(end+1) = mean(a(:));
                    param.stats.s(end+1) = std(a(:));
                end
            end
        end
    end
end

if ~check_stats(img_nse, param.stats.m)
    msg = ['Not enough homogeneous areas have been detected to ' ...
           'perform good estimation. Noise might be correlated or ' ...
           'the image resolution is too small. You could downsample ' ...
           'the image or reduce the window size.'];
    if ~param.auto || param.W < 6
        error(msg);
    else
        paramnew = param;
        paramnew.refine   = true;
        paramnew.W        = max(param.W - 2, 1);
        [noise, paramnew] = noise_estimation(img_nse, paramnew);
        if ~param.refine
            paramnew = rmfield(paramnew, 'refine');
            warning(sprintf('%s\nWindow size has been reduced from %d to %d', ...
                            msg, param.W, paramnew.W));
        end
        param = paramnew;
        return
    end
end

noise.type       = 'poly2';

% Estimation
[noise.nlf, noise.coefs] = nlf_estimation(param.stats.m, param.stats.s, ...
                                          param.nlftype, 'unprojected');

% Correction if negative variance
range  = linspace(min(img_nse(:)), max(img_nse(:)), 1000);
evalnlf = noise.nlf(range);
if sum(evalnlf < 0)
    [noise.nlf, noise.coefs] = nlf_estimation(param.stats.m, param.stats.s, ...
                                              param.nlftype, 'projected');
end

if ~param.refine
    param = rmfield(param, 'refine');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res = check_stats(img_nse, m)
% Check if there is enough statistics to cover the whole range of intensities

sol = 0;

n = length(img_nse(:));
s = sort(img_nse(:));

interval = s(round(linspace(1, n, 5+1)));
interval(end) = inf;
for k = 1:(length(interval)-1)
    q(k) = sum((interval(k) <= m) & (m < interval(k+1)));
end
res = min(q) >= 1;
