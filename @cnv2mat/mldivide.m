function x = mldivide(obj, y)

sf    = obj.sf;
sx    = obj.sx;
sy    = obj.sy;
sz    = obj.sz;
sw    = obj.sw;
z     = obj.z;    % precomputed fft
shape = obj.shape;
f     = obj.f;

% we can also use vectorized inputs
reshaped = 0;

if obj.tp
  if isvector(y) && numel(y) == prod(sx)
    reshaped = 1;
    y = reshape(y,sx);
  end
  switch shape
   case 'valid'
    error('not yet implemented')
   case 'circ'
    x = ifftn(fftn(y, sz) ./ conj(z));
    x = circshift(x, -floor(sw/2));
   case 'same'
    error('not yet implemented')
    %           x = lsqr(obj',vec(y),[],100);
    %           x = reshape(x,sy);
  end
else
  if isvector(y) && numel(y) == prod(sy)
    reshaped = 1;
    y = reshape(y,sy);
  end
  switch shape
   case 'valid'
    error('not yet implemented')
   case 'circ'
    x = ifftn(fftn(y, sz) ./ z);
    x = circshift(x, floor(sw/2));
   case 'same'
    error('not yet implemented')
    %           x = lsqr(obj,vec(y),[],100);
    %           x = reshape(x,sx);
  end
end

if reshaped
  x = vec(x);
end

end

