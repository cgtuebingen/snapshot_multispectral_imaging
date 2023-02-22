function obj = colorselect2mat(sx, color)
% Michael Hirsch | June 2016

% store all stuff in the structure
obj.s = [prod(sx) prod(sx)];
obj.color = color;
obj.tp = false;    % is the resulting matrix transposed?
obj = class(obj, 'colorselect2mat');
