%KENDALLTAU gives local scores of homogeneity
%   [TAU, PVALUE] = KENDALLTAU(IMAGE, WINDOW_SIZE, DX, DY) returns
%   the Kendall-tau coefficients and their associated p-values
%   in all non-overlapping WINDOW_SIZE x WINDOW_SIZE windows of the
%   2D array IMAGE as described in reference [1]. DX and DY define
%   how the sequences to be compared in each window are extracted.
%
%   KENDALLTAU(IMAGE, WINDOW_SIZE, DX, DY, TYPE). TYPE indicates the
%   type of algorithm to use. Its possible values are
%       'fast'          for fast implementation O(n log n),
%       'noties'        same as 'fast', does not  account for ties,
%       'naive'         for naive implementation O(n^2),
%       'naive-noties'  same as 'naive', does not account for ties.
%
%   License
%   -------
%   This work is protected by the CeCILL-C Licence, see
%   - Licence_CeCILL_V2.1-en.txt
%   - Licence_CeCILL_V2.1-fr.txt

%   Copyright 2015 Charles Deledalle

function [tau, pvalue] = kendalltau(img, W, dx, dy)

mfn = [ mfilename('fullpath') '.' mexext ];
cfn = [ mfilename('fullpath') '.c' ];
if ~exist(cfn, 'file')
    error('Kendalltau implementation missing');
    return
end
if ~exist(mfn, 'file')
    % Tested on Linux with gcc
    % Tested on Windows 7 with Windows SDK 7.1
    mex('CFLAGS=\$CFLAGS -fopenmp', ...
        'LDFLAGS=\$LDFLAGS -lgomp -fopenmp', ...
        '-DMATLAB_MEX_FILE', ...
        cfn, '-output', mfn);
end
[tau, pvalue] = kendalltau(img, W, dx, dy);
