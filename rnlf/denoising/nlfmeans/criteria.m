function diff = criteria(I, J, noise)

switch noise.type
  case 'gauss'
    diff = (I - J).^2 / (2 * noise.sig^2);
  case 'poisson'
    diff = xlogx(I / noise.Q) + xlogx(J / noise.Q) - 2 * xlogx((I + J) / noise.Q / 2);
  case 'gamma'
    diff = noise.L * (2 * log(I + J) - log(I) - log(J) - 2 * log(2));
  case { 'hybrid', 'poly2' }
    diff = (I - J).^2 ./ (noise.nlf(I) + noise.nlf(J));
  otherwise
    error(['Criteria for ' noise ' noise non implemented']);
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = xlogx(x)

y = x .* log(x);
y(x == 0) = 0;
