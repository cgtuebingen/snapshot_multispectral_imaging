function A = full(obj);
A = zeros(size(obj));
if obj.tp
  sv = obj.sy;
else
  sv = obj.sx;
end
for i=1:prod(sv)
  u = zeros(sv); u(i) = 1; 
  v = obj * u;
  A(:,i) = v(:);
end
return