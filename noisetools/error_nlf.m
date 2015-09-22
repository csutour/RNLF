function error = error_nlf(nlf, nlf_true, range)

evalnlf = nlf(range);
evalnlf_true = nlf_true(range);
error = mean(abs(evalnlf_true.^2 - evalnlf.^2) ./ (evalnlf_true.^2));
