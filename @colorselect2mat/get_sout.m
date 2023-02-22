function sout = get_sout(obj)
if obj.tp
  % transposed
  sout = obj.sx;
else 
  sout = obj.sy;
end
