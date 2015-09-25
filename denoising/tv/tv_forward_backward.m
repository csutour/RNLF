function C = tv_forward_backward(A, noise, param)

[n, m, t] = size(A);

% Retrieve parameters
lambda           = getoptions(param, 'lambda', [], 1);
gamma            = getoptions(param, 'gamma', 0.001);
tau              = getoptions(param, 'tau', 1/8);
W                = getoptions(param, 'W', ones(n, m, t));
N_iter           = getoptions(param, 'N_iter', 1000);
nsteps           = getoptions(param, 'nsteps', N_iter);

% Functionnal definitions
switch noise.type
  case 'gamma'
    G  = @(C) noise.L*(W.*log(C) +  W.*A./C);
    dG = @(C) noise.L*(W./C - W.*A./(C.^2));
  otherwise
    error(['FB for ' noise ' noise non implemented']);
    return;
end
a = min(A(:));
b = max(A(:));
x = A;

% Gradient functionnal
if t == 1
    wgrad = @grad;
    wdiv  = @div;
else
    alpha = 1.5; % Temporal regularization weight
    WeightedField = @(x) cat(4, x(:,:,:,1:2), alpha * x(:,:,:,3));
    wgrad = @(x) WeightedField(grad(x));
    wdiv  = @(x) div(WeightedField(x));
end

% Initialization
y = x;
t = 1;
nrj = 0;

% Main loop
k_iter=1;
step = nsteps - N_iter;
while k_iter <= N_iter
    step = step+1;

    if isfield(param, 'wait')
        waitbar(step / nsteps, param.wait);
    end

    x_old = x;

    % Forward step
    x = y - gamma / lambda * dG(y);

    % Backward step
    x = TV_FISTA_bornes(x, gamma, 20, tau, a, b, wgrad, wdiv);
    t = (1 + sqrt(1 + 4 * t^2)) / 2;
    y = x + (t - 1) / t * (x - x_old);
    y = max(y, a);
    y = min(y, b);

    k_iter = k_iter + 1;
end
C = y;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = TV_FISTA_bornes(f, mu, itmax, tau, a, b, wgrad, wdiv)

% Initialization
[m,n] = size(f);
y     = zeros(m, n);
u     = wgrad(y);
yold  = y;
y     = f;
uold  = u;
t = 1;

% Iterations
for it = 1:itmax
  z = f - mu * wdiv(u);

  z=max(z,a);
  z=min(z,b);

  v = proj_L2(u - tau * wgrad(z) / mu);

  t     = (1 + sqrt(1 + 4*t^2)) /2;
  u     = v + (t-1) * (v - uold) / t;
  uold  = u;
end;
y = f - mu * wdiv(v);
y = max(y,a);
y = min(y,b);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g = proj_L2(f)
% Projection of f on the unit ball of R^2

n  = ndims(f);
s  = size(f);
A  = repmat(sqrt(sum(f.^2, n)), [ones(1, n-1) s(n)]);
B  = max(A, 1);
g  = f ./ B;

