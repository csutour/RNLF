%NLFMEANS blindly denoises an image
%   IMG_FIL = NLFMEANS(IMG_NSE) returns a denoised image or video
%   contained in the 2 or 3D array IMG_NSE using the function
%   NLMEANS. The noise characteristics is first estimated
%   using the function NOISE_ESTIMATION.
%
%   [IMA_FIL, NOISE, NOISE_INFO, IMA_REDUCTION] = NLFMEANS(IMA_NSE)
%   the returned variables are those of NLMEANS and
%   NOISE_ESTIMATION.
%
%   NLFMEANS(IMA_NSE, PARAM) fields in the structure PARAM override
%   the default parameters as described in NLMEANS and
%   NOISE_ESTIMATION.
%
%   References
%   ----------
%   Sutour, C., Deledalle, C.-A. & Aujol, J.-F. "Estimation of the
%   noise level function based on a non-parametric detection of
%   homogeneous image regions." SIAM Journal on Imaging Sciences
%   (in press)
%
%   License
%   -------
%   This work is protected by the CeCILL-C Licence, see
%   - Licence_CeCILL_V2.1-en.txt
%   - Licence_CeCILL_V2.1-fr.txt
%
%   See also NLMEANS, RNL, RNLF, TV, NOISE_ESTIMATION.

%   Copyright 2015 Camille Sutour

function [img_fil, noise, noise_info, img_reduction] = nlfmeans(img_nse, param)

[noise, noise_info] = noise_estimation(img_nse, param);
[img_fil, img_reduction] = nlfmeans(img_nse, noise, param);
