%CRITERIA measure similarties wrt to the nature of the noise
%   [DIFF = CRITERIA(I, J, NOISE) returns the element-wise
%   dissimilarity between two ND-arrays I and J with respect to the
%   the noise information contains in the structure NOISE (as
%   provided by NOISEGEN) using the method described in references
%   [1] and [2].
%
%   References
%   ----------
%   [1] Deledalle, C. A., Denis, L., & Tupin, F. (2012). How to
%   compare noisy patches? Patch similarity beyond Gaussian
%   noise. International journal of computer vision, 99(1), 86-102.
%
%   [2] Sutour, C., Deledalle, C.-A. & Aujol, J.-F. "Estimation of
%   the noise level function based on a non-parametric detection of
%   homogeneous image regions." SIAM Journal on Imaging Sciences
%   (in press)
%
%   License
%   -------
%   This work is protected by the CeCILL-C Licence, see
%   - Licence_CeCILL_V2.1-en.txt
%   - Licence_CeCILL_V2.1-fr.txt
%
%   See also RNL, TV.

%   Copyright 2015 Camille Sutour and Charles Deledalle

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
