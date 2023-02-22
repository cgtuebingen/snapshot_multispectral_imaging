function [s1, s2] = size(obj, d)
s  = obj.s;
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
