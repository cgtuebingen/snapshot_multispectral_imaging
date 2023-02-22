function a = transpose(a)

mats = cell(1, a.lmats);
for i=a.lmats:-1:1
  mats{i} = transpose(a.mats{a.lmats-i+1});
end
a.mats = mats;
