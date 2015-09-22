function z = tv_primal_dual(A, noise, param)

% A : image to proceed
% N_iter : number of iterations
% lambda : regularization parameter
% theta in [0,1]

[n, m, t] = size(A);

% Retrieve parameters
lambda           = getoptions(param, 'lambda', [], 1);
W                = getoptions(param, 'W', ones(n, m, t));
N_iter           = getoptions(param, 'N_iter', 1000);
nsteps           = getoptions(param, 'nsteps', N_iter);

% Intern parameters
if t == 1
    sigma = 1/8^0.5;
    tau   = 1/8^0.5;
else
    alpha = 1.5; % Temporal regularization weight
    sigma = 1/(8+4*alpha^2)^0.5;
    tau   = 1/(8+4*alpha^2)^0.5;
end
theta = 1;

% Functionals and initialization according to noise
switch noise.type
  case 'gauss'
    prox_Fet = @(x) x./max(abs(x),1);
    prox_G   = @(u) (u+tau/(lambda*noise.sig^2).*W.*A)./(1+W*tau/(lambda*noise.sig^2));
    G        = @(C) (W.*(C-A).^2)/(2*noise.sig^2);
  case 'poisson'
    prox_Fet = @(x) x./max(abs(x),1);
    prox_G   = @(u) ...
        1/2*(u-tau/(lambda*noise.Q).*W+((u-tau/(lambda*noise.Q).*W).^2 ...
                                            +4*A*tau/(lambda*noise.Q).*W).^(1/2)).*(A>0)+...
        max(u-tau/(lambda*noise.Q).*W,0).*(A==0);
    G        = @(C) (W.*C - W.*A.*log(C))/noise.Q;
  case 'poly2'
    prox_Fet = @(x) x./max(abs(x),1);
    prox_G   = @(u) ...
        (u+tau./(lambda*noise.nlf(A)).*W.*A)./...
        (1+W.*tau./(lambda*noise.nlf(A)));
    G        = @(C) (W.*(C-A).^2)./(2*noise.nlf(A));
  otherwise
    error(['PD for ' noise ' noise non implemented']);
    return;
end

% Gradient functionnal
if t == 1
    wgrad = @grad;
    wdiv  = @div;
else
    WeightedField = @(x) cat(4, x(:,:,:,1:2), alpha * x(:,:,:,3));
    wgrad = @(x) WeightedField(grad(x));
    wdiv  = @(x) div(WeightedField(x));
end

% Initialization
z     = mean(A(:)) * ones(size(A));
x_old = z;
y     = wgrad(z);

k_iter = 1;
step = nsteps - N_iter;
while k_iter <= N_iter
    step = step + 1;

    if isfield(param, 'wait')
        waitbar(step / nsteps, param.wait);
    end

    y = prox_Fet(y + sigma * wgrad(z));
    x = prox_G(x_old + tau * wdiv(y));
    z = x + theta * (x - x_old);
    x_old = x;

    k_iter = k_iter + 1;
end
