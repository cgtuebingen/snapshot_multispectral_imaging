function z = color_selector(x,color)

z = zeros(size(x));
z(:,:,color) = x(:,:,color);
return