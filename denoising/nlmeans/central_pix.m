%CENTRAL_PIX Internal function
%   Not documented
%
%   License
%   -------
%   This work is protected by the CeCILL-C Licence, see
%   - Licence_CeCILL_V2.1-en.txt
%   - Licence_CeCILL_V2.1-fr.txt

%   Copyright 2015 Camille Sutour and Charles Deledalle

function [m_criteria, s_criteria] = central_pix(img_sample, param)

p      = param.p;
ptemp  = param.p_temp;
shape  = param.shape;
noise  = param.noise;
blur   = param.blur;

% Build an homogeneous image in order to study the statistics
% of the criteria under hypothesis H0
[~, ~, T] = size(img_sample);
if T == 1
    x = mean(img_sample(:)) * ones(512,512);
else
    x = mean(img_sample(:)) * ones(64,64,min(T,64));
end
[M, N, T] = size(x);

% Build patch shape
patch_shape = zeros(M, N, T);
patch_shape = build_patch_shape(M, N, T, p, ptemp, shape);
patch_size  = sum(patch_shape(:));
if sum(patch_shape(patch_shape == 1)) ~= patch_size
    error('Current implementation works only for binary patches');
    return;
end

% Generate two noisy blurry images
img_nse1    = noisegen(x, noise);
img_nse2    = noisegen(x, noise);
img_nse1    = gaussfilter(img_nse1, blur);
img_nse2    = gaussfilter(img_nse2, blur);

% Extract all patches of the two noisy images
patch_nse1  = zeros(M*N*T, patch_size);
patch_nse2  = zeros(M*N*T, patch_size);
n = 1;
for k = -(p+1):(p+1)
    for l = -(p+1):(p+1)
        for t = -(ptemp+1):(ptemp+1)
            if patch_shape(mod(k, M) + 1, mod(l, N) + 1, mod(t, T) + 1) == 1
                patch_nse1(:, n) = reshape(circshift(img_nse1, [k, l, t]), [M*N*T, 1]);
                patch_nse2(:, n) = reshape(circshift(img_nse2, [k, l, t]), [M*N*T, 1]);
                n = n + 1;
            end
        end
    end
end

% Compute n times the criteria between randomly selected pairs of patches
d = criteria(patch_nse1, patch_nse2(randperm(M*N*T), :), noise);
d = mean(d, 2);

% Evaluate the two first statistics of the critria under H0
m_criteria = mean(d);
s_criteria = std(d);

% Clear tempory variables
clear img_nse1;
clear img_nse2;
clear patch_nse1;
clear patch_nse2;
