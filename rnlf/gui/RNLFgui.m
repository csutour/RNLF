function param = RNLFgui(param, handles)

[M,N,T] = size(param.img);

if ~isfield(param,'NLF')
    if isfield(param, 'noisegen')
        answer = input('Do you wish to estimate the noise parameter ? Y/N \n Y: automatic estimation, \n N: uses true values \n [Default : Y]\n','s');
        if isempty(answer)
            answer='Y';
        end
        switch answer
            case {'Y','y'}
                param = noise_estimation(param,handles);
            case {'N','n'}
                switch param.noisegen
                    case 'hybrid'
                        param.NLF = [param.sig_gen(1,1)^2/param.sig_gen(1,2) param.sig_gen(2,1)^2*param.sig_gen(2,2) param.sig_gen(3,1)^2*param.sig_gen(3,2)^2];
                    otherwise
                        param.NLF = param.sig_gen;
                end
                param.noise = param.noisegen;
        end
    else
        param = noise_estimation(param,handles);
    end
end

% Denoising
disp('Denoising...')

axes(handles.waitbar_axes)
param.wait = waitbar(0, 'Please wait...');

param.res = RNLF(param.img_nse, param, handles);

close(param.wait)

if isfield(param,'noisegen')
    param.psnr = mean(10*log10((255^2)/(sum(sum(( (param.img - param.res).^2),2),1)/(size(param.img,1)*size(param.img,2)))));
    disp('PSNR = ')
    disp(param.psnr)
end

if T>1
    [lic,~] = license('checkout','Image_Toolbox');
    if lic
        implay(param.img_nse/255,15)
        implay(param.res/255,15)
    end
end

axes(handles.axes1)
hold off
imagesc(param.img_nse(:,:,floor((T+1)/2)),[0 255]),colormap('gray'),axis image, axis off
if isfield(param,'noisegen')
    title(['Noisy data, initial PSNR = ' num2str(param.psnr_init)])
end

axes(handles.axes3)
hold off
imagesc(param.res(:,:,floor((T+1)/2)),[0 255]),colormap('gray'),axis image, axis off
if isfield(param,'noisegen')
    title(['Denoised data, PSNR = ' num2str(param.psnr)])
end
