function obj = combmat(varargin)
len = length(varargin);
Ms = cell(len, 1);
for i = 1:len
  M = varargin{i};
  Ms{len+1-i} = M;
end
%if len > 0
%  % check matrix sizes
%  for j = 2:len
%    left = size(Ms{j-1}); left = left(1);
%    right = size(Ms{j}); right = right(2);
%    if left ~= right
%      error('size missmatch');
%    end
%  end
%end

% calculate matrix size
left = size(Ms{len}); left = left(1);
right = size(Ms{1}); right = right(2);
s = [left, right];

% create the object
obj.s   = s;
obj.Ms  = Ms;
obj.len = len;
obj = class(obj, 'combmat');
