function dispvideo(img_rnlf, img_nse, img_ref)

T=size(img_nse,3);

figure
subplot(1, 2, 1);
plotimage(img_nse(:,:,floor((T+1)/2)), img_ref(:,:,floor((T+1)/2)), 'Noisy image');
subplot(1, 2, 2);
plotimage(img_rnlf(:,:,floor((T+1)/2)), img_ref(:,:,floor((T+1)/2)), 'RNLF');

[lic,~] = license('checkout','Image_Toolbox');
if lic
    % Conversion in [0,1] for video display
    if exist('img_ref', 'var') && ~isempty(img_ref)
        mi=min(img_ref(:));
        ma=max(img_ref(:));
        img_ref_01 = (img_ref-mi)/(ma-mi);
        implay(img_ref_01,15)
    else
        mi=min(img_nse(:));
        ma=max(img_nse(:));
    end
    img_nse_01 = (img_nse-mi)/(ma-mi);
    img_nse_01(img_nse_01>1)=1;
    img_nse_01(img_nse_01<0)=0;
    implay(img_nse_01,15)
    img_rnlf_01 = (img_rnlf-mi)/(ma-mi);
    img_rnlf_01(img_rnlf_01>1)=1;
    img_rnlf_01(img_rnlf_01<0)=0;
    implay(img_rnlf_01,15)
end
