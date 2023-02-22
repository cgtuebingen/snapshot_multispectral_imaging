function y = mtimes(obj, x)

sx    = obj.sx;
sy    = obj.sy;
sz    = obj.sz;
sw    = obj.sw;

% we can also use vectorized inputs
reshaped = 0;  

if obj.tp
  if isvector(x) && numel(x) == prod(sy)
    reshaped = 1;
    x = reshape(x,sy);
  else
    if any(sy ~= size(x))
      error('size missmatch')
    end
  end
  % transposed
  switch obj.shape
   case 'valid'
    x = [zeros(sw(1)-1, sy(2)+sw(2)-1);
         zeros(sy(1), sw(2)-1), x]; % zero padding
   case 'circ'
    x = circshift(x, floor(sw/2));
   case 'same'
    sw2 = floor(sw/2);
    xx = zeros(sz);
    xx(sw2(1)+(1:sy(1)), sw2(2)+(1:sy(2))) = x;
    x = xx;
  end
  y = ifftn(fftn(x) .* conj(obj.z));
  y = y(1:sx(1), 1:sx(2));
else
  if isvector(x) && numel(x) == prod(sx)
    reshaped = 1;
    x = reshape(x,sx);
  else
    if any(sx ~= size(x))
      error('size missmatch')
    end
  end
  % not transposed
  y = ifftn(fftn(x, sz).* obj.z);
  switch obj.shape
   case 'valid'
    y = y(sw(1):end, sw(2):end);
   case 'circ'
    y = circshift(y, -floor(sw/2));
   case 'same'
    sw2 = floor(sw/2);
    y = y((sw2(1)+1):end, (sw2(2)+1):end);
    y = y(1:sy(1), 1:sy(2));
  end
end
y = real(y);

if reshaped
  y = y(:);
end
return
