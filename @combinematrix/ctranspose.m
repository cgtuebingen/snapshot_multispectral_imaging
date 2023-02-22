function a = ctranspose(a)

mats = cell(1, a.lmats);
for i=a.lmats:-1:1
  mats{i} = ctranspose(a.mats{a.lmats-i+1});
end
a.mats = mats;
