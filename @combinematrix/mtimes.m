function R = mtimes(a,B)

R = B;
for i = a.lmats:-1:1
  R = a.mats{i} * R;
end
