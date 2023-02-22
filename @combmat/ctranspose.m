function obj = ctranspose(obj)
Ms  = obj.Ms;
len = obj.len;
s   = obj.s;
s = [s(2), s(1)];
Mtps = cell(len, 1);
for i = 1:len
  Mtps{len-i+1} = ctranspose(Ms{i});
end
obj.Ms = Mtps;
obj.s  = s;