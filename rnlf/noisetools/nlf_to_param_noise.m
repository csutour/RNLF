function nlf_to_param_noise(nlf, noise)

FIXME

switch noise
    case 'gamma'
        Lest = NLF;
        sd = @(x) x/sqrt(Lest);
        disp(['L estimé = ' num2str(Lest)])
    case 'poisson'
        Qest = NLF;
        sd = @(x) sqrt((Qest*sqrt(x/Qest)).^2);
        disp(['Q estimé = ' num2str(Qest)])

    case 'gauss'
        sigest=NLF;
        sd = @(x) sigest;
        disp(['\sigma estimé = ' num2str(sigest)])

    case 'poly2'
        coefs = NLF;
        sd = @(x) sqrt(coefs(1) * x.^2 + coefs(2) * x + coefs(3));
        disp(coefs)
end
