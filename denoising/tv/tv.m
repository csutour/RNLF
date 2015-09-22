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