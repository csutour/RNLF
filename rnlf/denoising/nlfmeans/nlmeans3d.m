function [ima_fil, sum_w] = nlmeans3d(ima_nse, noise, param)

% 3d for temporal NL-means :
% 3d search window and/or patch

% This is a simple implementation of NL means (2D or 3D):
%
%   Buades, A. and Coll, B. and Morel, J.M.,
%   Computer Vision and Pattern Recognition, 2005. CVPR
%
% with possibility of defittering as described in:
%
%   Sutour, C.; Deledalle, C.-A.; Aujol, J.-F.,
%   "Adaptive Regularization of the NL-Means: Application to Image and Video Denoising,"
%   Image Processing, IEEE Transactions on , vol.23, no.8, pp.3506,3521, Aug. 2014
%
% It uses the fast FFT-based algorithm as described in:
%
%   Charles-Alban Deledalle, Vincent Duval and Joseph Salmon,
%   "Non-Local Methods with Shape-Adaptive Patches (NLM-SAP)",
%   Journal of Mathematical Imaging and Vision, pp. 1-18, 2011
%
% Author: Camille Sutour, Charles Deledalle

% ima_nse : 3dimensional (time)
% hW : search zone (spatial)
% hT : search zone(temporal)
% hP : patchs size (spatial)
% ht : patch size (temporal)
% tau : filter parameter

[M, N, T]   = size(ima_nse);

% Retrieve parameters
if T==1
    hW      = getoptions(param, 'w', 10);
    hT      = getoptions(param, 'w_temp', 0);
    ht      = getoptions(param, 'p_temp', 0);
else
    hW      = getoptions(param, 'w', 4);
    hT      = getoptions(param, 'w_temp', 4);
    ht      = getoptions(param, 'p_temp', 2);
end
hP          = getoptions(param, 'p', 3);
nsteps      = getoptions(param, 'nsteps', (2*hW+1)^2 *(2*hT+1));

% FIXME name 'search' is not appropriate
shape       = getoptions(param, 'search', 'circular'); % Define shape of patches
blur        = getoptions(param, 'blur', 1);            % Patch blurring (0 = no blur)
tau         = getoptions(param, 'tau', 1);             % Filtering parameter for exponential weights
block       = getoptions(param, 'block', true);        % Perform blockwise nlmeans
dejitter    = getoptions(param, 'dejitter', false);    % Perform dejiterring
renormalize = getoptions(param, 'renormalize', false); % Perform renormalization

m_criteria  = getoptions(param, 'm_criteria', []);     % Expectation of the criteria under H0
s_criteria  = getoptions(param, 's_criteria', []);     % Standard deviation of the criteria under H0

if isempty(m_criteria) || isempty(s_criteria)
    param.p = hP;
    param.p_temp = ht;
    param.search = shape;
    param.noise = noise;
    param.blur = blur;
    [m_criteria, s_criteria] = central_pix(ima_nse, param);
end

% Define a patch shape in the fourier domain
patch_shape = build_patch_shape(M, N, T, hP, ht, shape);
patch_size  = sum(patch_shape(:));
patch_shape = patch_shape / patch_size;
patch_shape = conj(fftn(patch_shape));

% Prefilter noisy image to improve robustness
ima_cmp = gaussfilter(ima_nse, blur);

% Main loop
sum_w = zeros(M, N, T);
sum_w2 = zeros(M, N, T);
sum_wI = zeros(M, N, T);
if dejitter
    sum_wI2 = zeros(M, N, T);
end
hT = min(hT,T);

step = 0;
for dx = -hW:hW
    for dy = -hW:hW
        for dz = -hT:hT
            step = step + 1;

            if isfield(param, 'wait')
                waitbar(step / nsteps, param.wait);
            end

            % Restrict the search window to be circular
            % and avoid the central pixel
            if (dx == 0 && dy == 0 && dz == 0) || dx^2 + dy^2 > (hW+0.5)^2
                continue
            end
            x2range = mod((1:M) + dx - 1, M) + 1;
            y2range = mod((1:N) + dy - 1, N) + 1;
            z2range = mod((1:T) + dz - 1, T) + 1;

            % Calculate the Euclidean distance between all pair of
            % patches in the direction (dx,dy,dz)
            diff = criteria(ima_cmp, ima_cmp(x2range, y2range, z2range), noise);
            diff = real(ifftn((patch_shape .* fftn(diff))));

            % Convert the distance to weights using an exponential
            % kernel (this is a critical step!)
            w = exp(-abs(diff - m_criteria)/ (s_criteria * tau^2));

            % Perform blockwise nlmeans
            if block
                w = real(ifftn((patch_size * patch_shape .* fftn(w))));
            end

            % Increment accumulators for the weighted average
            sum_w = sum_w + w;
            sum_w2 = sum_w2 + w.^2;
            sum_wI = sum_wI + w .* ima_nse(x2range, y2range, z2range);
            if dejitter
                sum_wI2 = sum_wI2 + w .* ima_nse(x2range, y2range, z2range).^2;
            end
        end
    end
end

% For the central weight we follow the idea of:
%   "On two parameters for denoising with Non-Local Means"
%   J. Salmon, IEEE Signal Process. Lett., 2010
w_center = 1;
sum_w = sum_w + w_center;
sum_w2 = sum_w2 + w_center.^2;
sum_wI = sum_wI + w_center * ima_nse;
if dejitter
    sum_wI2 = sum_wI2 + w_center * ima_nse.^2;
end

% Weighted average
ima_fil = sum_wI ./ sum_w;

% Perform defittering
if dejitter
    ima_var = sum_wI2 ./ sum_w - ima_fil.^2;
    ima_var_predict = noise.nlf(ima_fil);
    ima_var_x = abs(ima_var - ima_var_predict);
    alpha = ima_var_x ./ (ima_var_x + ima_var_predict);
    ima_fil = (1-alpha) .* ima_fil + alpha .* ima_nse;
    if ~renormalize
        sum_w = (1 - alpha) .* sum_w + alpha;
    end
end

% Renormalize the sum of weights as the inverse square root of
% the variance reduction
if renormalize
   ima_nbpixels = sum_w.^2 ./ sum_w2;
   if param.dejitter
        ima_nbpixels = ima_nbpixels ./ ...
            ((1-alpha).^2 + ...
             ((alpha.^2 + ...
              2 * alpha .* (1 - alpha) ./ sum_w) .* ima_nbpixels));
   end
   sum_w = (ima_nbpixels).^(1/2);
end
