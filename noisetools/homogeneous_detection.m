function hom = homogeneous_detection(img, param)
% img : input (noisy) image
% W : block size

[M, N, T] = size(img);

% Retrieve arguments
W       = getoptions(param, 'W', 16);

alpha   = 0.60;
thresh  = 1 - alpha;
hom = zeros(M, N, T);
for t = 1:T
    I = img(:, :, t);

    [~, p1] = kendalltau(I, W, 0, 1);
    [~, p2] = kendalltau(I, W, 1, 0);
    [~, p3] = kendalltau(I, W, 1, 1);
    [~, p4] = kendalltau(I, W, -1, 1);

    p = cat(3, p1, p2, p3, p4);
    p = min(p, [], 3);

    % Decision: threshold based on pfa and threshold alpha
    hom(:, :, t) = thresh < p;
end
