function div = div(I)
%I : à trois ou quatre dimensions

s  = size(I);
nd = ndims(I) - 1;
if s(end) ~= nd
    error(['Div requires the vector field to be ' num2str(nd) ' dimensional']);
end
n = s(1);

%Divergence
switch nd
  case 1
    tx = [n 1:n-1];
    div = I - I(tx);
    div(1, :) = I(1, :);
    div(end, :) = -I(end-1, :);
  case 2
    m = s(2);
    tx = [n 1:n-1];
    ty = [m 1:m-1];
    divx         = I(:, :, 1) - I(tx, :, 1);
    divx(1, :)   = I(1, :, 1);
    divx(end, :) = -I(end-1, :, 1);
    divy         = I(:, :, 2) - I(:,ty,2);
    divy(:, 1)   = I(:, 1, 2);
    divy(:, end) = -I(:, end-1, 2);
    div = divx + divy;
  case 3
    m = s(2);
    t = s(3);
    tx = [n 1:n-1];
    ty = [m 1:m-1];
    tz = [t 1:t-1];
    divx            = I(:, :, :, 1) - I(tx, :, :, 1);
    divx(1, :, :)   = I(1, :, :, 1);
    divx(end, :, :) = -I(end-1, :, :, 1);
    divy            = I(:, :, :, 2) - I(:, ty, :, 2);
    divy(:, 1, :)   = I(:, 1, :, 2);
    divy(:, end, :) = -I(:, end-1, :, 2);
    divz            = I(:, :, :, 3) - I(:, :, tz, 3);
    divz(:, :, 1)   = I(:, :, 1, 3);
    divz(:, :, end) = -I(:, :, end-1, 3);
    div = divx + divy + divz;
end
