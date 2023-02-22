function x = unpadn(y, sx, offset)
% UNPADN chops at loc in x of size y.
%
% This function is the transpose of padn.  See also @padmat.
%
% SH * 27 NOV 2009

if ~exist('offset', 'var')||isempty(offset)
  offset=zeros(1,length(sx)); 
end

o = offset;   % for brevity
switch length(sx)
 case 1
  x = y(o(1)+(1:sx(1)));
 case 2
  x = y(o(1)+(1:sx(1)),o(2)+(1:sx(2)));
 case 3
  x = y(o(1)+(1:sx(1)),o(2)+(1:sx(2)),o(3)+(1:sx(3)));
 case 4
  x = y(o(1)+(1:sx(1)),o(2)+(1:sx(2)),o(3)+(1:sx(3)),o(4)+(1:sx(4)));
 case 5
  x = y(o(1)+(1:sx(1)),o(2)+(1:sx(2)),o(3)+(1:sx(3)),o(4)+(1:sx(4)),o(5)+(1:sx(5)));
 otherwise
  error('six and more dimensions not yet implemented')
end
return
