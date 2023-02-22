function obj = transpose(obj)
len = obj.len;
Ms  = obj.Ms;
s   = obj.s;
s   = [s(2), s(1)];
Mtps = cell(len, 1);
for i = 1:len
  Mtps{len-i+1} = transpose(Ms{i});
end
obj.Ms = Mtps;
obj.s  = s;