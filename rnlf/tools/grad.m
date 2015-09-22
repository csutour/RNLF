function G = grad(I)

nd=ndims(I);

%Gradient
switch nd
  case 1
    n  = size(I);
    dx = [2:n 1];
    G  = I(dx,:,:)-I;
    G(end, 1) = 0;
  case 2
    [n,m] = size(I);
    dx = [2:n 1];
    dy = [2:m 1];
    G = cat(nd+1, I(dx,:,:)-I, I(:,dy,:)-I);
    G(end, :, 1) = 0;
    G(:, end, 2) = 0;
  case 3
    [n,m,t] = size(I);
    dx = [2:n 1];
    dy = [2:m 1];
    dz = [2:t 1];
    G = cat(nd+1, I(dx,:,:)-I, I(:,dy,:)-I, I(:,:,dz)-I);
    G(end, :, :, 1) = 0;
    G(:, end, :, 2) = 0;
    G(:, :, end, 3) = 0;
  otherwise
    error(['Grad for dimension ' num2str(nd) ' not implemented']);
end

end

