function [tau, pvalue] = kendalltau(img, W, dx, dy)

mfn = [ mfilename('fullpath') '.' mexext ];
cfn = [ mfilename('fullpath') '.c' ];
if ~exist(cfn, 'file')
    error('Kendalltau implementation missing');
    return
end
if ~exist(mfn, 'file')
    mex('CFLAGS=\$CFLAGS -fopenmp', ...
        'LDFLAGS=\$LDFLAGS -lgomp -fopenmp', ...
        '-DMATLAB_MEX_FILE', ...
        cfn, '-output', mfn);
end
[tau, pvalue] = kendalltau(img, W, dx, dy);
