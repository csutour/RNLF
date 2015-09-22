function h = plothomogeneous(img_nse, W, hom, img_ref)

if ~exist('img_ref', 'var')
    img_ref = img_nse;
end
img_nse = (img_nse - min(img_ref(:))) / (max(img_ref(:)) - min(img_ref(:)));

[M, N] = size(img_nse);
rgb = zeros(M, N, 3);
rgb(:,:,1) = img_nse .* (~hom) + ...
    (0.2 + img_nse) .* (hom);
rgb(:,:,2) = img_nse .* ~hom + img_nse * 0.5 .* hom;
rgb(:,:,3) = img_nse .* ~hom + img_nse * 0.5 .* hom;
rgb = min(rgb, 1);
rgb = max(rgb, 0);
h = imagesc(rgb, [0 1]);
axis image
axis off

hold on
for i = 1:W:(M-W+1)
    plot([1 N], 0.5 + [i+W-1 i+W-1], 'k')
end
for j = 1:W:(N-W+1)
    plot(0.5 + [j+W-1 j+W-1], [1 M], 'k')
end

title('Homogeneous regions');

if nargout == 0
    clear h;
end
