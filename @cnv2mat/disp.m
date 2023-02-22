function disp(obj)
fprintf('%s object', class(obj));
s = size(obj);
fprintf('  effective size: %d-by-%d\n', s(1), s(2));
