function sx = get_sin(obj)
if obj.tp
  % transposed
  sx = obj.sy;
else
  sx = obj.sx;
end
