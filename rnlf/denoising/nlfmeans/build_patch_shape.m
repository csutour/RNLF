function patch_shape = build_patch_shape(M, N, T, hP, ht, shape)

[X, Y, P] = meshgridperiodic(M, N, T);
switch shape
  case 'circular'
    patch_shape = (Y.^2 + X.^2 <= (hP+0.5).^2) & (P <= ht);
  case 'square'
    patch_shape = (abs(Y) <= hP & abs(X) <= hP) & (abs(P) <= ht);
  case 'gaussian'
    patch_shape = (exp(-(Y.^2 + X.^2) / (0.6*hP.^2))) & (abs(P) <= ht);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [X, Y, Z] = meshgridperiodic(M, N, T)

if ~exist('N', 'var')
    N = 1;
end
if ~exist('T', 'var')
    T = 1;
end
[Y, X, Z] = meshgrid(min((1:N)-1, N+1-(1:N)), ...
                     min((1:M)-1, M+1-(1:M)), ...
                     min((1:T)-1, T+1-(1:T)));
