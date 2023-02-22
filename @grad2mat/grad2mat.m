function obj = grad2mat(~, ~, shape, ~, type)

if ~exist('shape','var')||isempty(shape), shape = 'valid'; end
if ~exist('type','var')||isempty(type), type = ''; end

obj.shape = shape;
obj.type = type;
obj.tp = false;    % transposed ?
obj = class(obj, 'grad2mat');
return
