function y = mtimes(obj, x)
Ms  = obj.Ms;
len = obj.len;
y = x;
for i = 1:len
  y = Ms{i} * y;
end
