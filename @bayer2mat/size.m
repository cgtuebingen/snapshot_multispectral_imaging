function [s1, s2] = size(obj, d)
s  = obj.s;
tp = obj.tp;
if tp
  s = [s(2), s(1)];
end
if exist('d' ,'var')
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