function h = plotimage(img, img_ref, stitle)

if ~exist('stitle', 'var')
    stitle = '';
end
h = imagesc(img);
colormap('gray');
axis image;
axis off;
if exist('img_ref', 'var') && ~isempty(img_ref)
    caxis([min(img_ref(:)) max(img_ref(:))]);
    if ~isinf(psnr(img, img_ref))
        title(sprintf('%s (%f)', stitle, psnr(img, img_ref)));
    else
        title(stitle);
    end
else
    title(stitle);
end
if nargout < 1
    clear h
end