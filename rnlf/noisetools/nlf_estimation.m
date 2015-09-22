function [nlf, coefs] = nlf_estimation(m, s, nlftype, method)

if ~exist('nlftype', 'var');
    nlftype = 'poly2';
end
if ~exist('method', 'var');
    method = 'unprojected';
end

s(m==0) = [];
m(m==0) = [];

Niter = 5000;

b = (s.^2)';
switch nlftype
  case 'constant'
    A = ones(size(m))';
    getcoefs = @(coefs) [ coefs 0 0 ];
  case 'linear'
    A = m';
    getcoefs = @(coefs) [ 0 coefs 0 ];
  case 'quadratic'
    A = (m.^2)';
    getcoefs = @(coefs) [ 0 0 coefs ];
  case 'affine'
    Niter = 10000;
    A     = [ones(size(m)); m]';
    getcoefs = @(coefs) [ coefs 0 ];
  case 'poly2'
    Niter = 10000;
    A     = [ones(size(m)); m; m.^2]';
    getcoefs = @(coefs) coefs;
  otherwise
    error(['Unknown nlf type ' nlftype]);
end

mb = mean(b(:));
b = b / mb;
mA = diag(mean(A, 1));
A = A * inv(mA);
switch method
  case 'unprojected'
    coefs = unprojected_primal_dual_L1(A, b, Niter);
  case 'projected'
    coefs = primal_dual_L1(A, b, Niter);
  otherwise
    error(['Unknown method ' method]);
end
coefs = getcoefs(inv(mA) * coefs * mb);
nlf = @(x) coefs(3) * x.^2 + coefs(2) * x + coefs(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = unprojected_primal_dual_L1(A,b,Niter)

% Solve min_x ||Ax-b||_1

% Parameters
proxFet = @(p) p./max(abs(p),1);
sigma   = 1./sum(abs(A),2);
tau     = 1./sum(abs(A'),2);
theta   = 1;

% Initialization
xb = zeros(size(A,2),1);
x  = zeros(size(A,2),1);
y  = zeros(size(b));

% Core
for k=1:Niter
    y   = proxFet(y + sigma .* (A * xb - b));
    x_1 = x;
    x   = x - tau .* (A' * y);
    xb  = x + theta * (x - x_1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = primal_dual_L1(A,b,Niter)

% Solve min_x ||Ax-b||_1 + Chi(x)
% st x_i>=0

% Parameters
proxFet = @(p) p./max(abs(p),1);
proxG   = @(x) max(x,0);
sigma   = 1./sum(abs(A),2);
tau     = 1./sum(abs(A'),2);
theta   = 1;

% Initialisation
xb = zeros(size(A,2),1);
x  = zeros(size(A,2),1);
y  = zeros(size(b));

% Core
for k=1:Niter
    y   = proxFet(y + sigma .* (A * xb - b));
    x_1 = x;
    x   = proxG(x - tau .* (A' * y));
    xb  = x + theta * (x - x_1);
end
