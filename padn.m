function y = padn(x, sy, offset)
% PADN pads x such that its size becomes sy and x is offset.
%
% y = padn(x, sy, offset)
%
% Input:  x       input image
%         sy      size of padded output image
%         offset  offset of padding
%
% Output: y       padded image of size sy
%
% Michael Hirsch (c) 2012

if ~exist('offset', 'var')||isempty(offset)
  offset=zeros(1,length(sy)); 
end

if isscalar(sy) == 1
  y = zeros(sy, 1);  % stupid case due to matlab's syntactic sugar
else
  y = zeros(sy);
end
sx = size(x);
o = offset;  % for brevity
switch length(sy)
 case 1
  y(o(1)+(1:sx(1))) = x;
 case 2
  y(o(1)+(1:sx(1)),o(2)+(1:sx(2))) = x;
end
return
