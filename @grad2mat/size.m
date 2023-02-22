function s = size(obj, d);
grads  = obj.grads;
tp     = obj.tp;
s = size(grads{1});
s(1) = sum(cellfun(@(A) size(A, 1), grads));
if tp
  s = [s(2), s(1)];
end
if exist('d', 'var')
  s1 = s(d);
  return
end
if nargout <= 1
  s1 = s;
else
  s1 = s(1);
  s2 = s(2);
end
return
