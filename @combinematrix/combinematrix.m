function res = combinematrix(varargin)
res.mats = {};
for i = 1:length(varargin)
  A = varargin{i};
  if ~isempty(A)
    res.mats{end+1} = A;
  end
end
res.lmats = length(res.mats);
if 0 && res.lmats > 0
  % check matrix sizes
  left = size(res.mats{1}); left = left(2);
  for j=2:res.lmats
    sizej = size(res.mats{j});
    right = sizej(1);
    if left ~= right
      error('[@combinematrix/combinematrix.m] sizes do not match');
    end
    left = sizej(2);
  end
end
res = class(res, 'combinematrix');
