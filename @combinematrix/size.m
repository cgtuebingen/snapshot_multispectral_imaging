function s = size(a)

s1 = size(a.mats{1});
s2 = size(a.mats{a.lmats});
s = [s1(1), s2(2)];
